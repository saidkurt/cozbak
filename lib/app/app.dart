import 'package:cozbak/app/router/app_router.dart';
import 'package:cozbak/core/theme/app_theme.dart';
import 'package:cozbak/shared/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CozBakApp extends ConsumerWidget {
  const CozBakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}