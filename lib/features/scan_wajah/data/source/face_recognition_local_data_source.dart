import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/entity/face_recognition_entity.dart';

abstract class FaceRecognitionLocalDataSource {
  Future<List<dynamic>> getAvailableCameras();
  
  Future<FaceRecognitionEntity> recognizeFace(File image);

  Future<FaceRecognitionEntity> registerFace(String userId, File image);
}


class FaceRecognitionLocalDataSourceImpl implements FaceRecognitionLocalDataSource{
@override
  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      // Logic dari package camera
      return await availableCameras();
    } on CameraException catch (e) {
      throw PlatformException(code: e.code, message: e.description);
    }
  }

  @override
  Future<FaceRecognitionEntity> recognizeFace(File image) {
    // TODO: implement recognizeFace
    throw UnimplementedError();
  }

  @override
  Future<FaceRecognitionEntity> registerFace(String userId, File image) {
    // TODO: implement registerFace
    throw UnimplementedError();
  }

}