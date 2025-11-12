import '../../domain/entity/register_request_entity.dart';

/// Data layer model for register request.
/// Responsible for (de)serializing JSON and converting to domain entity.
class RegisterRequestModel {
	final String email;
	final String username;
	final String password;

	const RegisterRequestModel({
		required this.email,
		required this.username,
		required this.password,
	});

	factory RegisterRequestModel.fromEntity(RegisterRequestEntity entity) =>
			RegisterRequestModel(
				email: entity.email,
				username: entity.username,
				password: entity.password,
			);

	RegisterRequestEntity toEntity() => RegisterRequestEntity(
				email: email,
				username: username,
				password: password,
			);

	factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
		return RegisterRequestModel(
			email: (json['email'] ?? '').toString(),
			username: (json['username'] ?? json['user_name'] ?? '').toString(),
			password: (json['password'] ?? '').toString(),
		);
	}

	Map<String, dynamic> toJson() => {
				'email': email,
				'username': username,
				'password': password,
			};

	RegisterRequestModel copyWith({
		String? email,
		String? username,
		String? password,
	}) => RegisterRequestModel(
				email: email ?? this.email,
				username: username ?? this.username,
				password: password ?? this.password,
			);

	bool get isValid => email.isNotEmpty && username.isNotEmpty && password.length >= 6;

	@override
	String toString() => 'RegisterRequestModel(email: $email, username: $username)';

	@override
	bool operator ==(Object other) =>
			identical(this, other) ||
			other is RegisterRequestModel &&
					runtimeType == other.runtimeType &&
					email == other.email &&
					username == other.username &&
					password == other.password;

	@override
	int get hashCode => Object.hash(email, username, password);
}
