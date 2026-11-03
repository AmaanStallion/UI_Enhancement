import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'models.dart';

class ChatService {
  static const String baseUrl = 'http://82.112.230.225:3008';

  static Future<List<ChatListItem>> getChatList(String userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/my_chats?userId=$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      inspect(res);
      return list.map((e) => ChatListItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load chat list: ${res.statusCode}');
  }

  static Future<List<ServerMessage>> getChatHistory(
      String type, String chatId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/history?type=$type&chatId=$chatId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((e) => ServerMessage.fromJson(e)).toList();
    }
    throw Exception('Failed to load history: ${res.statusCode}');
  }

  static Future<void> markChatAsRead(
      String userId, String chatType, String chatId) async {
    await http.post(
      Uri.parse('$baseUrl/mark_read'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'userId': userId, 'chatType': chatType, 'chatId': chatId}),
    );
  }

  static Future<bool> editMessage(
      String messageId, String newText, String chatType, String chatId) async {
    final res = await http.put(
      Uri.parse('$baseUrl/edit_message'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'messageId': messageId,
        'newText': newText,
        'chatType': chatType,
        'chatId': chatId,
      }),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['success'] == true;
    }
    return false;
  }

  static Future<bool> deleteMessage(
      String messageId, String chatType, String chatId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/delete_message'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'messageId': messageId,
        'chatType': chatType,
        'chatId': chatId,
      }),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['success'] == true;
    }
    return false;
  }

  static Future<Map<String, String>?> uploadFile(
      File file, String userId) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    // request.headers.addAll({'Authorization': 'Bearer $token'});
    request.fields['userId'] = userId;

    final extension = file.path.split('.').last.toLowerCase();
    final MediaType contentType;
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      contentType = MediaType('image', extension == 'jpg' ? 'jpeg' : extension);
    } else if (extension == 'pdf') {
      contentType = MediaType('application', 'pdf');
    } else {
      contentType = MediaType('application', 'octet-stream');
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: contentType,
      ),
    );
    inspect(request.fields);
    final response = await request.send();
    inspect(response);
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      inspect(json);
      if (json['success'] == true) {
        return {
          'fileUrl': json['fileUrl']?.toString() ?? '',
          'fileName': json['fileName']?.toString() ?? '',
          'fileType': json['fileType']?.toString() ?? '',
        };
      }
    }
    return null;
  }
}
