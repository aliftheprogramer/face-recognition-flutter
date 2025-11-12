import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/bloc/auth/auth_cubit.dart';
import '../services/services_locator.dart';

/// This interceptor is used to show request and response logs
class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';
    logger.e('${options.method} request ==> $requestPath'); //Error log
    logger.d(
      'Error type: ${err.error} \n '
      'Error message: ${err.message}'
      'SERVER RESPONSE: ${err.response?.data}',
    ); //Debug log
    handler.next(err); //Continue with the Error
    if (err.response?.statusCode == 401) {
      logger.w('Unauthorized request detected. Redirecting to login.');
      sl<AuthStateCubit>()
          .appStarted(); // Trigger appStarted to check login state
    } else {
      logger.w('An error occurred: ${err.message}');
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Ambil SharedPreferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // 2. Cek apakah token ada. Support both 'token' and 'access_token' keys for compatibility.
    String? token;
    if (sharedPreferences.containsKey('token')) {
      token = sharedPreferences.getString('token');
    } else if (sharedPreferences.containsKey('access_token')) {
      token = sharedPreferences.getString('access_token');
    }

    if (token != null && token.isNotEmpty) {
      // 3. Tambahkan header Authorization jika token tersedia
      options.headers['Authorization'] = 'Bearer $token';
    }

    final requestPath = '${options.baseUrl}${options.path}';
    logger.i('${options.method} request ==> $requestPath');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d(
      'STATUSCODE: ${response.statusCode} \n '
      'STATUSMESSAGE: ${response.statusMessage} \n'
      'HEADERS: ${response.headers} \n'
      'Data: ${response.data}',
    ); // Debug log
    handler.next(response); // continue with the Response
  }
}
