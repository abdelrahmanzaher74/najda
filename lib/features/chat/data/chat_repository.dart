import 'models/chat_message.dart';

/// الواجهة اللي الشاشات بتتعامل معاها.
/// دلوقتي التنفيذ وهمي، وبعدين هيبقى الـ API الحقيقي
/// (الـ Dispatcher والـ Admin بيكتبوا من الويب، والـ Backend هو اللي بيوصّل الرسايل).
abstract class ChatRepository {
  /// كل رسايل البلاغ بالترتيب الزمني. دلوقتي Polling، وبعدين WebSocket.
  Stream<List<ChatMessage>> watchMessages(int incidentId);

  /// الـ Backend هو اللي بيحدد المرسل من الـ token (مش من الموبايل).
  Future<ChatMessage> sendMessage(int incidentId, String content);
}