import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:gii_dace_recognition/core/usecase/usecase.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/entity/face_recognition_entity.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/repository/face_recognition_repository.dart';

class RegisterFaceBytesUsecase
    implements
        Usecase<Either<String, FaceRecognitionEntity>, Map<String, dynamic>> {
  final FaceRecognitionRepository repository;

  RegisterFaceBytesUsecase(this.repository);

  @override
  Future<Either<String, FaceRecognitionEntity>> call({
    Map<String, dynamic>? param,
  }) async {
    final userId = param?['userId'] as String?;
    final bytes = param?['bytes'] as Uint8List?;
    final filename = param?['filename'] as String?;
    if (userId == null ||
        bytes == null ||
        filename == null ||
        filename.isEmpty) {
      return Left('Invalid parameters');
    }
    return await repository.registerFaceBytes(userId, bytes, filename);
  }
}
