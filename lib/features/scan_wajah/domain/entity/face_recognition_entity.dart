class FaceRecognitionEntity {
  final String userId;
  final String userName;
  final double confidence; // Skor kepercayaan model

  FaceRecognitionEntity({
    required this.userId,
    required this.userName,
    required this.confidence,
  });

  // Entitas untuk kasus pendaftaran wajah
  factory FaceRecognitionEntity.registrationSuccess() => FaceRecognitionEntity(
    userId: 'REGISTERED',
    userName: 'Pendaftaran Berhasil',
    confidence: 1.0,
  );
}

// Entitas untuk menyimpan data wajah (misal: embeddings dari TFLite)
class FaceDataEntity {
  final String userId;
  final List<double> embeddings;

  FaceDataEntity({required this.userId, required this.embeddings});
}

