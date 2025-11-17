import 'package:dartz/dartz.dart';
import 'package:camera/camera.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/detected_face_entity.dart';
import '../repository/face_recognition_repository.dart';

class DetectFacesUsecase
    implements Usecase<Either<String, List<DetectedFaceEntity>>, CameraImage> {
  final FaceRecognitionRepository repository;

  DetectFacesUsecase(this.repository);

  @override
  Future<Either<String, List<DetectedFaceEntity>>> call({
    CameraImage? param,
  }) async {
    return await repository.detectFaces(param!);
  }
}
