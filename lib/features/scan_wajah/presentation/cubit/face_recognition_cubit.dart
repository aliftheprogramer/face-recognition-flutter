import 'dart:async'; // Untuk Timer
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/services_locator.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecase/get_available_cameras_usecase.dart';
import '../../domain/usecase/recognize_face_usecase.dart';
import 'face_recognition_state.dart';

class FaceRecognitionCubit extends Cubit<FaceRecognitionState> {
  final GetAvailableCamerasUsecase _getAvailableCamerasUsecase;
  final RecognizeFaceUsecase _recognizeFaceUsecase;

  // Tidak ada deteksi wajah real-time lagi

  FaceRecognitionCubit()
    : _getAvailableCamerasUsecase = sl<GetAvailableCamerasUsecase>(),
      _recognizeFaceUsecase = sl<RecognizeFaceUsecase>(),
      super(const FaceRecognitionState());

  @override
  Future<void> close() {
    state.controller?.dispose();
    return super.close();
  }

  Future<void> initCamera() async {
    emit(
      state.copyWith(
        cameraStatus: CameraStatus.loading,
        errorMessage: null,
        detectedFaces: [], // Reset deteksi
      ),
    );

    final result = await _getAvailableCamerasUsecase(param: NoParams());

    result.fold(
      (err) => emit(
        state.copyWith(
          cameraStatus: CameraStatus.error,
          errorMessage: err.toString(),
          controller: null,
        ),
      ),
      (cameras) async {
        // Pastikan hasil bertipe List<CameraDescription>
        final List<CameraDescription> camList = List<CameraDescription>.from(
          cameras,
        );

        if (camList.isEmpty) {
          return emit(
            state.copyWith(
              cameraStatus: CameraStatus.error,
              errorMessage: 'Tidak ada kamera tersedia.',
              controller: null,
            ),
          );
        }

        final frontCamera = camList.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => camList.first,
        );

        final controller = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );

        try {
          await controller.initialize();
          emit(
            state.copyWith(
              cameraStatus: CameraStatus.ready,
              controller: controller,
              frontCamera: frontCamera,
            ),
          );
          // Tidak ada stream deteksi wajah
        } on CameraException catch (e) {
          emit(
            state.copyWith(
              cameraStatus: CameraStatus.error,
              errorMessage: 'Gagal inisialisasi kamera: ${e.description}',
              controller: null,
            ),
          );
        }
      },
    );
  }

  void disposeController() {
    state.controller?.stopImageStream();
    state.controller?.dispose();
    emit(
      state.copyWith(
        controller: null,
        cameraStatus: CameraStatus.initial,
        detectedFaces: [],
      ),
    );
  }

  Future<void> switchCamera() async {
    final current = state.controller;
    if (current == null) return;

    // Ambil daftar kamera
    final camsEither = await _getAvailableCamerasUsecase(param: NoParams());
    await current.dispose();

    await camsEither.fold(
      (err) async {
        emit(
          state.copyWith(
            cameraStatus: CameraStatus.error,
            errorMessage: err.toString(),
            controller: null,
          ),
        );
      },
      (cameras) async {
        final List<CameraDescription> camList = List<CameraDescription>.from(
          cameras,
        );
        if (camList.isEmpty) {
          emit(
            state.copyWith(
              cameraStatus: CameraStatus.error,
              errorMessage: 'Tidak ada kamera tersedia.',
              controller: null,
            ),
          );
          return;
        }

        final usingFront =
            state.frontCamera?.lensDirection == CameraLensDirection.front;
        final target = camList.firstWhere(
          (c) =>
              c.lensDirection ==
              (usingFront
                  ? CameraLensDirection.back
                  : CameraLensDirection.front),
          orElse: () => camList.first,
        );

        final newController = CameraController(
          target,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );

        try {
          await newController.initialize();
          emit(
            state.copyWith(
              cameraStatus: CameraStatus.ready,
              controller: newController,
              frontCamera: target,
            ),
          );
        } on CameraException catch (e) {
          emit(
            state.copyWith(
              cameraStatus: CameraStatus.error,
              errorMessage: 'Gagal ganti kamera: ${e.description}',
              controller: null,
            ),
          );
        }
      },
    );
  }

  Future<void> toggleFlash() async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final current = controller.value.flashMode;
      final next = current == FlashMode.torch ? FlashMode.off : FlashMode.torch;
      await controller.setFlashMode(next);
    } catch (_) {
      // Abaikan jika mode flash tidak didukung
    }
  }

  /// Ambil foto dan simpan `XFile` ke `state.captures` tanpa melakukan
  /// proses pengenalan. Mengembalikan `XFile` yang diambil atau `null` jika gagal.
  Future<XFile?> captureAndSave() async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return null;

    try {
      final xFile = await controller.takePicture();
      final newCaptures = List<XFile>.from(state.captures)..add(xFile);
      emit(state.copyWith(captures: newCaptures));
      return xFile;
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Gagal mengambil gambar: ${e.toString()}'),
      );
      return null;
    }
  }

  Future<void> captureAndRecognize() async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return;

    // Pastikan ada wajah yang terdeteksi sebelum mengambil gambar
    if (state.detectedFaces.isEmpty) {
      return emit(
        state.copyWith(
          recognitionStatus: RecognitionStatus.failure,
          errorMessage:
              'Tidak ada wajah terdeteksi. Posisikan wajah di depan kamera.',
        ),
      );
    }

    emit(
      state.copyWith(
        recognitionStatus: RecognitionStatus.processing,
        errorMessage: null,
      ),
    );
    try {
      final xFile = await controller.takePicture();

      // Simpan XFile ke state.captures
      final newCaptures = List<XFile>.from(state.captures)..add(xFile);
      emit(state.copyWith(captures: newCaptures));

      final imageFile = xFile.length() == 0 ? null : File(xFile.path);

      if (imageFile == null) {
        return emit(
          state.copyWith(
            recognitionStatus: RecognitionStatus.failure,
            errorMessage: 'Gagal mengambil gambar.',
          ),
        );
      }

      // Masuk ke lapisan Domain (Use Case)
      final result = await _recognizeFaceUsecase(param: imageFile);

      result.fold(
        (err) => emit(
          state.copyWith(
            recognitionStatus: RecognitionStatus.failure,
            errorMessage: err.toString(),
          ),
        ),
        (entity) {
          emit(
            state.copyWith(
              recognitionStatus: RecognitionStatus.success,
              result: entity,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          recognitionStatus: RecognitionStatus.failure,
          errorMessage: 'Terjadi error saat memproses: ${e.toString()}',
        ),
      );
    } finally {
      if (state.recognitionStatus != RecognitionStatus.success) {
        emit(state.copyWith(recognitionStatus: RecognitionStatus.idle));
      }
    }
  }
}
