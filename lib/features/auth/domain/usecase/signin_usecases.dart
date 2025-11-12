// lib/features/auth/domain/usecase/signin_usecases.dart

import 'package:dartz/dartz.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/model/login_request_model.dart';
import '../repository/auth_repository.dart';

class SigninUsecases implements Usecase<Either, LoginRequestModel> {
  SigninUsecases(AuthRepository authRepository);

  @override
  Future<Either> call({LoginRequestModel? param}) async {
    return sl<AuthRepository>().signIn(param!);
  }

}
