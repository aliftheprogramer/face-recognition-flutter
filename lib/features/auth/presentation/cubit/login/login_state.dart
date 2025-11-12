import 'package:equatable/equatable.dart';
import '../../../data/model/login_request_model.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
	final String email;
	final String password;
	final LoginStatus status;
	final String? errorMessage;

	const LoginState({
		this.email = '',
		this.password = '',
		this.status = LoginStatus.initial,
		this.errorMessage,
	});

	LoginState copyWith({
		String? email,
		String? password,
		LoginStatus? status,
		String? errorMessage,
	}) {
		return LoginState(
			email: email ?? this.email,
			password: password ?? this.password,
			status: status ?? this.status,
			errorMessage: errorMessage,
		);
	}

	bool get isValid => email.isNotEmpty && password.length >= 6;
	LoginRequestModel toModel() => LoginRequestModel(email: email, password: password);

	@override
	List<Object?> get props => [email, password, status, errorMessage];
}
