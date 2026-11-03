# Architecture & Data Flow Diagrams

## System Architecture

```
┌─────────────────────────────────────────────────────┐
│                   CHAT UI                           │
│                 (chat_ui.dart)                       │
├─────────────────────────────────────────────────────┤
│  Input Area                                         │
│  ┌─────────────────────────────────────────────┐   │
│  │ [📎 Button] [TextField] [➤ Send Button]    │   │
│  │ Attachment Preview: [IMG] [VID] [FILE]     │   │
│  └─────────────────────────────────────────────┘   │
│           ↓                          ↓              │
│   ┌──────────────────┐    ┌──────────────────┐     │
│   │ Attachment       │    │ Send Message     │     │
│   │ Service          │    │                  │     │
│   │ (picks files)    │    │ (creates msg)    │     │
│   └──────────────────┘    └──────────────────┘     │
└─────────────────────────────────────────────────────┘
         │                           │
         ↓                           ↓
┌──────────────────────┐   ┌──────────────────────┐
│ File Picker Plugin   │   │ Messages List        │
│ (file_picker pkg)    │   │ (displays in chat)   │
└──────────────────────┘   └──────────────────────┘
         │                           ↑
         └───────────────────────────┘
                Messages with
               Attachments Stored
```

## Data Flow Diagram

```
USER SELECTS ATTACH (📎)
         │
         ↓
┌────────────────────────────┐
│ Show Attachment Options    │
│ - Images                   │
│ - Videos                   │
│ - Files                    │
└────────────────────────────┘
         │
         ↓
    USER SELECTS TYPE
         │
    ┌────┴────┬────────┬────────┐
    ↓         ↓        ↓        ↓
 IMAGES   VIDEOS    FILES     CANCEL
    │         │        │
    └────┬────┴────┬───┘
         │
         ↓
┌─────────────────────────────┐
│ File Picker Opens           │
│ (via AttachmentService)     │
└─────────────────────────────┘
         │
         ↓
   USER SELECTS FILE(S)
         │
         ↓
┌──────────────────────────────────┐
│ Convert to ChatAttachment Objects │
│ - filePath                       │
│ - fileName                       │
│ - fileType                       │
│ - fileSize                       │
│ - uploadedAt                     │
└──────────────────────────────────┘
         │
         ↓
┌──────────────────────────────────┐
│ Add to _selectedAttachments List │
└──────────────────────────────────┘
         │
         ↓
┌──────────────────────────────────┐
│ Display Attachment Preview       │
│ (AttachmentPreviewWidget)        │
│ - Show thumbnail/icon            │
│ - Show filename & size           │
│ - Show remove button             │
└──────────────────────────────────┘
         │
    ┌────┴──────────────┐
    ↓                   ↓
USER ADDS MORE    USER REMOVES
    │                   │
    └──────┬────────────┘
           ↓
      USER CLICKS SEND
           │
           ↓
┌──────────────────────────────────┐
│ Create ChatMessage               │
│ - message (text)                 │
│ - isMe (true)                    │
│ - time (now)                     │
│ - attachments (list)             │
└──────────────────────────────────┘
           │
           ↓
┌──────────────────────────────────┐
│ Add to messages List             │
└──────────────────────────────────┘
           │
           ↓
┌──────────────────────────────────┐
│ Clear Text & Attachments         │
│ - _controller.clear()            │
│ - _selectedAttachments.clear()   │
└──────────────────────────────────┘
           │
           ↓
┌──────────────────────────────────┐
│ Rebuild UI (setState)            │
│ Rebuild Messages (ListView)      │
└──────────────────────────────────┘
           │
           ↓
    MESSAGE DISPLAYED IN CHAT
```

## Component Hierarchy

```
ChatUI (StatefulWidget)
│
├── _ChatUIState
│   │
│   ├── _buildSidebar()
│   │   └── User List
│   │
│   ├── _buildChatArea()
│   │   │
│   │   ├── _buildChatHeader()
│   │   │   └── Selected User Info
│   │   │
│   │   ├── _buildMessages()
│   │   │   └── ListView
│   │   │       └── ForEach Message
│   │   │           ├── Message Text
│   │   │           └── MessageAttachmentsWidget  ← Displays attachments
│   │   │               ├── Image Display
│   │   │               ├── Video Display
│   │   │               └── File Display
│   │   │
│   │   └── _buildInputArea()
│   │       ├── AttachmentPreviewWidget  ← Shows preview
│   │       │   ├── Image Thumbnail
│   │       │   ├── Video Icon
│   │       │   └── File Card
│   │       └── Input Row
│   │           ├── Attach Button (📎)
│   │           ├── TextField
│   │           └── Send Button (➤)
│   │
│   └── _showAttachmentOptions()
│       └── AttachmentBottomSheet
│           ├── Images Option
│           ├── Videos Option
│           └── Files Option
│
└── AttachmentService (Utility)
    ├── pickImages()
    ├── pickVideos()
    ├── pickFiles()
    └── _convertToAttachments()
```

## State Management Flow

```
┌─────────────────────────────────┐
│     ChatUI State (_ChatUIState)  │
├─────────────────────────────────┤
│ Variables:                       │
│ • _controller (TextEditingCtrl)  │
│ • _selectedAttachments (List)    │
│ • selectedUser (ChatUser)        │
│ • users (List<ChatUser>)         │
│ • messages (List<ChatMessage>)   │
└─────────────────────────────────┘
         │
    ┌────┴─────────────────┐
    ↓                      ↓
ATTACH FILE           SEND MESSAGE
    │                      │
    ├──► Update            ├──► Create
    │    _selectedAt       │    ChatMessage
    │    tachments         │
    │                      ├──► Add to
    │                      │    messages
    │                      │
    ├──► setState()◄───────┘
    │
    └──► Rebuild UI
```

## Message with Attachments Structure

```
ChatMessage {
  message: String      // "Check this out!"
  isMe: bool          // true
  time: DateTime      // 2024-01-30 15:45:30
  attachments: [      // List of files
    ChatAttachment {
      filePath: String      // "/storage/photos/img.jpg"
      fileName: String      // "img.jpg"
      fileType: String      // "image"
      fileSize: int         // 2048576
      uploadedAt: DateTime  // 2024-01-30 15:45:20
    },
    ChatAttachment {
      filePath: String      // "/storage/files/doc.pdf"
      fileName: String      // "document.pdf"
      fileType: String      // "file"
      fileSize: int         // 1024000
      uploadedAt: DateTime  // 2024-01-30 15:45:21
    }
  ]
}
```

## Widget Rendering Flow

```
┌─────────────────────────┐
│  Chat Message Display   │
└─────────────────────────┘
         │
         ↓
    CHECK IF isMe
    ├──► TRUE (right align, blue)
    └──► FALSE (left align, gray)
         │
         ↓
    CREATE MESSAGE BUBBLE
    ├──► Background Color
    └──► Border Radius
         │
         ↓
    HAS ATTACHMENTS?
    ├──► YES
    │   └──► MessageAttachmentsWidget
    │       └──► Render each attachment
    │           ├──► isImage?
    │           │   └──► Image.file()
    │           ├──► isVideo?
    │           │   └──► Video icon + name
    │           └──► isFile?
    │               └──► File card
    │
    └──► NO
        └──► Skip attachment section
         │
         ↓
    ADD MESSAGE TEXT
    │
    ↓
    ADD TIMESTAMP
    │
    ↓
RENDER COMPLETE MESSAGE
```

## File Type Detection Logic

```
INPUT: fileName = "document.pdf"
       │
       ↓
EXTRACT EXTENSION
       │
       ├──► "jpg", "jpeg", "png", "gif", "webp"?
       │   └──► fileType = "image"
       │       isImage = true
       │
       ├──► "mp4", "avi", "mov", "mkv", "flv"?
       │   └──► fileType = "video"
       │       isVideo = true
       │
       └──► OTHER?
           └──► fileType = "file"
```

## UI Layout Breakdown

```
┌─────────────────────────────────────────────────┐
│              CHAT APPLICATION                   │
├────────────┬──────────────────────────────────┤
│            │                                  │
│  SIDEBAR   │      CHAT AREA                   │
│ (280px)    │                                  │
│            │  ┌────────────────────────────┐  │
│ • John     │  │ John Deo                   │  │
│ • David    │  └────────────────────────────┘  │
│ • Deo      │                                  │
│            │  ┌────────────────────────────┐  │
│            │  │ Messages List              │  │
│            │  │                            │  │
│            │  │ [User] Message             │  │
│            │  │ [Me]   Text + 📷           │  │
│            │  │        [Video] name        │  │
│            │  │        [📄] doc  1.5MB     │  │
│            │  │                            │  │
│            │  │ [User] Text message        │  │
│            │  └────────────────────────────┘  │
│            │                                  │
│            │  ┌────────────────────────────┐  │
│            │  │ [📷] [📄] [📹]            │  │ ← Preview
│            │  │ [📎] [Type message] [➤]  │  │ ← Input
│            │  └────────────────────────────┘  │
│            │                                  │
└────────────┴──────────────────────────────────┘
```

---

This architecture makes the attachment feature:
- **Modular** - Each component has single responsibility
- **Scalable** - Easy to add more attachment types
- **Maintainable** - Clear data flow and separation of concerns
- **Testable** - Each piece can be tested independently
