import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class FaceLoginBytesUsecase
    implements Usecase<Either<String, Response>, Map<String, dynamic>> {
  final AuthRepository repository;

  FaceLoginBytesUsecase(this.repository);

  @override
  Future<Either<String, Response>> call({Map<String, dynamic>? param}) async {
    if (param == null) return Left('Parameter kosong');
    final bytes = param['bytes'] as Uint8List?;
    final filename = param['filename'] as String?;
    if (bytes == null || filename == null || filename.isEmpty) {
      return Left('Bytes/filename tidak valid');
    }
    return repository.faceLoginBytes(bytes, filename);
  }
}
