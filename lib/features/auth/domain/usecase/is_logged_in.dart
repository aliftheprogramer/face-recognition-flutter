// lib/features/auth/domain/usecase/is_logged_in.dart



import '../../../../core/services/services_locator.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class IsLoggedInUseCase implements Usecase<bool, dynamic> {
  IsLoggedInUseCase(AuthRepository authRepository);

  @override
  Future<bool> call({dynamic param}) async {
    return await sl<AuthRepository>().isLoggedIn();
  }
}
