import 'package:camera/camera.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/cubit/face_recognition_state.dart';

class LoginCameraState {
  final CameraStatus cameraStatus;
  final CameraController? controller;
  final String? errorMessage;

  const LoginCameraState({
    this.cameraStatus = CameraStatus.initial,
    this.controller,
    this.errorMessage,
  });

  LoginCameraState copyWith({
    CameraStatus? cameraStatus,
    CameraController? controller,
    String? errorMessage,
  }) {
    return LoginCameraState(
      cameraStatus: cameraStatus ?? this.cameraStatus,
      controller: controller ?? this.controller,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
