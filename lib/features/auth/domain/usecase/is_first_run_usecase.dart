//  lib/features/welcome/domain/usecase/is_first_run_usecase.dart





import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class IsFirstRunUsecase implements Usecase<bool, NoParams> {
  final AuthRepository repository;

  IsFirstRunUsecase(this.repository);
  @override
  Future<bool> call({NoParams? param}) async {
    return await repository.isFirstRun();
  }
}