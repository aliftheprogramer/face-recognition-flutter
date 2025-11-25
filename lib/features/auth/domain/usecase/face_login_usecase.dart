import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class FaceLoginUsecase implements Usecase<Either<String, Response>, String> {
  final AuthRepository repository;

  FaceLoginUsecase(this.repository);

  @override
  Future<Either<String, Response>> call({String? param}) async {
    if (param == null || param.isEmpty) {
      return Left('Path file tidak boleh kosong');
    }
    return repository.faceLogin(param);
  }
}
