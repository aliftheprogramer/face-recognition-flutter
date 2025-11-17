import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../../../../widget/primary_button.dart';
import '../../domain/entity/detected_face_entity.dart'; // Import entitas deteksi wajah
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: _TopBar(),
            ),

            Expanded(
              child: Center(
                child: BlocConsumer<FaceRecognitionCubit, FaceRecognitionState>(
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!)),
                      );
                    }
                    if (state.recognitionStatus == RecognitionStatus.success &&
                        state.result != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Wajah dikenali: ${state.result!.userName}',
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    switch (state.cameraStatus) {
                      case CameraStatus.initial:
                      case CameraStatus.loading:
                        return const Center(child: CircularProgressIndicator());
                      case CameraStatus.error:
                        return Center(
                          child: Text(
                            state.errorMessage ?? 'Gagal memuat kamera',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      case CameraStatus.ready:
                        final controller = state.controller!;
                        final aspect = controller.value.aspectRatio;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Kamera Preview
                            Transform.scale(
                              scale:
                                  controller.value.aspectRatio /
                                  (MediaQuery.of(context).size.width /
                                      (MediaQuery.of(context).size.height *
                                          0.7)),
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: controller.value.aspectRatio,
                                  child: CameraPreview(controller),
                                ),
                              ),
                            ),
                            // Overlay deteksi wajah
                            CustomPaint(
                              painter: FaceDetectorPainter(
                                detectedFaces: state.detectedFaces,
                                imageSize: Size(
                                  controller
                                      .value
                                      .previewSize!
                                      .height, // Perhatikan ini, mungkin perlu disesuaikan
                                  controller
                                      .value
                                      .previewSize!
                                      .width, // tergantung orientasi kamera
                                ),
                                cameraSensorOrientation:
                                    controller.description.sensorOrientation,
                              ),
                            ),
                            // Pesan status
                            if (state.recognitionStatus ==
                                RecognitionStatus.processing)
                              const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            if (state.detectionStatus ==
                                DetectionStatus.detecting)
                              const Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text(
                                    'Mendeteksi Wajah...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            if (state.detectedFaces.isEmpty &&
                                state.recognitionStatus ==
                                    RecognitionStatus.idle)
                              const Positioned(
                                top: 50,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text(
                                    'Posisikan wajah di dalam bingkai',
                                    style: TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                    }
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _BottomControls(),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter untuk menggambar bounding box deteksi wajah
class FaceDetectorPainter extends CustomPainter {
  final List<DetectedFaceEntity> detectedFaces;
  final Size imageSize;
  final int cameraSensorOrientation;

  FaceDetectorPainter({
    required this.detectedFaces,
    required this.imageSize,
    required this.cameraSensorOrientation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;

    for (final face in detectedFaces) {
      // Perlu transformasi koordinat dari resolusi gambar ke resolusi layar
      // dan juga memperhitungkan orientasi kamera.
      // Ini adalah bagian yang paling kompleks, contoh ini adalah penyederhanaan.

      final scaleX = size.width / imageSize.width;
      final scaleY = size.height / imageSize.height;

      // Asumsi: Kamera depan, orientasi potret.
      // Jika kamera dirotasi, bounding box juga perlu dirotasi.
      // Contoh ini mungkin perlu penyesuaian intensif.
      Rect rect = Rect.fromLTRB(
        face.boundingBox.left * scaleX,
        face.boundingBox.top * scaleY,
        face.boundingBox.right * scaleX,
        face.boundingBox.bottom * scaleY,
      );

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is FaceDetectorPainter &&
        oldDelegate.detectedFaces != detectedFaces;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();
  // ... (Implementasi TopBar)
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
        const Text(
          'Scan Wajah',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        // Anda bisa menambahkan tombol lain di sini, seperti flash
      ],
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FaceRecognitionCubit>();
    return BlocBuilder<FaceRecognitionCubit, FaceRecognitionState>(
      builder: (context, state) {
        final isProcessing =
            state.recognitionStatus == RecognitionStatus.processing ||
            state.detectionStatus == DetectionStatus.detecting;
        final hasFaces = state.detectedFaces.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: isProcessing || !hasFaces
                  ? null
                  : cubit
                        .captureAndRecognize, // Nonaktifkan jika tidak ada wajah
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: (isProcessing || !hasFaces)
                      ? Colors.grey
                      : Colors.white, // Warna abu-abu jika tidak ada wajah
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: isProcessing
                        ? (state.recognitionStatus ==
                                  RecognitionStatus.processing
                              ? 'Memproses...'
                              : 'Mendeteksi...')
                        : (hasFaces
                              ? 'Scan Wajah'
                              : 'Posisikan Wajah'), // Teks berubah
                    onPressed: isProcessing || !hasFaces
                        ? null
                        : cubit.captureAndRecognize,
                    icon: const Icon(Icons.check),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
