import '../../domain/entity/face_entity.dart';

class FaceModel extends FaceEntity {
  FaceModel({
    required super.id,
    required super.filepath,
    required super.bboxFilepath,
  });

  factory FaceModel.fromJson(Map<String, dynamic> json) {
    return FaceModel(
      id: json['id'] as int,
      filepath: json['filepath'] as String,
      bboxFilepath: json['bbox_filepath'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'filepath': filepath, 'bbox_filepath': bboxFilepath};
  }

  FaceEntity toEntity() {
    return FaceEntity(id: id, filepath: filepath, bboxFilepath: bboxFilepath);
  }
}
