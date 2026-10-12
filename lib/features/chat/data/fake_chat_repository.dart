import '../../../core/error/failure.dart';
import '../../auth/data/models/user_role.dart';
import 'chat_repository.dart';
import 'models/chat_message.dart';

/// بيحفظ في الذاكرة بس. بيحاكي رد الـ Dispatcher (بعد أول رسالة)
/// ودخول Admin (بعد التانية) عشان تجرّب شكل الأدوار.
class FakeChatRepository implements ChatRepository {
  final int senderId;
  final String senderName;

  FakeChatRepository({required this.senderId, required this.senderName});

  final Map<int, List<ChatMessage>> _messages = {};
  final Map<int, int> _citizenCount = {};
  int _nextId = 1;

  ChatMessage _add(
      int incidentId, {
        required int id,
        required String name,
        required UserRole role,
        required String content,
      }) {
    final message = ChatMessage(
      id: _nextId++,
      incidentId: incidentId,
      senderId: id,
      senderName: name,
      senderRole: role,
      content: content,
      sentAt: DateTime.now(),
    );
    _messages.putIfAbsent(incidentId, () => []).add(message);
    return message;
  }

  void _replyLater(
      int incidentId,
      int seconds, {
        required int id,
        required String name,
        required UserRole role,
        required String content,
      }) {
    Future.delayed(Duration(seconds: seconds), () {
      _add(incidentId, id: id, name: name, role: role, content: content);
    });
  }

  @override
  Stream<List<ChatMessage>> watchMessages(int incidentId) async* {
    while (true) {
      yield List.unmodifiable(_messages[incidentId] ?? const []);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Future<ChatMessage> sendMessage(int incidentId, String content) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final text = content.trim();
    if (text.isEmpty) throw const ValidationFailure('Message is empty');

    final message = _add(
      incidentId,
      id: senderId,
      name: senderName,
      role: UserRole.citizen,
      content: text,
    );

    final count = (_citizenCount[incidentId] ?? 0) + 1;
    _citizenCount[incidentId] = count;

    if (count == 1) {
      _replyLater(
        incidentId,
        4,
        id: 101,
        name: 'Nadia',
        role: UserRole.dispatcher,
        content:
        'Hi, this is the dispatch room. We received your report and help is being arranged. Is the person breathing normally?',
      );
    } else if (count == 2) {
      _replyLater(
        incidentId,
        5,
        id: 102,
        name: 'Youssef',
        role: UserRole.admin,
        content: 'Admin here. I am following this case with the dispatcher.',
      );
    }

    return message;
  }
}