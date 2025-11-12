// lib/core/services/services_locator.dart

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart'; // <-- Ditambahkan
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../../features/auth/data/repository_impl/auth_repository_impl.dart';
import '../../features/auth/data/source/auth_api_service.dart';
import '../../features/auth/data/source/auth_local_service.dart';
import '../../features/auth/domain/repository/auth_repository.dart';
import '../../features/auth/domain/usecase/register_usecase.dart';
import '../../features/auth/domain/usecase/signin_usecases.dart';
import '../../features/auth/domain/usecase/is_logged_in.dart';
import '../../features/auth/domain/usecase/is_first_run_usecase.dart';
import '../../features/auth/domain/usecase/set_first_run_complete_usecase.dart';

final sl = GetIt.instance;

Future<void> setUpServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton(() => Logger()); // <-- DITAMBAHKAN: Registrasi Logger

  // Auth data sources
  sl.registerLazySingleton(() => AuthLocalService(sl()));
  sl.registerLazySingleton(() => AuthApiService(sl(), sl()));

  // Auth repository
  sl.registerLazySingleton<AuthRepository>(() =>
      AuthRepositoryImpl(api: sl(), local: sl(), logger: sl()));

  // Auth usecases
  sl.registerLazySingleton(() => SigninUsecases(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => IsLoggedInUseCase(sl()));
  sl.registerLazySingleton(() => IsFirstRunUsecase(sl()));
  sl.registerLazySingleton(() => SetFirstRunCompleteUsecase(sl()));
}