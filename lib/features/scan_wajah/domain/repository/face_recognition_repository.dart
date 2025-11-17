import 'dart:io';
import 'package:dartz/dartz.dart';
import '../entity/face_recognition_entity.dart';

abstract class FaceRecognitionRepository {
  Future<Either<String, List<dynamic>>> getAvailableCameras();
  
  Future<Either<String, FaceRecognitionEntity>> recognizeFace(File image);

  Future<Either<String, FaceRecognitionEntity>> registerFace(String userId, File image);
}