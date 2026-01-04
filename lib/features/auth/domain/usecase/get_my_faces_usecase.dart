import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/face_entity.dart';
import '../repository/face_repository.dart';

class GetMyFacesUseCase
    implements Usecase<Either<String, List<FaceEntity>>, NoParams> {
  final FaceRepository repository;

  GetMyFacesUseCase(this.repository);

  @override
  Future<Either<String, List<FaceEntity>>> call({NoParams? param}) async {
    return await repository.getMyFaces();
  }
}
