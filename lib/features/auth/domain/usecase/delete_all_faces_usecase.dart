import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/face_repository.dart';

class DeleteAllFacesUseCase implements Usecase<Either<String, void>, NoParams> {
  final FaceRepository repository;

  DeleteAllFacesUseCase(this.repository);

  @override
  Future<Either<String, void>> call({NoParams? param}) async {
    return await repository.deleteAllFaces();
  }
}
