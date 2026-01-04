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
    try {
      final bool isLoggedIn = await sl<IsLoggedInUseCase>()
          .call(param: NoParams())
          .timeout(const Duration(seconds: 5));
      if (isLoggedIn) {
        emit(Authenticated());
      } else {
        emit(UnAuthenticated());
      }
    } catch (_) {
      // On error or timeout, assume unauthenticated so UI can proceed.
      emit(UnAuthenticated());
    }
  }

  Future<void> appStarted() async {
    // Prevent duplicate initialization if already resolved.
    if (state is! AppInitialState) return;
    try {
      // IMPORTANT: Check if user is logged in FIRST
      // This ensures that users who have a token stay authenticated
      // even if it's their "first run" (e.g., after reinstalling)
      final bool isLoggedIn = await sl<IsLoggedInUseCase>()
          .call(param: NoParams())
          .timeout(const Duration(seconds: 5));

      if (isLoggedIn) {
        // User has a valid token, go to main screen
        emit(Authenticated());
        return;
      }

      // No token found, check if this is first run
      final bool isFirstRun = await sl<IsFirstRunUsecase>()
          .call(param: NoParams())
          .timeout(const Duration(seconds: 5));

      if (isFirstRun) {
        emit(FirstRun());
      } else {
        emit(UnAuthenticated());
      }
    } catch (_) {
      // Fallback: treat as unauthenticated if anything fails.
      emit(UnAuthenticated());
    }
  }

  Future<void> finishWelcomeScreen() async {
    try {
      await sl<SetFirstRunCompleteUsecase>()
          .call(param: NoParams())
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Ignore errors; continue to auth status check.
    }
    await checkAuthStatus();
  }
}
