import 'package:dartz/dartz.dart';
import 'package:gii_dace_recognition/core/usecase/usecase.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/repository/face_recognition_repository.dart';

class GetAvailableCamerasUsecase implements Usecase<Either, NoParams> {
  final FaceRecognitionRepository repository;

  GetAvailableCamerasUsecase(this.repository);
  
  @override
  Future<Either<dynamic, dynamic>> call({NoParams? param}) async {
    return await repository.getAvailableCameras();
  }

}