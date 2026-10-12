import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/session_controller.dart';
import 'chat_repository.dart';
import 'fake_chat_repository.dart';
import 'models/chat_message.dart';

/// وقت الربط الحقيقي: FakeChatRepository(...) ← RealChatRepository(...)
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final user = ref.watch(sessionProvider);
  return FakeChatRepository(
    senderId: user?.id ?? 0,
    senderName: user?.firstName ?? 'You',
  );
});

/// رسايل بلاغ معيّن (شاشة التتبع وشاشة الشات بيشاركوا نفس الـ stream).
final chatMessagesProvider = StreamProvider.autoDispose
    .family<List<ChatMessage>, int>((ref, incidentId) {
  return ref.read(chatRepositoryProvider).watchMessages(incidentId);
});

/// آخر رسالة المستخدم شافها في كل بلاغ (محلي، في الذاكرة بس).
/// الداتا بيز مفيهاش حالة "اتقرأت"، فده تقدير على الموبايل.
class ChatLastSeenController extends Notifier<Map<int, int>> {
  @override
  Map<int, int> build() => const {};

  void markSeen(int incidentId, int messageId) {
    if ((state[incidentId] ?? 0) >= messageId) return;
    state = {...state, incidentId: messageId};
  }
}

final chatLastSeenProvider =
NotifierProvider<ChatLastSeenController, Map<int, int>>(
    ChatLastSeenController.new);

/// في رسالة جديدة من حد تاني لسه ما اتفتحتش؟
final unreadChatProvider = Provider.autoDispose.family<bool, int>((ref, id) {
  final me = ref.watch(sessionProvider)?.id;
  final messages =
      ref.watch(chatMessagesProvider(id)).value ?? const <ChatMessage>[];
  final lastSeen = ref.watch(chatLastSeenProvider)[id] ?? 0;

  return messages.any((m) => m.senderId != me && m.id > lastSeen);
});