import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/cubit/face_recognition_state.dart';
import '../cubit/face_recognition_cubit.dart';
import 'scan_result.dart';

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
      body: BlocBuilder<FaceRecognitionCubit, FaceRecognitionState>(
        builder: (context, state) {
          switch (state.cameraStatus) {
            case CameraStatus.initial:
            case CameraStatus.loading:
              return const SizedBox.expand();
            case CameraStatus.error:
              return Center(
                child: Text(
                  state.errorMessage ?? 'Gagal memuat kamera',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            case CameraStatus.ready:
              final controller = state.controller!;
              final previewSize = controller.value.previewSize;
              // Full-screen camera with overlays (guide + controls)
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Camera preview (portrait-friendly)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width:
                          previewSize?.height ??
                          MediaQuery.of(context).size.height,
                      height:
                          previewSize?.width ??
                          MediaQuery.of(context).size.width,
                      child: CameraPreview(controller),
                    ),
                  ),

                  // Top-left back button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: _CircleIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),

                  // Center text instruction
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

                  // Dashed ellipse face guide
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

                  // Small pill hint near bottom of guide
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
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),

                  // Bottom controls bar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left: flash toggle
                          _CircleIconButton(
                            icon: Icons.flash_on,
                            onTap: () => context
                                .read<FaceRecognitionCubit>()
                                .toggleFlash(),
                          ),
                          // Center: shutter (no-op)
                          _ShutterButton(
                            onTap: () async {
                              final cubit = context
                                  .read<FaceRecognitionCubit>();
                              final xfile = await cubit.captureAndSave();
                              if (xfile == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Gagal mengambil gambar'),
                                  ),
                                );
                                return;
                              }

                              final files = cubit.state.captures;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ScanResultPage(files: files),
                                ),
                              );
                            },
                          ),
                          // Right: switch camera
                          _CircleIconButton(
                            icon: Icons.cameraswitch,
                            onTap: () => context
                                .read<FaceRecognitionCubit>()
                                .switchCamera(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFF2D64F0),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ShutterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class FaceGuidePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const FaceGuidePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()..addOval(rect);
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = distance + dashLength;
        final extract = metric.extractPath(distance, next);
        canvas.drawPath(extract, paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant FaceGuidePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}
