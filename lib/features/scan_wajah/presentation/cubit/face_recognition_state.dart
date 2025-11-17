import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';
import '../../domain/entity/face_recognition_entity.dart';
import '../../domain/entity/detected_face_entity.dart'; // Entitas baru

enum CameraStatus { initial, loading, ready, error }

enum RecognitionStatus { idle, processing, success, failure }

enum DetectionStatus { idle, detecting } // Status baru

class FaceRecognitionState extends Equatable {
  final CameraStatus cameraStatus;
  final RecognitionStatus recognitionStatus;
  final DetectionStatus detectionStatus; // Status deteksi
  final CameraController? controller;
  final CameraDescription? frontCamera;
  final List<XFile> captures;
  final FaceRecognitionEntity? result;
  final List<DetectedFaceEntity> detectedFaces; // List wajah yang terdeteksi
  final String? errorMessage;

  const FaceRecognitionState({
    this.cameraStatus = CameraStatus.initial,
    this.recognitionStatus = RecognitionStatus.idle,
    this.detectionStatus = DetectionStatus.idle, // Default
    this.controller,
    this.frontCamera,
    this.captures = const [],
    this.result,
    this.detectedFaces = const [], // Default kosong
    this.errorMessage,
  });

  FaceRecognitionState copyWith({
    CameraStatus? cameraStatus,
    RecognitionStatus? recognitionStatus,
    DetectionStatus? detectionStatus, // Tambahkan ini
    CameraController? controller,
    CameraDescription? frontCamera,
    List<XFile>? captures,
    FaceRecognitionEntity? result,
    List<DetectedFaceEntity>? detectedFaces, // Tambahkan ini
    String? errorMessage,
  }) {
    return FaceRecognitionState(
      cameraStatus: cameraStatus ?? this.cameraStatus,
      recognitionStatus: recognitionStatus ?? this.recognitionStatus,
      detectionStatus: detectionStatus ?? this.detectionStatus, // Gunakan ini
      controller: controller,
      frontCamera: frontCamera ?? this.frontCamera,
      captures: captures ?? this.captures,
      result: result,
      detectedFaces: detectedFaces ?? this.detectedFaces, // Gunakan ini
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    cameraStatus,
    recognitionStatus,
    detectionStatus, // Tambahkan
    controller,
    frontCamera,
    captures,
    result,
    detectedFaces, // Tambahkan
    errorMessage,
  ];
}
