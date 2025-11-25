import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../../common/bloc/auth/auth_cubit.dart';
import '../../../../common/pages/main_screen.dart';
import '../../../../core/services/services_locator.dart';
import '../../../auth/domain/usecase/face_login_usecase.dart';

class ScanLoginPage extends StatefulWidget {
  const ScanLoginPage({super.key});

  @override
  State<ScanLoginPage> createState() => _ScanLoginPageState();
}

class _ScanLoginPageState extends State<ScanLoginPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _initializing = true;
  bool _processing = false;
  final Logger _logger = sl<Logger>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() => _initializing = true);
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('Kamera tidak tersedia');
      }
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      setState(() => _controller = controller);
    } catch (e, st) {
      _logger.e('Gagal inisialisasi kamera: $e', error: e, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuka kamera: $e')));
      }
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  void _disposeCamera() {
    final controller = _controller;
    _controller = null;
    controller?.dispose();
  }

  Future<void> _captureAndAuthenticate() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _processing) {
      return;
    }
    setState(() => _processing = true);
    try {
      final xFile = await controller.takePicture();
      final dartz.Either<String, Response> result = await sl<FaceLoginUsecase>()
          .call(param: xFile.path);
      if (!mounted) return;
      await result.fold(
        (err) async {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Login wajah gagal: $err')));
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          try {
            await sl<AuthStateCubit>().checkAuthStatus();
          } catch (_) {}
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
        },
      );
    } catch (e, st) {
      _logger.e('Gagal mengirim foto: $e', error: e, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
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
      body: SafeArea(
        child: _initializing
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: controller != null && controller.value.isInitialized
                        ? CameraPreview(controller)
                        : const Center(
                            child: Text(
                              'Kamera tidak tersedia',
                              style: TextStyle(color: Colors.white70),
                            ),
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
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF2D64F0),
                      ),
                      icon: const Icon(Icons.camera_alt),
                      label: Text(
                        _processing ? 'Memproses...' : 'Masuk dengan wajah',
                      ),
                      onPressed: _processing ? null : _captureAndAuthenticate,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
