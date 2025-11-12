// lib/features/auth/domain/usecase/register_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/model/register_request_model.dart';
import '../repository/auth_repository.dart';

class RegisterUsecase implements Usecase<Either, RegisterRequestModel> {
  RegisterUsecase(AuthRepository authRepository);

  @override
  Future<Either> call({RegisterRequestModel? param}) async {
    return sl<AuthRepository>().register(param!);
  }
}
