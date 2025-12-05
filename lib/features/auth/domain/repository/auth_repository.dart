import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';

import '../../data/model/login_request_model.dart';
import '../../data/model/register_request_model.dart';

abstract class AuthRepository {
  Future<bool> isFirstRun();
  Future<void> setFirstRunComplete();
  Future<Either<String, Response>> signIn(LoginRequestModel loginRequestModel);
  Future<Either<String, Response>> register(
    RegisterRequestModel registerRequestModel,
  );
  Future<bool> isLoggedIn();
  Future<Either<String, Response>> logout();
  Future<Either<String, Response>> faceLogin(String filePath);
  Future<Either<String, Response>> faceLoginBytes(
    Uint8List bytes,
    String filename,
  );
}
