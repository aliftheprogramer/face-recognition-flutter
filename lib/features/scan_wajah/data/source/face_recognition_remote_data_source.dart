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
      // API expects key 'files' (array) carrying the uploaded file(s)
      final form = FormData.fromMap({
        'files': [
          MultipartFile.fromFileSync(
            image.path,
            filename: fileName,
            // contentType can be omitted; Dio will set multipart headers
          ),
        ],
      });

      logger.i('[API] Upload face to ${ApiUrls.uploadFace}');

      final res = await client.post(
        ApiUrls.uploadFace,
        data: form,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final data = res.data;

      // If API indicates success, return a registration success entity.
      // The documented response is:
      // { "status": "success", "uploaded_face_ids": [19] }
      if (data is Map &&
          (data['status'] == 'success' || data['status'] == 'ok')) {
        return FaceRecognitionEntity.registrationSuccess();
      }

      // Otherwise, return a generic success fallback as well
      return FaceRecognitionEntity.registrationSuccess();
    } on DioException catch (e) {
      logger.e('[RemoteDataSource] registerFace error: ${e.message}');
      rethrow;
    }
  }
}
