import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gii_dace_recognition/core/services/services_locator.dart';
import 'package:gii_dace_recognition/features/auth/domain/usecase/face_login_usecase.dart';
import 'package:gii_dace_recognition/features/auth/domain/usecase/face_login_bytes_usecase.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gii_dace_recognition/features/scan_wajah/presentation/cubit/login_camera_cubit.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/cubit/login_camera_state.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/cubit/face_recognition_state.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/widget/face_guide_painter.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/widget/lifecycle_handler.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/widget/shutter_button.dart';
import 'package:gii_dace_recognition/common/bloc/auth/auth_cubit.dart';
import 'package:gii_dace_recognition/common/pages/main_screen.dart'
    as main_screen;
import 'package:gii_dace_recognition/common/bloc/navigation/navigation_cubit.dart'
    as nav;

class ScanLoginPage extends StatelessWidget {
  const ScanLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCameraCubit()..initCamera(),
      child: const _ScanLoginView(),
    );
  }
}

class _ScanLoginView extends StatelessWidget {
  const _ScanLoginView();

  Future<void> _handleCapture(BuildContext context) async {
    final cubit = context.read<LoginCameraCubit>();
    final xfile = await cubit.capture();
    if (xfile == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal mengambil foto')));
      }
      return;
    }

    try {
      dartz.Either<String, Response> res;
      if (kIsWeb) {
        final bytes = await xfile.readAsBytes();
        final name = xfile.name.isNotEmpty ? xfile.name : 'face.jpg';
        res = await sl<FaceLoginBytesUsecase>().call(
          param: {'bytes': bytes, 'filename': name},
        );
      } else {
        res = await sl<FaceLoginUsecase>().call(param: xfile.path);
      }
      if (!context.mounted) return;
      await res.fold(
        (err) async {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Login wajah gagal: $err')));
          }
        },
        (response) async {
          final data = response.data;
          double? matchPercentage;
          if (data is Map && data['match_percentage'] != null) {
            final raw = data['match_percentage'];
            if (raw is num) {
              matchPercentage = raw.toDouble();
            } else {
              matchPercentage = double.tryParse(raw.toString());
            }
          }
          final message = matchPercentage != null
              ? 'Kecocokan wajah: ${matchPercentage.toStringAsFixed(2)}%'
              : 'Login wajah berhasil';
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }

          try {
            await sl<AuthStateCubit>().checkAuthStatus();
          } catch (_) {}

          if (!context.mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const main_screen.MainScreen(
                initialTab: nav.NavigationTab.profil,
              ),
            ),
            (route) => false,
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Scan Wajah', style: TextStyle(color: Colors.white)),
      ),
      body: BlocBuilder<LoginCameraCubit, LoginCameraState>(
        builder: (context, state) {
          return LifecycleHandler(
            onPause: () => context.read<LoginCameraCubit>().disposeController(),
            onResume: () => context.read<LoginCameraCubit>().initCamera(),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (ctx) {
                        if (state.cameraStatus == CameraStatus.loading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state.cameraStatus == CameraStatus.error) {
                          return Center(
                            child: Text(
                              state.errorMessage ?? 'Kamera tidak tersedia',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        final controller = state.controller;
                        if (controller == null ||
                            !controller.value.isInitialized) {
                          return const Center(
                            child: Text(
                              'Kamera tidak tersedia',
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width:
                                    controller.value.previewSize?.height ??
                                    MediaQuery.of(context).size.height,
                                height:
                                    controller.value.previewSize?.width ??
                                    MediaQuery.of(context).size.width,
                                child: CameraPreview(controller),
                              ),
                            ),

                            Align(
                              alignment: Alignment.center,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final double guideWidth =
                                      constraints.maxWidth * 0.78;
                                  final double guideHeight =
                                      constraints.maxHeight * 0.52;
                                  return SizedBox(
                                    width: guideWidth,
                                    height: guideHeight,
                                    child: const CustomPaint(
                                      painter: FaceGuidePainter(
                                        color: Colors.white70,
                                        strokeWidth: 3,
                                        dashLength: 10,
                                        gapLength: 6,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            Positioned(
                              bottom: MediaQuery.of(context).size.height * 0.26,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Arahkan wajah ke dalam lingkaran',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShutterButton(
                          onTap: () async {
                            await _handleCapture(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
