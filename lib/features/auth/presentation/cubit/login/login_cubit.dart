import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/services_locator.dart';
import '../../../data/model/login_request_model.dart';
import '../../../domain/usecase/signin_usecases.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
	final SigninUsecases _signinUsecases;

	LoginCubit() : _signinUsecases = sl<SigninUsecases>(), super(const LoginState());

	void emailChanged(String value) => emit(state.copyWith(email: value));
	void passwordChanged(String value) => emit(state.copyWith(password: value));

	Future<void> submit() async {
		if (!state.isValid) {
			emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'Email atau password tidak valid'));
			return;
		}
		emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));
		final result = await _signinUsecases(param: LoginRequestModel(email: state.email, password: state.password));
		result.fold(
			(err) => emit(state.copyWith(status: LoginStatus.failure, errorMessage: err.toString())),
			(_) => emit(state.copyWith(status: LoginStatus.success, errorMessage: null)),
		);
	}
}
