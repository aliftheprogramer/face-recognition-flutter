import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/cubit/face_recognition_state.dart';
import 'login_camera_state.dart';

class LoginCameraCubit extends Cubit<LoginCameraState> {
  LoginCameraCubit() : super(const LoginCameraState());

  Future<void> initCamera() async {
    emit(
      state.copyWith(cameraStatus: CameraStatus.loading, errorMessage: null),
    );
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        emit(
          state.copyWith(
            cameraStatus: CameraStatus.error, 
            errorMessage: 'Tidak ada kamera tersedia.',
            controller: null,
          ),
        );
        return;
      }
      final front = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      emit(
        state.copyWith(
          cameraStatus: CameraStatus.ready,
          controller: controller,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          cameraStatus: CameraStatus.error,
          errorMessage: e.toString(),
          controller: null,
        ),
      );
    }
  }

  void disposeController() {
    state.controller?.dispose();
    emit(const LoginCameraState());
  }

  Future<XFile?> capture() async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return null;
    try {
      final xfile = await controller.takePicture();
      return xfile;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() {
    state.controller?.dispose();
    return super.close();
  }
}
