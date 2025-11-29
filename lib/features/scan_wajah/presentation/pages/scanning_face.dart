import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/cubit/face_recognition_state.dart';
import '../cubit/face_recognition_cubit.dart';
import 'scan_result.dart';
import 'package:gii_dace_recognition/core/services/services_locator.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/widget/circle_icon_button.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/widget/shutter_button.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/widget/face_guide_painter.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/widget/lifecycle_handler.dart';

class ScanningFacePage extends StatelessWidget {
  const ScanningFacePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Log creation and camera init
    sl<Logger>().i('ScanningFacePage: build - creating FaceRecognitionCubit');
    return BlocProvider(
      create: (context) {
        sl<Logger>().i(
          'ScanningFacePage: creating FaceRecognitionCubit and calling initCamera',
        );
        final cubit = FaceRecognitionCubit();
        cubit.initCamera();
        return cubit;
      },
      child: const _ScanningFaceView(),
    );
  }
}

class _ScanningFaceView extends StatelessWidget {
  const _ScanningFaceView();

  @override
  Widget build(BuildContext context) {
    final logger = sl<Logger>();
    return LifecycleHandler(
      onDispose: () {
        logger.i('ScanningFaceView: dispose - disposing controller via cubit');
        try {
          context.read<FaceRecognitionCubit>().disposeController();
        } catch (_) {}
      },
      onResume: () {
        logger.i('ScanningFaceView: resumed - re-initializing camera');
        context.read<FaceRecognitionCubit>().initCamera();
      },
      onPause: () {
        logger.i('ScanningFaceView: paused - disposing camera controller');
        context.read<FaceRecognitionCubit>().disposeController();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<FaceRecognitionCubit, FaceRecognitionState>(
          builder: (context, state) {
            switch (state.cameraStatus) {
              case CameraStatus.initial:
              case CameraStatus.loading:
                logger.i('CameraStatus: loading');
                return const SizedBox.expand();
              case CameraStatus.error:
                return Center(
                  child: Text(
                    state.errorMessage ?? 'Gagal memuat kamera',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              case CameraStatus.ready:
                logger.i('CameraStatus: ready');
                final controllerReady = state.controller;
                if (controllerReady == null) {
                  // Try to re-initialize the camera when controller is unexpectedly null.
                  Future.microtask(
                    () => context.read<FaceRecognitionCubit>().initCamera(),
                  );
                  return const Center(child: CircularProgressIndicator());
                }
                final controller = controllerReady;
                final previewSize = controller.value.previewSize;
                return _CameraView(
                  controller: controller,
                  previewSize: previewSize,
                );
            }
          },
        ),
      ),
    );
  }
}

// using shared LifecycleHandler from presentation/widget/lifecycle_handler.dart

class _CameraView extends StatelessWidget {
  final CameraController controller;
  final Size? previewSize;

  const _CameraView({required this.controller, required this.previewSize});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FaceRecognitionCubit>();
    final _logger = sl<Logger>();
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewSize?.height ?? MediaQuery.of(context).size.height,
            height: previewSize?.width ?? MediaQuery.of(context).size.width,
            child: CameraPreview(controller),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: CircleIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.18,
          left: 0,
          right: 0,
          child: const Center(
            child: Text(
              'Posisi wajah lurus kedepan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double guideWidth = constraints.maxWidth * 0.78;
              final double guideHeight = constraints.maxHeight * 0.52;
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
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.45)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleIconButton(
                  icon: Icons.flash_on,
                  onTap: () => cubit.toggleFlash(),
                ),
                ShutterButton(
                  onTap: () async {
                    _logger.i('Shutter pressed - capturing image');
                    try {
                      final xfile = await cubit.captureAndSave();
                      if (xfile == null) {
                        _logger.w('Capture failed - returned null XFile');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal mengambil gambar'),
                          ),
                        );
                        return;
                      }
                      _logger.i('Capture saved: ${xfile.path}');
                      final files = cubit.state.captures;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ScanResultPage(files: files),
                        ),
                      );
                    } catch (e, st) {
                      _logger.e('Exception during capture: $e\n$st');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal mengambil gambar')),
                      );
                    }
                  },
                ),
                CircleIconButton(
                  icon: Icons.cameraswitch,
                  onTap: () {
                    _logger.i('Camera switch requested');
                    cubit.switchCamera();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
