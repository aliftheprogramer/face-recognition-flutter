import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gii_dace_recognition/common/bloc/auth/auth_cubit.dart';
import 'package:gii_dace_recognition/common/bloc/auth/auth_state.dart';
import 'package:gii_dace_recognition/common/pages/main_screen.dart';
import 'package:gii_dace_recognition/features/auth/presentation/pages/welcome_page.dart';
import 'core/services/services_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AuthStateCubit>()..appStarted()),
        // BlocProvider(create: (context) => sl<NavigationCubit>()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFC2D8FC)),
        ),
        home: BlocBuilder<AuthStateCubit, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              // return StartScan();
              return const MainScreen();
            }
            // Treat FirstRun the same as unauthenticated (show auth page)
            if (state is UnAuthenticated || state is FirstRun) {
              // return AuthPage();
              return const WelcomePage();
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
