import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/login_controller.dart';

class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginControllerProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('NAJDA')),
      body: Center(
        child: Text(
          user == null ? '—' : '${user.fullName}\n${user.role.code}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}