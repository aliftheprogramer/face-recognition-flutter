import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/services_locator.dart';
import '../../../core/usecase/usecase.dart';
import '../../../features/auth/domain/usecase/is_first_run_usecase.dart';
import '../../../features/auth/domain/usecase/is_logged_in.dart';
import '../../../features/auth/domain/usecase/set_first_run_complete_usecase.dart';
import 'auth_state.dart';

class AuthStateCubit extends Cubit<AuthState> {
  AuthStateCubit() : super(AppInitialState());

  Future<void> checkAuthStatus() async {
    final bool isLoggedIn = await sl<IsLoggedInUseCase>().call(param: NoParams());
    if (isLoggedIn) {
      emit(Authenticated());
    } else {
      emit(UnAuthenticated());
    }
  }

  void appStarted() async {
    final bool isFirstRun = await sl<IsFirstRunUsecase>().call(param: NoParams());
    
    if (isFirstRun) {
      emit(FirstRun());
    } else {
      await checkAuthStatus();
    }
  }

  void finishWelcomeScreen() async {
    await sl<SetFirstRunCompleteUsecase>().call(param: NoParams());
    await checkAuthStatus();
  }
}