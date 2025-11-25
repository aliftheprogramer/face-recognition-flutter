// lib/core/services/services_locator.dart

import 'package:get_it/get_it.dart';
import 'package:gii_dace_recognition/features/scan_wajah/data/repository_impl/face_recognition_repository_impl.dart';
import 'package:gii_dace_recognition/features/scan_wajah/data/source/face_recognition_local_data_source.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/repository/face_recognition_repository.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/usecase/detect_face_usecase.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/usecase/get_available_cameras_usecase.dart';
import 'package:gii_dace_recognition/features/scan_wajah/domain/usecase/recognize_face_usecase.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/cubit/face_recognition_cubit.dart';
import 'package:logger/logger.dart'; // <-- Ditambahkan
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../../features/auth/data/repository_impl/auth_repository_impl.dart';
import '../../features/auth/data/source/auth_api_service.dart';
import '../../features/auth/data/source/auth_local_service.dart';
import '../../features/auth/domain/repository/auth_repository.dart';
import '../../features/auth/domain/usecase/register_usecase.dart';
import '../../features/auth/domain/usecase/signin_usecases.dart';
import '../../features/auth/domain/usecase/logout_usecase.dart';
import '../../features/auth/domain/usecase/is_logged_in.dart';
import '../../features/auth/domain/usecase/is_first_run_usecase.dart';
import '../../features/auth/domain/usecase/set_first_run_complete_usecase.dart';
import '../../common/bloc/auth/auth_cubit.dart';
import '../../features/scan_wajah/data/source/face_recognition_remote_data_source.dart';
import '../../features/scan_wajah/domain/usecase/register_face_usecase.dart';

final sl = GetIt.instance;

Future<void> setUpServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton(() => Logger());

  // Auth data sources
  sl.registerLazySingleton(() => AuthLocalService(sl()));
  sl.registerLazySingleton(() => AuthApiService(sl(), sl()));

  // Auth repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(api: sl(), local: sl(), logger: sl()),
  );

  // Auth usecases
  sl.registerLazySingleton(() => SigninUsecases(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => IsLoggedInUseCase(sl()));
  sl.registerLazySingleton(() => IsFirstRunUsecase(sl()));
  sl.registerLazySingleton(() => SetFirstRunCompleteUsecase(sl()));

  // App-level cubits / blocs
  sl.registerLazySingleton(() => AuthStateCubit());
  // Face recognition: local + remote data sources
  sl.registerLazySingleton<FaceRecognitionLocalDataSource>(
    () => FaceRecognitionLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<FaceRecognitionRemoteDataSource>(
    () => FaceRecognitionRemoteDataSourceImpl(client: sl(), logger: sl()),
  );

  sl.registerLazySingleton<FaceRecognitionRepository>(
    () => FaceRecognitionRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      logger: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetAvailableCamerasUsecase(sl()));
  sl.registerLazySingleton(() => RecognizeFaceUsecase(sl()));
  sl.registerLazySingleton(() => RegisterFaceUsecase(sl()));
  sl.registerFactory(() => FaceRecognitionCubit());
  sl.registerLazySingleton(() => DetectFacesUsecase(sl()));
}
