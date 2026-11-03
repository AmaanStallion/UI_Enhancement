class ChatUser {
  final String id;
  final String name;
  final String lastMessage;

  ChatUser({
    required this.id,
    required this.name,
    required this.lastMessage,
  });
}

// ---- API response models ----

class ChatListItem {
  final String id;
  final String type; // "p2p" or "group"
  final String name;
  final String? mobile;
  final String? otherUserId;
  final int unreadCount;
  final String lastMessage;
  final DateTime? lastMessageTime;

  ChatListItem({
    required this.id,
    required this.type,
    required this.name,
    this.mobile,
    this.otherUserId,
    required this.unreadCount,
    required this.lastMessage,
    this.lastMessageTime,
  });

  factory ChatListItem.fromJson(Map<String, dynamic> json) {
    return ChatListItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'p2p',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString(),
      otherUserId: json['other_user_id']?.toString(),
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
      lastMessage: json['last_message']?.toString() ?? '',
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.tryParse(json['last_message_time'].toString())
          : null,
    );
  }
}

class ServerMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final String? attachmentName;
  final String? attachmentType;
  final String? fileUrl;
  final bool isEdited;
  final String? replyToId;
  final String? replyToText;
  final String? replyToSender;

  ServerMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.attachmentName,
    this.attachmentType,
    this.fileUrl,
    required this.isEdited,
    this.replyToId,
    this.replyToText,
    this.replyToSender,
  });

  factory ServerMessage.fromJson(Map<String, dynamic> json) {
    return ServerMessage(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      attachmentName: json['attachmentName']?.toString(),
      attachmentType: json['attachmentType']?.toString(),
      fileUrl: json['fileUrl']?.toString(),
      isEdited: json['isEdited'] == true,
      replyToId: json['replyToId']?.toString(),
      replyToText: json['replyToText']?.toString(),
      replyToSender: json['replyToSender']?.toString(),
    );
  }

  bool get hasAttachment => fileUrl != null && fileUrl!.isNotEmpty;

  bool get isImageAttachment {
    if (attachmentType != null) {
      return attachmentType!.startsWith('image/');
    }
    if (attachmentName != null) {
      final ext = attachmentName!.split('.').last.toLowerCase();
      return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
    }
    return false;
  }
}

class ChatAttachment {  
  final String filePath;
  final String fileName;
  final String fileType; // 'image', 'video', 'file'
  final int fileSize; // in bytes
  final DateTime uploadedAt;

  ChatAttachment({
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
  });

  // Helper method to get file extension
  String get extension => fileName.split('.').last.toLowerCase();

  // Helper method to check if it's an image
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);

  // Helper method to check if it's a video
  bool get isVideo => ['mp4', 'avi', 'mov', 'mkv', 'flv'].contains(extension);

  // Format file size in human-readable format
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class ChatMessage {
  final String message;
  final bool isMe;
  final DateTime time;
  final List<ChatAttachment>? attachments;
  final List<String>? mentions;
  final DateTime? editedAt;

  ChatMessage({
    required this.message,
    required this.isMe,
    required this.time,
    this.attachments,
    this.mentions,
    this.editedAt,
  });

  // Check if message has been edited
  bool get isEdited => editedAt != null;

  // Create a copy with modifications
  ChatMessage copyWith({
    String? message,
    bool? isMe,
    DateTime? time,
    List<ChatAttachment>? attachments,
    List<String>? mentions,
    DateTime? editedAt,
  }) {
    return ChatMessage(
      message: message ?? this.message,
      isMe: isMe ?? this.isMe,
      time: time ?? this.time,
      attachments: attachments ?? this.attachments,
      mentions: mentions ?? this.mentions,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}
