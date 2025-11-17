import 'dart:async'; // Untuk Timer
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/usecase/detect_face_usecase.dart';
import '../../../../core/services/services_locator.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecase/get_available_cameras_usecase.dart';
import '../../domain/usecase/recognize_face_usecase.dart';

import '../../data/source/face_recognition_local_data_source.dart'; // Untuk dispose interpreter
import 'face_recognition_state.dart';

class FaceRecognitionCubit extends Cubit<FaceRecognitionState> {
  final GetAvailableCamerasUsecase _getAvailableCamerasUsecase;
  final RecognizeFaceUsecase _recognizeFaceUsecase;
  final DetectFacesUsecase _detectFacesUsecase; // Use Case baru
  
  // Timer untuk membatasi frekuensi deteksi
  Timer? _detectionTimer;
  bool _isDetecting = false; // Flag untuk menghindari deteksi bersamaan

  FaceRecognitionCubit() 
      : _getAvailableCamerasUsecase = sl<GetAvailableCamerasUsecase>(),
        _recognizeFaceUsecase = sl<RecognizeFaceUsecase>(),
        _detectFacesUsecase = sl<DetectFacesUsecase>(), // Inisialisasi use case baru
        super(const FaceRecognitionState());

  @override
  Future<void> close() {
    _detectionTimer?.cancel();
    state.controller?.dispose();
    sl<FaceRecognitionLocalDataSource>().disposeFaceDetector(); // Tutup interpreter TFLite
    return super.close();
  }

  Future<void> initCamera() async {
    emit(state.copyWith(
      cameraStatus: CameraStatus.loading, 
      errorMessage: null,
      detectedFaces: [], // Reset deteksi
    ));
    
    // Inisialisasi TFLite Face Detector saat kamera diinisialisasi
    await sl<FaceRecognitionLocalDataSource>().initFaceDetector();

    final result = await _getAvailableCamerasUsecase(param: NoParams());

    result.fold(
      (err) => emit(state.copyWith(
        cameraStatus: CameraStatus.error, 
        errorMessage: err.toString(), 
        controller: null,
      )),
      (cameras) async {
        if (cameras.isEmpty) {
          return emit(state.copyWith(
            cameraStatus: CameraStatus.error,
            errorMessage: 'Tidak ada kamera tersedia.',
            controller: null,
          ));
        }

        final frontCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
        );
        
        final controller = CameraController(
          frontCamera,
          ResolutionPreset.low, // Gunakan resolusi rendah untuk deteksi real-time
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420, // Penting untuk pemrosesan TFLite
        );
        
        try {
          await controller.initialize();
          emit(state.copyWith(
            cameraStatus: CameraStatus.ready,
            controller: controller,
            frontCamera: frontCamera,
          ));
          startImageStream(); // Mulai stream gambar untuk deteksi wajah
        } on CameraException catch (e) {
          emit(state.copyWith(
            cameraStatus: CameraStatus.error, 
            errorMessage: 'Gagal inisialisasi kamera: ${e.description}',
            controller: null,
          ));
        }
      },
    );
  }
  
  void disposeController() {
    _detectionTimer?.cancel();
    _detectionTimer = null;
    state.controller?.stopImageStream(); // Hentikan stream gambar
    state.controller?.dispose();
    emit(state.copyWith(
      controller: null, 
      cameraStatus: CameraStatus.initial,
      detectedFaces: [],
    ));
  }

  // Metode baru untuk memulai stream gambar
  void startImageStream() {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized || controller.value.isStreamingImages) {
      return;
    }

    controller.startImageStream((image) async {
      if (_isDetecting || state.cameraStatus != CameraStatus.ready) return;

      // Batasi frekuensi deteksi agar tidak membebani CPU
      _detectionTimer ??= Timer.periodic(const Duration(milliseconds: 200), (timer) async {
        if (!_isDetecting) {
          _isDetecting = true;
          emit(state.copyWith(detectionStatus: DetectionStatus.detecting)); // Update status
          
          final result = await _detectFacesUsecase(param: image);
          result.fold(
            (err) => emit(state.copyWith(
              errorMessage: err.toString(),
              detectedFaces: [],
            )),
            (faces) => emit(state.copyWith(
              detectedFaces: faces,
            )),
          );
          _isDetecting = false;
          emit(state.copyWith(detectionStatus: DetectionStatus.idle)); // Reset status
        }
      });
    });
  }


  Future<void> captureAndRecognize() async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return;

    // Pastikan ada wajah yang terdeteksi sebelum mengambil gambar
    if (state.detectedFaces.isEmpty) {
      return emit(state.copyWith(
        recognitionStatus: RecognitionStatus.failure,
        errorMessage: 'Tidak ada wajah terdeteksi. Posisikan wajah di depan kamera.',
      ));
    }

    emit(state.copyWith(recognitionStatus: RecognitionStatus.processing, errorMessage: null));
    try {
      final xFile = await controller.takePicture();
      final imageFile = xFile.length() == 0 ? null : File(xFile.path);

      if (imageFile == null) {
          return emit(state.copyWith(
            recognitionStatus: RecognitionStatus.failure,
            errorMessage: 'Gagal mengambil gambar.',
          ));
      }
      
      // Masuk ke lapisan Domain (Use Case)
      final result = await _recognizeFaceUsecase(param: imageFile);

      result.fold(
        (err) => emit(state.copyWith(
          recognitionStatus: RecognitionStatus.failure, 
          errorMessage: err.toString(),
        )),
        (entity) {
          emit(state.copyWith(
            recognitionStatus: RecognitionStatus.success, 
            result: entity,
          ));
        }
      );
    } catch (e) {
      emit(state.copyWith(
        recognitionStatus: RecognitionStatus.failure,
        errorMessage: 'Terjadi error saat memproses: ${e.toString()}',
      ));
    } finally {
        if (state.recognitionStatus != RecognitionStatus.success) {
            emit(state.copyWith(recognitionStatus: RecognitionStatus.idle));
        }
    }
  }
}