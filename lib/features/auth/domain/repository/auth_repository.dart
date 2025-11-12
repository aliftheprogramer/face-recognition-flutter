import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../data/model/login_request_model.dart';

abstract class AuthRepository {
  Future<bool> isFirstRun();
  Future<void> setFirstRunComplete();
  Future<Either<String, Response>> signIn(LoginRequestModel loginRequestModel);
  Future<bool> isLoggedIn();
}
