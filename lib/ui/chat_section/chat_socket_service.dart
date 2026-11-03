import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatSocketService {
  static const String _wsBaseUrl = 'ws://82.112.230.225:3008';

  static WebSocketChannel? _channel;
  static String? _userId;
  static bool _manuallyClosed = false;
  static Timer? _reconnectTimer;

  static final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get messageStream => _controller.stream;

  static bool get isConnected => _channel != null;

  static void connect(String userId) {
    _userId = userId;
    _manuallyClosed = false;
    _reconnectTimer?.cancel();
    _doConnect();
  }

  static void _doConnect() {
    if (_userId == null || _manuallyClosed) return;
    try {
      _channel?.sink.close();
      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsBaseUrl?userId=$_userId'),
      );
      _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      _scheduleReconnect();
    }
  }

  static void _onData(dynamic data) {
    try {
      final decoded = jsonDecode(data as String);
      if (decoded is Map<String, dynamic>) {
        _controller.add(decoded);
      }
    } catch (_) {}
  }

  static void _onError(dynamic error) {
    _channel = null;
    _scheduleReconnect();
  }

  static void _onDone() {
    _channel = null;
    if (!_manuallyClosed) {
      _scheduleReconnect();
    }
  }

  static void _scheduleReconnect() {
    if (_manuallyClosed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), _doConnect);
  }

  static void _send(Map<String, dynamic> payload) {
    try {
      print(payload);
      _channel?.sink.add(jsonEncode(payload));
    } catch (_) {}
  }

  /// Send a P2P message
  static void sendP2P({
    required String to,
    required String content,
    required String senderId,
    required String senderName,
    String? attachmentName,
    String? attachmentType,
    String? fileUrl,
    String? replyToId,
    String? replyToText,
    String? replyToSender,
  }) {
    final payload = <String, dynamic>{
      'type': 'p2p',
      'to': to,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
    };
    if (attachmentName != null) payload['attachmentName'] = attachmentName;
    if (attachmentType != null) payload['attachmentType'] = attachmentType;
    if (fileUrl != null) payload['fileUrl'] = fileUrl;
    if (replyToId != null) payload['replyToId'] = replyToId;
    if (replyToText != null) payload['replyToText'] = replyToText;
    if (replyToSender != null) payload['replyToSender'] = replyToSender;
    _send(payload);
  }

  /// Send a group message
  static void sendGroup({
    required String groupId,
    required String content,
    required String senderId,
    required String senderName,
    String? attachmentName,
    String? attachmentType,
    String? fileUrl,
    String? replyToId,
    String? replyToText,
    String? replyToSender,
  }) {
    final payload = <String, dynamic>{
      'type': 'group',
      'to': groupId,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
    };
    if (attachmentName != null) payload['attachmentName'] = attachmentName;
    if (attachmentType != null) payload['attachmentType'] = attachmentType;
    if (fileUrl != null) payload['fileUrl'] = fileUrl;
    if (replyToId != null) payload['replyToId'] = replyToId;
    if (replyToText != null) payload['replyToText'] = replyToText;
    if (replyToSender != null) payload['replyToSender'] = replyToSender;
    _send(payload);
  }

  /// Notify server that user opened a chat screen
  static void setActiveChat({
    required String chatType,
    required String chatId,
  }) {
    _send({
      'type': 'status_active_chat',
      'chatType': chatType,
      'chatId': chatId,
    });
  }

  /// Notify server that user left a chat screen
  static void clearActiveChat() {
    _send({'type': 'status_active_chat'});
  }

  static void disconnect() {
    _manuallyClosed = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _userId = null;
  }
}
