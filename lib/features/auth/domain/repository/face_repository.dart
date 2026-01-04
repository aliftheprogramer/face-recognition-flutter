import 'package:dartz/dartz.dart';
import '../entity/face_entity.dart';

abstract class FaceRepository {
  Future<Either<String, List<FaceEntity>>> getMyFaces();
  Future<Either<String, void>> deleteAllFaces();
}
