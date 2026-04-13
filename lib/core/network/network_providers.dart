import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_service.dart';
import 'network_status.dart';

final networkServiceProvider = Provider<NetworkService>((ref) {
  final service = NetworkService();
  unawaited(service.initialize());
  ref.onDispose(service.dispose);
  return service;
});

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final service = ref.watch(networkServiceProvider);

  return Stream<NetworkStatus>.multi((controller) {
    controller.add(service.currentStatus);

    final sub = service.statusStream.listen(
      controller.add,
      onError: controller.addError,
    );

    controller.onCancel = () => sub.cancel();
  });
});

final isOfflineProvider = Provider<bool>((ref) {
  final networkStatus = ref.watch(networkStatusProvider).valueOrNull;
  return networkStatus == NetworkStatus.offline;
});

final isNetworkReadyProvider = Provider<bool>((ref) {
  final networkStatus = ref.watch(networkStatusProvider).valueOrNull;
  return networkStatus != null && networkStatus != NetworkStatus.unknown;
});