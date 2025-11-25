import 'package:dartz/dartz.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class LogoutUsecase implements Usecase<Either, dynamic> {
  LogoutUsecase(AuthRepository authRepository);

  @override
  Future<Either> call({param}) async {
    return sl<AuthRepository>().logout();
  }
}
