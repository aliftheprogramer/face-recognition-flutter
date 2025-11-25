import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:gii_dace_recognition/core/usecase/usecase.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/entity/face_recognition_entity.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/repository/face_recognition_repository.dart';

class RegisterFaceUsecase
    implements
        Usecase<Either<String, FaceRecognitionEntity>, Map<String, dynamic>> {
  final FaceRecognitionRepository repository;

  RegisterFaceUsecase(this.repository);

  @override
  Future<Either<String, FaceRecognitionEntity>> call({
    Map<String, dynamic>? param,
  }) async {
    final userId = param?['userId'] as String?;
    final file = param?['file'] as File?;
    if (userId == null || file == null) {
      return Left('Invalid parameters');
    }
    return await repository.registerFace(userId, file);
  }
}
