import 'dart:ui';

class DetectedFaceEntity {
  final Rect boundingBox;
  final double confidence;

  DetectedFaceEntity({required this.boundingBox, required this.confidence});
}
