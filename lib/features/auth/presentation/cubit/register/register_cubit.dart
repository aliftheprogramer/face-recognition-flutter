import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/services_locator.dart';
import '../../../domain/usecase/register_usecase.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
	final RegisterUsecase _registerUsecase;
	RegisterCubit() : _registerUsecase = sl<RegisterUsecase>(), super(const RegisterState());

	void usernameChanged(String v) => emit(state.copyWith(username: v));
	void emailChanged(String v) => emit(state.copyWith(email: v));
	void passwordChanged(String v) => emit(state.copyWith(password: v));
	void confirmPasswordChanged(String v) => emit(state.copyWith(confirmPassword: v));

	Future<void> submit() async {
		if (!state.isValid) {
			emit(state.copyWith(status: RegisterStatus.failure, errorMessage: 'Data tidak valid atau password tidak sama'));
			return;
		}
		emit(state.copyWith(status: RegisterStatus.loading, errorMessage: null));
		final result = await _registerUsecase(param: state.toModel());
		result.fold(
			(err) => emit(state.copyWith(status: RegisterStatus.failure, errorMessage: err.toString())),
			(_) => emit(state.copyWith(status: RegisterStatus.success)),
		);
	}
}
