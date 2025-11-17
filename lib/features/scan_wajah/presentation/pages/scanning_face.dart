import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../cubit/face_recognition_cubit.dart';
import '../cubit/face_recognition_state.dart';

class ScanningFacePage extends StatelessWidget {
  const ScanningFacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FaceRecognitionCubit()..initCamera(),
      child: const _ScanningFaceView(),
    );
  }
}

class _ScanningFaceView extends StatefulWidget {
  const _ScanningFaceView();

  @override
  State<_ScanningFaceView> createState() => _ScanningFaceViewState();
}

class _ScanningFaceViewState extends State<_ScanningFaceView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<FaceRecognitionCubit>().disposeController();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<FaceRecognitionCubit>();
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      cubit.disposeController();
    } else if (state == AppLifecycleState.resumed) {
      cubit.initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            Expanded(
              child: Center(
                child: BlocBuilder<FaceRecognitionCubit, FaceRecognitionState>(
                  builder: (context, state) {
                    switch (state.cameraStatus) {
                      case CameraStatus.initial:
                      case CameraStatus.loading:
                        // Tanpa loading indicator, biarkan kosong
                        return const SizedBox.shrink();
                      case CameraStatus.error:
                        return Center(
                          child: Text(
                            state.errorMessage ?? 'Gagal memuat kamera',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      case CameraStatus.ready:
                        final controller = state.controller!;
                        return AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: CameraPreview(controller),
                        );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
