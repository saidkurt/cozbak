import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'network_status.dart';

class NetworkService {
  NetworkService({
    Connectivity? connectivity,
    InternetConnection? internetConnection,
  })  : _connectivity = connectivity ?? Connectivity(),
        _internetConnection = internetConnection ?? InternetConnection();

  final Connectivity _connectivity;
  final InternetConnection _internetConnection;

  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<InternetStatus>? _internetSubscription;

  bool _initialized = false;
  NetworkStatus _currentStatus = NetworkStatus.unknown;

  Stream<NetworkStatus> get statusStream => _statusController.stream;
  NetworkStatus get currentStatus => _currentStatus;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await refresh();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((_) async {
      await refresh();
    });

    _internetSubscription =
        _internetConnection.onStatusChange.listen((_) async {
      await refresh();
    });
  }

  Future<void> refresh() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      final hasTransport = connectivityResults.any(
        (result) => result != ConnectivityResult.none,
      );

      if (!hasTransport) {
        _emit(NetworkStatus.offline);
        return;
      }

      final hasInternet = await _internetConnection.hasInternetAccess;

      _emit(hasInternet ? NetworkStatus.online : NetworkStatus.offline);
    } catch (_) {
      _emit(NetworkStatus.offline);
    }
  }

  void _emit(NetworkStatus status) {
    if (_currentStatus == status) return;
    _currentStatus = status;

    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _internetSubscription?.cancel();
    await _statusController.close();
  }
}