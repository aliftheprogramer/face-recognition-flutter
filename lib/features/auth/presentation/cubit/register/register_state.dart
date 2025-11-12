import 'package:equatable/equatable.dart';
import '../../../data/model/register_request_model.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
	final String username;
	final String email;
	final String password;
	final String confirmPassword;
	final RegisterStatus status;
	final String? errorMessage;

	const RegisterState({
		this.username = '',
		this.email = '',
		this.password = '',
		this.confirmPassword = '',
		this.status = RegisterStatus.initial,
		this.errorMessage,
	});

	RegisterState copyWith({
		String? username,
		String? email,
		String? password,
		String? confirmPassword,
		RegisterStatus? status,
		String? errorMessage,
	}) {
		return RegisterState(
			username: username ?? this.username,
			email: email ?? this.email,
			password: password ?? this.password,
			confirmPassword: confirmPassword ?? this.confirmPassword,
			status: status ?? this.status,
			errorMessage: errorMessage,
		);
	}

	bool get isValid => username.isNotEmpty && email.isNotEmpty && password.length >= 6 && password == confirmPassword;
	RegisterRequestModel toModel() => RegisterRequestModel(email: email, username: username, password: password);

	@override
	List<Object?> get props => [username, email, password, confirmPassword, status, errorMessage];
}
