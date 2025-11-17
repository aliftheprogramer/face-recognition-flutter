import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/entity/detected_face_entity.dart';
import '../entity/face_recognition_entity.dart';

abstract class FaceRecognitionRepository {
  Future<Either<String, List<dynamic>>> getAvailableCameras();
  
  Future<Either<String, FaceRecognitionEntity>> recognizeFace(File image);

  Future<Either<String, FaceRecognitionEntity>> registerFace(String userId, File image);

  Future<Either<String, List<DetectedFaceEntity>>> detectFaces(
    CameraImage cameraImage,
  );
}