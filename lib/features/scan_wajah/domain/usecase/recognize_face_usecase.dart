import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:gii_dace_recognition/core/usecase/usecase.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/entity/face_recognition_entity.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/repository/face_recognition_repository.dart';

class RecognizeFaceUsecase implements Usecase<Either<String, FaceRecognitionEntity>, File>{
  final FaceRecognitionRepository repository;
  RecognizeFaceUsecase(this.repository);
  
  @override
  Future<Either<String, FaceRecognitionEntity>> call({File? param}) async{
    return await repository.recognizeFace(param!);
  }
}