// lib/core/services/services_locator.dart

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart'; // <-- Ditambahkan
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';

final sl = GetIt.instance;

Future<void> setUpServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton(() => Logger()); // <-- DITAMBAHKAN: Registrasi Logger

}