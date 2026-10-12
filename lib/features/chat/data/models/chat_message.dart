import '../../../auth/data/models/user_role.dart';

/// رسالة في شات بلاغ. بتطابق جدول chat_messages
/// (content و sent_at و incident_id و sender_id)،
/// واسم المرسل ودوره بييجوا من الـ Backend (من users).
class ChatMessage {
  final int id;
  final int incidentId;
  final int senderId;
  final String senderName;
  final UserRole senderRole;
  final String content;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.incidentId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.sentAt,
  });

  // أسماء المفاتيح تخمين (camelCase)، هنأكدها من رد حقيقي من الـ Backend.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['id'] as num).toInt(),
      incidentId: (json['incidentId'] as num).toInt(),
      senderId: (json['senderId'] as num).toInt(),
      senderName: json['senderName'] as String? ?? '',
      senderRole: UserRole.fromCode(json['senderRole'] as String?),
      content: json['content'] as String? ?? '',
      sentAt: DateTime.tryParse(json['sentAt'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}