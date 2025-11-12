// lib/features/welcome/domain/usecase/set_first_run_complete_usecase.dart


import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class SetFirstRunCompleteUsecase implements Usecase<void, NoParams> {
  final AuthRepository repository;

  SetFirstRunCompleteUsecase(this.repository);


  @override
  Future<void> call({NoParams? param}) async { 
    return await repository.setFirstRunComplete();
  }
}