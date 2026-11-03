import 'package:flutter/foundation.dart';

/// Service to track and expose WebSocket debug information
class DebugService {
  static final _connectionLogs = <String>[];
  static final _messageCount = <String, int>{};
  static final _listeners = <VoidCallback>[];

  static const int _maxLogs = 100; // Keep last 100 logs

  static void log(String message) {
    final timestamp = DateTime.now().toIso8601String().split('T')[1];
    final logMessage = '[$timestamp] $message';

    _connectionLogs.add(logMessage);

    // Keep only recent logs
    if (_connectionLogs.length > _maxLogs) {
      _connectionLogs.removeAt(0);
    }

    debugPrint(logMessage);
    _notifyListeners();
  }

  static void trackMessage(String type) {
    _messageCount[type] = (_messageCount[type] ?? 0) + 1;
    _notifyListeners();
  }

  static List<String> getLogs() => List.from(_connectionLogs);

  static Map<String, int> getMessageStats() => Map.from(_messageCount);

  static String getStatus() {
    if (_connectionLogs.isEmpty) return 'Initializing...';

    final lastLog = _connectionLogs.last;

    if (lastLog.contains('🔌 WebSocket connected')) {
      return 'Connected ✅';
    } else if (lastLog.contains('WebSocket disconnected')) {
      return 'Disconnected ❌';
    } else if (lastLog.contains('WS connect error')) {
      return 'Connection Error ⚠️';
    } else if (lastLog.contains('Reconnecting')) {
      return 'Reconnecting...';
    }

    return 'Unknown';
  }

  static int getTotalMessages() =>
      _messageCount.values.fold(0, (a, b) => a + b);

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  static void clearLogs() {
    _connectionLogs.clear();
    _messageCount.clear();
    _notifyListeners();
  }
}
