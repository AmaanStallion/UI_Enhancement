# Quick Start Guide - Chat Attachments

## Files Overview

### Core Files
- **models.dart** - Data models (ChatUser, ChatMessage, ChatAttachment)
- **chat_ui.dart** - Main chat UI with attachment integration
- **attachment_service.dart** - File picker service
- **attachment_components.dart** - UI widgets for attachments

## Key Changes Summary

### 1. ChatAttachment Model
```dart
// New class to represent file attachments
class ChatAttachment {
  final String filePath;
  final String fileName;
  final String fileType; // 'image', 'video', 'file'
  final int fileSize;
  final DateTime uploadedAt;
  
  // Helpers
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  bool get isVideo => ['mp4', 'avi', 'mov', 'mkv', 'flv'].contains(extension);
  String get formattedSize => '${(fileSize / 1024).toStringAsFixed(2)} KB';
}
```

### 2. Updated ChatMessage
```dart
class ChatMessage {
  final String message;
  final bool isMe;
  final DateTime time;
  final List<ChatAttachment>? attachments;  // NEW
}
```

### 3. Chat UI Updates
```dart
// State
List<ChatAttachment> _selectedAttachments = [];

// Show attachment options
void _showAttachmentOptions() { ... }

// Handle file selection
Future<void> _handleAttachmentSelection(String type) async { ... }

// Send with attachments
void _sendMessage() {
  // Now includes attachment handling
}
```

## User Interactions

| Action | Button | Result |
|--------|--------|--------|
| Attach files | 📎 | Shows bottom sheet |
| Pick images | Select "Images" | Image picker opens |
| Pick videos | Select "Videos" | Video picker opens |
| Pick files | Select "Files" | File picker opens |
| Remove attachment | X on preview | Attachment removed |
| Send | ➤ | Message + attachments sent |

## Implementation Flow

```
Click Attach (📎)
    ↓
Show Bottom Sheet (Images/Videos/Files)
    ↓
User selects type
    ↓
File Picker opens (via AttachmentService)
    ↓
User selects file(s)
    ↓
Attachments displayed in preview area
    ↓
User can remove or add more
    ↓
Click Send
    ↓
Message + attachments added to chat
```

## Code Usage Examples

### Send Text with Image
```dart
// User picks image
List<ChatAttachment> images = await AttachmentService.pickImages();

// Message with attachment
messages.add(ChatMessage(
  message: 'Check this photo!',
  isMe: true,
  time: DateTime.now(),
  attachments: images,
));
```

### Send Multiple Files
```dart
List<ChatAttachment> files = await AttachmentService.pickFiles();
// Can pick multiple files at once
// All files are added to _selectedAttachments
```

### Display in Chat
```dart
// In _buildMessages()
if (msg.attachments != null && msg.attachments!.isNotEmpty)
  MessageAttachmentsWidget(attachments: msg.attachments!)
```

## UI Components Structure

### Attachment Preview Widget
Shows horizontal scrollable list of selected files before sending
- Image thumbnail preview
- Video icon + filename
- File icon + filename + size
- Remove button (X)

### Message Attachments Widget
Displays attachments in sent/received messages
- Full-size image display
- Video card with play icon
- File card with download icon

### Bottom Sheet
Modal for selecting attachment type
- Images button → pickImages()
- Videos button → pickVideos()
- Files button → pickFiles()

## Next Steps for Production

1. **Add Upload to Server**
   ```dart
   // Call API to upload file
   Future<void> uploadAttachment(ChatAttachment attachment) async {
     // Send to server
     // Get URL back
     // Save URL to database
   }
   ```

2. **Download Received Attachments**
   ```dart
   // When receiving message with attachment
   // Download and cache locally
   ```

3. **Persistence**
   ```dart
   // Save messages with attachments to local database
   // Use sqflite or hive for local storage
   ```

4. **Error Handling**
   ```dart
   // Handle failed uploads
   // Retry mechanism
   // Network error messages
   ```

## Testing Checklist

- [ ] Click attach button opens bottom sheet
- [ ] Selecting "Images" opens image picker
- [ ] Selecting "Videos" opens video picker
- [ ] Selecting "Files" opens file picker
- [ ] Selected file(s) show in preview
- [ ] Can remove attachment with X button
- [ ] Can select multiple files
- [ ] Message sends with attachments
- [ ] Attachment displays in chat correctly
- [ ] Image shows as thumbnail
- [ ] Video shows with icon
- [ ] File shows as card
- [ ] File size displays correctly

## Troubleshooting

**Import errors?**
- Add imports to chat_ui.dart:
  ```dart
  import 'attachment_components.dart';
  import 'attachment_service.dart';
  ```

**File picker not working?**
- Check file_picker version: `^10.3.7`
- Ensure platform-specific permissions are set

**Attachments not showing?**
- Verify `MessageAttachmentsWidget` is called in `_buildMessages()`
- Check attachments list is not null/empty

## API Integration Template

```dart
Future<void> sendMessageWithAttachments(String text, List<ChatAttachment> attachments) async {
  // Upload files first
  List<String> fileUrls = [];
  for (var attachment in attachments) {
    String url = await uploadFileToServer(attachment);
    fileUrls.add(url);
  }
  
  // Send message with file URLs
  await sendMessageToServer(
    text: text,
    fileUrls: fileUrls,
    userId: currentUser.id,
  );
  
  // Add to local chat
  messages.add(ChatMessage(
    message: text,
    isMe: true,
    time: DateTime.now(),
    attachments: attachments,
  ));
}
```

---

**Status**: ✅ Core attachment feature ready  
**Next**: Integrate with backend API for upload/download functionality
