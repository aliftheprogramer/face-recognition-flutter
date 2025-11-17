import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/entity/detected_face_entity.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/entity/face_recognition_entity.dart';

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
    // TFLite dihapus: kembalikan tanpa deteksi
    return [];
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
