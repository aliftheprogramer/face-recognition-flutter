import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../../../core/constant/api_urls.dart';
import '../../../../core/network/dio_client.dart';
import '../model/login_request_model.dart';
import '../model/register_request_model.dart';

class AuthApiService {
  final DioClient _client;
  final Logger _logger;

  AuthApiService(this._client, this._logger);

  Future<Response> signIn(LoginRequestModel request) async {
    try {
      _logger.i('[API] POST ${ApiUrls.login}');
      return await _client.post(ApiUrls.login, data: request.toMap());
    } on DioException catch (e) {
      _logger.e('[API] Login failed', error: e, stackTrace: e.stackTrace);
      rethrow;
    }
  }

  Future<Response> register(RegisterRequestModel request) async {
    try {
      _logger.i('[API] POST ${ApiUrls.register}');
      return await _client.post(ApiUrls.register, data: request.toJson());
    } on DioException catch (e) {
      _logger.e('[API] Register failed', error: e, stackTrace: e.stackTrace);
      rethrow;
    }
  }

  Future<Response> getProfile() async {
    try {
      _logger.i('[API] GET ${ApiUrls.baseUrl}/user/my-profile');
      return await _client.get('${ApiUrls.baseUrl}/user/my-profile');
    } on DioException catch (e) {
      _logger.e('[API] getProfile failed', error: e, stackTrace: e.stackTrace);
      rethrow;
    }
  }

  Future<Response> logout() async {
    try {
      _logger.i('[API] POST ${ApiUrls.baseUrl}/auth/logout');
      return await _client.post('${ApiUrls.baseUrl}/auth/logout');
    } on DioException catch (e) {
      _logger.e('[API] logout failed', error: e, stackTrace: e.stackTrace);
      rethrow;
    }
  }

  Future<Response> faceLogin(String filePath) async {
    try {
      _logger.i('[API] POST ${ApiUrls.baseUrl}/auth/face-login');
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      return await _client.post(
        '${ApiUrls.baseUrl}/auth/face-login',
        data: formData,
      );
    } on DioException catch (e) {
      _logger.e('[API] faceLogin failed', error: e, stackTrace: e.stackTrace);
      rethrow;
    }
  }

  Future<Response> faceLoginBytes(Uint8List bytes, String filename) async {
    try {
      _logger.i('[API] POST ${ApiUrls.baseUrl}/auth/face-login (bytes)');
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      return await _client.post(
        '${ApiUrls.baseUrl}/auth/face-login',
        data: formData,
      );
    } on DioException catch (e) {
      _logger.e(
        '[API] faceLoginBytes failed',
        error: e,
        stackTrace: e.stackTrace,
      );
      rethrow;
    }
  }
}
