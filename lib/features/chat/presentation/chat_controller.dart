import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../data/chat_providers.dart';

class ChatController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// بترجع true لو الرسالة اتبعتت
  Future<bool> send(int incidentId, String text) async {
    state = const AsyncLoading();
    try {
      await ref.read(chatRepositoryProvider).sendMessage(incidentId, text);
      // نحدّث القايمة فورًا بدل ما نستنى الـ Polling
      ref.invalidate(chatMessagesProvider(incidentId));
      state = const AsyncData(null);
      return true;
    } on Failure catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final chatControllerProvider =
AsyncNotifierProvider<ChatController, void>(ChatController.new);