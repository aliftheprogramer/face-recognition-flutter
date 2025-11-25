import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/constant/api_urls.dart';
import '../../../../core/network/dio_client.dart';
import '../../../scan_wajah/domain/entity/face_recognition_entity.dart';

abstract class FaceRecognitionRemoteDataSource {
  Future<FaceRecognitionEntity> registerFace(String userId, File image);
}

class FaceRecognitionRemoteDataSourceImpl
    implements FaceRecognitionRemoteDataSource {
  final DioClient client;
  final Logger logger;

  FaceRecognitionRemoteDataSourceImpl({
    required this.client,
    required this.logger,
  });

  @override
  Future<FaceRecognitionEntity> registerFace(String userId, File image) async {
    try {
      final fileName = image.path.split(Platform.pathSeparator).last;
      final form = FormData.fromMap({
        'file': MultipartFile.fromFileSync(image.path, filename: fileName),
        'user_id': userId,
      });

      logger.i('[API] Upload face to ${ApiUrls.uploadFace}');

      final res = await client.post(
        ApiUrls.uploadFace,
        data: form,
        // ensure multipart content header is set by Dio when sending FormData
      );

      final data = res.data;

      // Tolerant parsing — try to extract useful info if present
      if (data is Map) {
        final nested = data['data'] ?? data;
        if (nested is Map) {
          final uid =
              nested['user_id']?.toString() ??
              nested['id']?.toString() ??
              userId;
          final name =
              nested['name']?.toString() ??
              nested['user_name']?.toString() ??
              'User';
          final confidence = (nested['confidence'] is num)
              ? (nested['confidence'] as num).toDouble()
              : 1.0;
          return FaceRecognitionEntity(
            userId: uid,
            userName: name,
            confidence: confidence,
          );
        }
      }

      // fallback: return registration success entity
      return FaceRecognitionEntity.registrationSuccess();
    } on DioException catch (e) {
      logger.e('[RemoteDataSource] registerFace error: ${e.message}');
      rethrow;
    }
  }
}
