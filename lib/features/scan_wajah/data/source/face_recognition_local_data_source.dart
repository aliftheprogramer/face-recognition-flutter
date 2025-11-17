import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/entity/detected_face_entity.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/entity/face_recognition_entity.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

abstract class FaceRecognitionLocalDataSource {
  Future<List<dynamic>> getAvailableCameras();

  Future<List<DetectedFaceEntity>> detectFaces(
    CameraImage cameraImage,
  ); // Method baru
  Future<FaceRecognitionEntity> recognizeFace(File image);

  Future<FaceRecognitionEntity> registerFace(String userId, File image);
}

class FaceRecognitionLocalDataSourceImpl
    implements FaceRecognitionLocalDataSource {
  Interpreter? _faceDetectorInterpreter;

  Future<void> initFaceDetector() async {
    try {
      if (_faceDetectorInterpreter != null) return;
      _faceDetectorInterpreter = await Interpreter.fromAsset(
        'assets/ml/face_detection.tflite', // Path model deteksi wajah Anda
        options: InterpreterOptions()..threads = 2, // Sesuaikan jumlah thread
      );
      Logger().i('TFLite Face Detector loaded successfully!');
    } catch (e) {
      Logger().e('Failed to load TFLite Face Detector: $e');
      _faceDetectorInterpreter = null;
    }
  }

  void disposeFaceDetector() {
    _faceDetectorInterpreter?.close();
    _faceDetectorInterpreter = null;
  }

  @override
  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } on CameraException catch (e) {
      throw PlatformException(code: e.code, message: e.description);
    }
  }

  @override
  Future<List<DetectedFaceEntity>> detectFaces(CameraImage cameraImage) async {
    if (_faceDetectorInterpreter == null) {
      Logger().i('Face detector not initialized.');
      return [];
    }

    // --- Pre-processing CameraImage ke format yang diterima TFLite ---
    // Ini adalah bagian yang paling kompleks dan seringkali bergantung pada model TFLite Anda.
    // Contoh ini mengasumsikan model menerima input float32 [1, height, width, 3].
    // Anda mungkin perlu mengonversi YUV420 ke RGB.

    // Contoh sederhana konversi (BUTUH PENYESUAIAN SESUAI MODEL ANDA)
    // Untuk YUV420, Anda perlu melakukan konversi yang lebih rumit.
    // Library 'image' dapat membantu, tetapi mungkin lambat untuk real-time.
    // Untuk performa, pertimbangkan paket seperti 'image_converter' atau implementasi sendiri.

    // placeholder untuk input
    final inputTensor = List<List<List<List<double>>>>.filled(
      1,
      List<List<List<double>>>.filled(
        128, // Contoh tinggi input model
        List<List<double>>.filled(
          128, // Contoh lebar input model
          List<double>.filled(3, 0.0),
        ),
      ),
    );

    // Placeholder untuk output
    // Sesuaikan bentuk output dengan model deteksi wajah Anda.
    // Contoh: output 1 adalah bounding box, output 2 adalah skor.
    // Misal: [1, N, 4] untuk bounding box, [1, N] untuk confidence.
    final List<Object> outputs = [
      List<List<double>>.filled(
        10,
        List<double>.filled(4, 0.0),
      ), // Bounding boxes (y1, x1, y2, x2)
      List<double>.filled(10, 0.0), // Scores
      List<double>.filled(10, 0.0), // Classes (jika ada)
      List<double>.filled(1, 0.0), // Jumlah deteksi
    ];

    try {
      _faceDetectorInterpreter?.runForMultipleInputs(
        [inputTensor], // Input gambar yang sudah diproses
        {
          0: outputs[0],
          1: outputs[1],
          // ... sesuai output model Anda
        },
      );

      final List<DetectedFaceEntity> detectedFaces = [];
      // Parsing hasil output TFLite
      final boxes =
          outputs[0]
              as List<List<double>>; // Misal output 0 adalah bounding box
      final scores = outputs[1] as List<double>; // Misal output 1 adalah skor

      // Iterasi hasil deteksi
      for (int i = 0; i < scores.length; i++) {
        if (scores[i] > 0.5) {
          // Thresholding confidence
          // Konversi koordinat relatif (0-1) ke koordinat piksel
          // Model sering mengembalikan [y1, x1, y2, x2]
          final y1 = boxes[i][0] * cameraImage.height;
          final x1 = boxes[i][1] * cameraImage.width;
          final y2 = boxes[i][2] * cameraImage.height;
          final x2 = boxes[i][3] * cameraImage.width;

          detectedFaces.add(
            DetectedFaceEntity(
              boundingBox: Rect.fromLTRB(x1, y1, x2, y2),
              confidence: scores[i],
            ),
          );
        }
      }
      return detectedFaces;
    } catch (e) {
      Logger().i('Error running TFLite inference: $e');
      return [];
    }
  }

  @override
  Future<FaceRecognitionEntity> registerFace(String userId, File image) async {
    await Future.delayed(const Duration(seconds: 1));
    return FaceRecognitionEntity.registrationSuccess();
  }
  

  @override
  Future<FaceRecognitionEntity> recognizeFace(File image) async {
    await Future.delayed(const Duration(seconds: 1));
    return FaceRecognitionEntity(
      userId: 'backend_id_001',
      userName: 'Backend User',
      confidence: 0.98,
    );
  }
}
