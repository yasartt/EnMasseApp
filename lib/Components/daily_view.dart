import 'package:hive/hive.dart';

part 'daily_view.g.dart'; // This file will be generated

@HiveType(typeId: 0)
class DailyView {
  @HiveField(0)
  final String dailyId;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String? caption;
  @HiveField(3)
  final DateTime? created;
  @HiveField(4)
  final List<ImageDTO>? images;
  @HiveField(5)
  final String userName;
  @HiveField(6)
  final String? userPhotoId;

  DailyView({
    required this.dailyId,
    required this.userId,
    this.caption,
    this.created,
    this.images,
    required this.userName,
    this.userPhotoId,
  });

  factory DailyView.fromJson(Map<String, dynamic> json) {
    return DailyView(
      dailyId: json['dailyId'] ?? 0,
      userId: json['userId'] ?? 0,
      caption: json['caption'] ?? "",
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      userName: json['userName'] ?? "",
      userPhotoId: json['userPhotoId'] ?? "",
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => ImageDTO.fromJson(image))
          .toList(),
    );
  }
}

@HiveType(typeId: 1)
class ImageDTO {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String imageName;
  @HiveField(2)
  final int dailyId;

  ImageDTO({
    required this.id,
    required this.imageName,
    required this.dailyId,
  });

  factory ImageDTO.fromJson(Map<String, dynamic> json) {
    return ImageDTO(
      id: json['id'],
      imageName: json['imageName'],
      dailyId: json['dailyId'],
    );
  }
}
