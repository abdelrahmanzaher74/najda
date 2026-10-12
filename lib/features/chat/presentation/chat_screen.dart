import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/error/failure.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/models/user_role.dart';
import '../../auth/presentation/session_controller.dart';
import '../../incident/data/incident_providers.dart';
import '../data/chat_providers.dart';
import '../data/models/chat_message.dart';
import 'chat_controller.dart';
import 'chat_labels.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int incidentId;

  const ChatScreen({super.key, required this.incidentId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final ok = await ref
        .read(chatControllerProvider.notifier)
        .send(widget.incidentId, text);
    if (!mounted) return;

    if (ok) {
      _textController.clear();
    } else {
      // بنسيب النص في الخانة عشان المستخدم يعيد المحاولة
      final l10n = AppLocalizations.of(context);
      final error = ref.read(chatControllerProvider).error;
      final message =
      error is NetworkFailure ? error.message : l10n.chatSendFailed;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// بنضيف إشعار "انضم مسؤول" قبل أول رسالة من الـ Admin.
  List<_ChatItem> _buildItems(List<ChatMessage> messages) {
    final items = <_ChatItem>[];
    var adminAnnounced = false;

    for (final m in messages) {
      final isAdmin =
          m.senderRole == UserRole.admin || m.senderRole == UserRole.superAdmin;
      if (isAdmin && !adminAnnounced) {
        adminAnnounced = true;
        items.add(const _ChatItem.adminJoined());
      }
      items.add(_ChatItem.message(m));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final id = widget.incidentId;

    final me = ref.watch(sessionProvider)?.id;
    final messagesState = ref.watch(chatMessagesProvider(id));
    final isSending = ref.watch(chatControllerProvider).isLoading;
    final closed =
        ref.watch(incidentStreamProvider(id)).value?.status.isFinished ?? false;

    // علّم الرسايل كمقروءة
    final messages = messagesState.value;
    if (messages != null && messages.isNotEmpty) {
      final lastId = messages.last.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(chatLastSeenProvider.notifier).markSeen(id, lastId);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.chatTitle),
            Text(
              '${l10n.reportNumber} #$id',
              style: textTheme.labelSmall?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messagesState.when(
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          error is Failure
                              ? error.message
                              : const UnknownFailure().message,
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(chatMessagesProvider(id)),
                          child: Text(l10n.tryAgain),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (list) {
                  if (list.isEmpty) return const _EmptyChat();

                  final items = _buildItems(list);
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[items.length - 1 - index];
                      if (item.message == null) return const _AdminJoinedNotice();

                      final message = item.message!;
                      return _MessageBubble(
                        message: message,
                        mine: message.senderId == me,
                      );
                    },
                  );
                },
              ),
            ),
            if (closed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                color: Colors.black.withValues(alpha: 0.04),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 18, color: Colors.black54),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.chatClosed,
                        style: textTheme.bodySmall
                            ?.copyWith(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: 1000,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: l10n.chatHint,
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: l10n.send,
                        onPressed: isSending ? null : _send,
                        icon: isSending
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// عنصر في القايمة: رسالة، أو إشعار "انضم مسؤول".
class _ChatItem {
  final ChatMessage? message;

  const _ChatItem.message(ChatMessage this.message);
  const _ChatItem.adminJoined() : message = null;
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.chatEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminJoinedNotice extends StatelessWidget {
  const _AdminJoinedNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: chatRoleColor(UserRole.admin).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            l10n.adminJoined,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: chatRoleColor(UserRole.admin),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool mine;

  const _MessageBubble({required this.message, required this.mine});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final roleColor = chatRoleColor(message.senderRole);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(message.sentAt),
    );

    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // اسم المرسل + شارة دوره (لرسايل التانيين)
              if (!mine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
                  child: Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        message.senderName,
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          chatRoleLabel(l10n, message.senderRole),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: mine ? AppColors.primary : Colors.white,
                  border: mine
                      ? null
                      : Border.all(color: roleColor.withValues(alpha: 0.35)),
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: const Radius.circular(18),
                    topEnd: const Radius.circular(18),
                    bottomStart: Radius.circular(mine ? 18 : 4),
                    bottomEnd: Radius.circular(mine ? 4 : 18),
                  ),
                ),
                child: Text(
                  message.content,
                  style: textTheme.bodyMedium?.copyWith(
                    color: mine ? Colors.white : AppColors.foreground,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                child: Text(
                  time,
                  style: textTheme.labelSmall?.copyWith(color: Colors.black45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}