import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../domain/repository/auth_repository.dart';
import '../model/login_request_model.dart';
import '../model/register_request_model.dart';
import '../source/auth_api_service.dart';
import '../source/auth_local_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService api;
  final AuthLocalService local;
  final Logger logger;

  AuthRepositoryImpl({
    required this.api,
    required this.local,
    required this.logger,
  });

  @override
  Future<bool> isFirstRun() async {
    return await local.isFirstRun();
  }

  @override
  Future<void> setFirstRunComplete() async {
    await local.setFirstRunComplete();
  }

  @override
  Future<Either<String, Response>> signIn(
    LoginRequestModel loginRequestModel,
  ) async {
    try {
      final res = await api.signIn(loginRequestModel);
      // Extract token from response and persist locally for future sessions.
      String? token;
      final data = res.data;
      if (data is Map) {
        // Common patterns: {token: x}, {access_token: x}, {data: {token: x}}, etc.
        final map = data;
        final nestedData = map['data'];
        if (map['token'] is String) {
          token = map['token'];
        } else if (map['access_token'] is String) {
          token = map['access_token'];
        } else if (nestedData is Map) {
          if (nestedData['token'] is String) {
            token = nestedData['token'];
          } else if (nestedData['access_token'] is String) {
            token = nestedData['access_token'];
          }
        }
      }
      if (token != null && token.isNotEmpty) {
        await local.saveToken(token);
        logger.i('[Repo] Token saved');
      } else {
        logger.w('[Repo] Token not found in login response');
      }
      return Right(res);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Login failed';
      logger.e('[Repo] signIn error: $msg');
      return Left(msg);
    } catch (e) {
      logger.e('[Repo] signIn unexpected error', error: e);
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Response>> register(
    RegisterRequestModel registerRequestModel,
  ) async {
    try {
      final res = await api.register(registerRequestModel);
      return Right(res);
    } on DioException catch (e) {
      final msg =
          e.response?.data?.toString() ?? e.message ?? 'Register failed';
      logger.e('[Repo] register error: $msg');
      return Left(msg);
    } catch (e) {
      logger.e('[Repo] register unexpected error', error: e);
      return Left(e.toString());
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await local.isLoggedIn();
  }
}
