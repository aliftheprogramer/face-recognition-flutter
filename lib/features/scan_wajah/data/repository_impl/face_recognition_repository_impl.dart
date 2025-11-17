import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:gii_dace_recognition/features/scan_wajah/data/source/face_recognition_local_data_source.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/entity/detected_face_entity.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/entity/face_recognition_entity.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/repository/face_recognition_repository.dart';
import 'package:logger/logger.dart';

class FaceRecognitionRepositoryImpl implements FaceRecognitionRepository {
  final FaceRecognitionLocalDataSource localDataSource;
  final Logger logger;

  FaceRecognitionRepositoryImpl({
    required this.localDataSource,
    required this.logger,
  });

  @override
  Future<Either<String, List<dynamic>>> getAvailableCameras() async {
    try {
      final cameras = await localDataSource.getAvailableCameras();
      return Right(cameras);
    } on Exception catch (e) {
      logger.e('[Repo] Get Cameras error: $e');
      return Left('Gagal mendapatkan kamera: $e');
    }
  }

  @override
  Future<Either<String, List<DetectedFaceEntity>>> detectFaces(
    CameraImage cameraImage,
  ) async {
    try {
      final faces = await localDataSource.detectFaces(cameraImage);
      return Right(faces);
    } on Exception catch (e) {
      logger.e('[Repo] Detect Faces error: $e');
      return Left('Gagal mendeteksi wajah: $e');
    }
  }

  @override
  Future<Either<String, FaceRecognitionEntity>> recognizeFace(
    File image,
  ) async {
    try {
      final result = await localDataSource.recognizeFace(image);
      return Right(result);
    } on Exception catch (e) {
      logger.e('[Repo] Recognize Face error: $e');
      return Left('Gagal mengenali wajah: $e');
    }
  }

  @override
  Future<Either<String, FaceRecognitionEntity>> registerFace(
    String userId,
    File image,
  ) async {
    try {
      final result = await localDataSource.registerFace(userId, image);
      return Right(result);
    } on Exception catch (e) {
      logger.e('[Repo] Register Face error: $e');
      return Left('Gagal mendaftarkan wajah: $e');
    }
  }
}
