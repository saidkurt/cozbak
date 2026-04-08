
import 'package:cozbak/features/auth/providers/auth_action_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            await ref.read(authActionProvider).signOut();
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Çıkış Yap'),
        ),
      ),
    );
  }
}