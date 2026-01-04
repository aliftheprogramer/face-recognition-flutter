import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../domain/entity/face_entity.dart';
import '../../domain/repository/face_repository.dart';
import '../model/face_model.dart';
import '../source/auth_api_service.dart';

class FaceRepositoryImpl implements FaceRepository {
  final AuthApiService api;
  final Logger logger;

  FaceRepositoryImpl({required this.api, required this.logger});

  @override
  Future<Either<String, List<FaceEntity>>> getMyFaces() async {
    try {
      logger.i('[FaceRepo] Fetching user faces from profile...');
      // Use getProfile instead of getMyFaces API since it returns faces array
      // and the /face endpoint has authentication issues
      final res = await api.getProfile();

      final data = res.data;
      if (data is Map) {
        final facesData = data['faces'];
        if (facesData is List) {
          final faces = facesData
              .map((json) => FaceModel.fromJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();

          logger.i(
            '[FaceRepo] Successfully fetched ${faces.length} faces from profile',
          );
          return Right(faces);
        } else {
          logger.w('[FaceRepo] No faces array in profile response');
          return const Right([]); // Return empty list if no faces
        }
      } else {
        logger.w('[FaceRepo] Unexpected response format: $data');
        return const Left('Invalid response format');
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?.toString() ?? e.message ?? 'Failed to fetch faces';
      logger.e('[FaceRepo] getMyFaces error: $msg');
      return Left(msg);
    } catch (e) {
      logger.e('[FaceRepo] getMyFaces unexpected error', error: e);
      return Left(e.toString());
    }
  }
}
