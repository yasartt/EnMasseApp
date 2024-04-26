import 'package:hive/hive.dart';

part 'session_message.g.dart';

@HiveType(typeId: 1)
class SessionMessage {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cafeId;

  @HiveField(2)
  final String senderId;

  @HiveField(3)
  final DateTime sentAt;

  @HiveField(4)
  final String content;

  SessionMessage({
    required this.id,
    required this.cafeId,
    required this.senderId,
    required this.sentAt,
    required this.content,
  });

// Adding a factory constructor for creating an instance from JSON
  factory SessionMessage.fromJson(Map<String, dynamic> json) {
    return SessionMessage(
      id: json['id'] as String,
      cafeId: json['cafeId'] as String,
      senderId: json['senderId'] as String,
      // Parsing the string to DateTime. Ensure your JSON date format matches.
      sentAt: DateTime.parse(json['sentAt']),
      content: json['content'] as String,
    );
  }
// Add methods for converting to and from JSON if needed
}
