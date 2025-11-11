// lib/common/bloc/auth/auth_state.dart

abstract class AuthState {}

class AppInitialState extends AuthState {}

class Authenticated extends AuthState {}

class UnAuthenticated extends AuthState {}

class FirstRun extends AuthState {}
