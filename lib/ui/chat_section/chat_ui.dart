import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'chat_service.dart';
import 'chat_socket_service.dart';
import 'attachment_service.dart';
import 'attachment_components.dart';

// ─── Colour palette (matching the Teams-like screenshot) ──────────────────
const _kSidebarBg = Color(0xFF1F1F1F);
const _kSidebarSelected = Color(0xFF333333);
const _kSidebarText = Color(0xFFD6D6D6);
const _kSidebarSubText = Color(0xFF888888);
const _kSentBubble = Color(0xFF5B5FC7); // Teams-purple
const _kHeaderBg = Colors.white;
const _kBodyBg = Colors.white;
const _kInputBg = Color(0xFFF5F5F5);
const _kDivider = Color(0xFFE0E0E0);

class ChatUI extends StatefulWidget {
  const ChatUI({super.key});

  @override
  State<ChatUI> createState() => _ChatUIState();
}

class _ChatUIState extends State<ChatUI> with SingleTickerProviderStateMixin {
  // ── Sidebar state ──────────────────────────────────────────────────────
  List<ChatListItem> _chats = [];
  List<ChatListItem> _filtered = [];
  bool _chatsLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  // ── Right-panel state ──────────────────────────────────────────────────
  ChatListItem? _selectedChat;
  List<ServerMessage> _messages = [];
  bool _messagesLoading = false;
  late TabController _tabController;

  // ── Input state ────────────────────────────────────────────────────────
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  bool _showEmoji = false;
  bool _isSending = false;
  bool _isUploading = false;
  ServerMessage? _editingMsg;
  ServerMessage? _replyMsg;
  List<ChatAttachment> _pendingAttachments = [];

  // ── User credentials ───────────────────────────────────────────────────
  String _userId = '';
  String _userName = '';
  String _token = '';

  // ── Socket ────────────────────────────────────────────────────────────
  StreamSubscription<Map<String, dynamic>>? _socketSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchCtrl.addListener(_onSearch);
    _inputCtrl.addListener(() => setState(() {}));
    _inputFocus.addListener(() {
      if (_inputFocus.hasFocus && _showEmoji)
        setState(() => _showEmoji = false);
    });
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('mobileNo') ?? '';
    _userName = prefs.getString('userName') ?? 'Me';
    _token = prefs.getString('projectToken') ?? prefs.getString('masterToken') ?? prefs.getString('token') ?? '';
    if (_userId.isNotEmpty) ChatSocketService.connect(_userId);
    _socketSub = ChatSocketService.messageStream.listen(_onSocketMessage);
    await _loadChats();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _inputFocus.dispose();
    _tabController.dispose();
    _socketSub?.cancel();
    ChatSocketService.clearActiveChat();
    super.dispose();
  }

  // ── Chat list ────────────────────────────────────────────────────────

  Future<void> _loadChats() async {
    if (_userId.isEmpty) {
      setState(() => _chatsLoading = false);
      return;
    }
    setState(() => _chatsLoading = true);
    try {
      final list = await ChatService.getChatList(_userId);
      if (mounted)
        setState(() {
          _chats = list;
          _filtered = list;
          _chatsLoading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _chatsLoading = false);
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    print(q);
    setState(() {
      _filtered = q.isEmpty
          ? _chats
          : _chats
              .where((c) =>
                  c.name.toLowerCase().contains(q) ||
                  c.lastMessage.toLowerCase().contains(q))
              .toList();
    });
  }

  Future<void> _selectChat(ChatListItem chat) async {
    if (_selectedChat?.id == chat.id) return;
    ChatSocketService.clearActiveChat();
    setState(() {
      _selectedChat = chat;
      _messages = [];
      _messagesLoading = true;
      _editingMsg = null;
      _replyMsg = null;
      _pendingAttachments = [];
      _inputCtrl.clear();
      _tabController.index = 0;
    });
    ChatSocketService.setActiveChat(chatType: chat.type, chatId: chat.id);
    if (_userId.isNotEmpty) {
      ChatService.markChatAsRead(_userId, chat.type, chat.id);
      // Mark as read locally
      final idx = _chats.indexWhere((c) => c.id == chat.id);
      if (idx != -1) {
        setState(() {
          _chats[idx] = ChatListItem(
            id: _chats[idx].id,
            type: _chats[idx].type,
            name: _chats[idx].name,
            mobile: _chats[idx].mobile,
            otherUserId: _chats[idx].otherUserId,
            unreadCount: 0,
            lastMessage: _chats[idx].lastMessage,
            lastMessageTime: _chats[idx].lastMessageTime,
          );
          _filtered = _chats;
        });
      }
    }
    try {
      final msgs = await ChatService.getChatHistory(chat.type, chat.id);
      if (mounted) {
        setState(() {
          _messages = msgs;
          _messagesLoading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _messagesLoading = false);
    }
  }

  // ── Socket ───────────────────────────────────────────────────────────

  void _onSocketMessage(Map<String, dynamic> data) {
    final type = data['type']?.toString();

    // Handle new incoming chat message
    if (type == 'p2p' || type == 'group') {
      final senderId = data['senderId']?.toString() ?? '';
      if (senderId == _userId) return;

      // Update sidebar last message
      final chatId = _selectedChat?.id;
      bool isCurrentChat = false;
      if (_selectedChat != null) {
        if (type == 'group') {
          isCurrentChat = (data['to']?.toString() == chatId ||
              data['chatId']?.toString() == chatId);
        } else {
          isCurrentChat = senderId == _selectedChat!.otherUserId;
        }
      }

      if (isCurrentChat) {
        final msg = ServerMessage(
          id: data['id']?.toString() ??
              '${DateTime.now().millisecondsSinceEpoch}',
          senderId: senderId,
          senderName: data['senderName']?.toString() ?? '',
          content: data['content']?.toString() ?? '',
          timestamp: DateTime.now(),
          attachmentName: data['attachmentName']?.toString(),
          attachmentType: data['attachmentType']?.toString(),
          fileUrl: data['fileUrl']?.toString(),
          isEdited: false,
          replyToId: data['replyToId']?.toString(),
          replyToText: data['replyToText']?.toString(),
          replyToSender: data['replyToSender']?.toString(),
        );
        setState(() => _messages.add(msg));
        _scrollToBottom();
      } else {
        // Increment unread for the other chat in sidebar
        _loadChats();
      }
    }
  }

  // ── Send / Edit / Delete ──────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if ((text.isEmpty && _pendingAttachments.isEmpty) || _selectedChat == null)
      return;

    if (_editingMsg != null) {
      await _submitEdit(text);
      return;
    }

    setState(() => _isSending = true);
    try {
      String? upUrl, upName, upType;
      if (_pendingAttachments.isNotEmpty) {
        setState(() => _isUploading = true);
        final r = await ChatService.uploadFile(
          File(_pendingAttachments.first.filePath),
          _userId,
        );
        setState(() => _isUploading = false);
        if (r != null) {
          upUrl = r['fileUrl'];
          upName = r['fileName'];
          upType = r['fileType'];
        }
      }

      final optimistic = ServerMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}-$_userId',
        senderId: _userId,
        senderName: _userName,
        content: text,
        timestamp: DateTime.now(),
        attachmentName: upName,
        attachmentType: upType,
        fileUrl: upUrl,
        isEdited: false,
        replyToId: _replyMsg?.id,
        replyToText: _replyMsg?.content,
        replyToSender: _replyMsg?.senderName,
      );

      setState(() {
        _messages.add(optimistic);
        _inputCtrl.clear();
        _pendingAttachments.clear();
        _replyMsg = null;
        _isSending = false;
      });
      _scrollToBottom();

      // Update sidebar last message
      _updateSidebarLastMsg(_selectedChat!.id, text);

      if (_selectedChat!.type == 'group') {
        ChatSocketService.sendGroup(
          groupId: _selectedChat!.id,
          content: text,
          senderId: _userId,
          senderName: _userName,
          attachmentName: upName,
          attachmentType: upType,
          fileUrl: upUrl,
          replyToId: optimistic.replyToId,
          replyToText: optimistic.replyToText,
          replyToSender: optimistic.replyToSender,
        );
      } else {
        ChatSocketService.sendP2P(
          to: _selectedChat!.otherUserId ?? _selectedChat!.id,
          content: text,
          senderId: _userId,
          senderName: _userName,
          attachmentName: upName,
          attachmentType: upType,
          fileUrl: upUrl,
          replyToId: optimistic.replyToId,
          replyToText: optimistic.replyToText,
          replyToSender: optimistic.replyToSender,
        );
      }
    } catch (e) {
      setState(() {
        _isSending = false;
        _isUploading = false;
      });
    }
  }

  void _updateSidebarLastMsg(String chatId, String text) {
    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx == -1) return;
    final c = _chats[idx];
    final updated = ChatListItem(
      id: c.id,
      type: c.type,
      name: c.name,
      mobile: c.mobile,
      otherUserId: c.otherUserId,
      unreadCount: 0,
      lastMessage: text.isEmpty ? (c.lastMessage) : text,
      lastMessageTime: DateTime.now(),
    );
    setState(() {
      _chats[idx] = updated;
      _filtered = _chats;
    });
  }

  Future<void> _submitEdit(String newText) async {
    if (newText.isEmpty || _editingMsg == null || _selectedChat == null) return;
    final msg = _editingMsg!;
    setState(() {
      final idx = _messages.indexWhere((m) => m.id == msg.id);
      if (idx != -1) {
        _messages[idx] = ServerMessage(
          id: msg.id,
          senderId: msg.senderId,
          senderName: msg.senderName,
          content: newText,
          timestamp: msg.timestamp,
          attachmentName: msg.attachmentName,
          attachmentType: msg.attachmentType,
          fileUrl: msg.fileUrl,
          isEdited: true,
          replyToId: msg.replyToId,
          replyToText: msg.replyToText,
          replyToSender: msg.replyToSender,
        );
      }
      _editingMsg = null;
      _inputCtrl.clear();
      _isSending = false;
    });
    await ChatService.editMessage(
        msg.id, newText, _selectedChat!.type, _selectedChat!.id);
  }

  Future<void> _deleteMessage(ServerMessage msg) async {
    if (_selectedChat == null) return;
    setState(() => _messages.removeWhere((m) => m.id == msg.id));
    await ChatService.deleteMessage(
        msg.id, _selectedChat!.type, _selectedChat!.id);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  // ── Attachment picker ─────────────────────────────────────────────────

  void _pickAttachment() async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          0, MediaQuery.of(context).size.height - 200, 0, 0),
      color: Colors.white,
      items: const [
        PopupMenuItem(
            value: 'gallery',
            child: Row(children: [
              Icon(Icons.photo_library_outlined),
              SizedBox(width: 8),
              Text('Photo Gallery')
            ])),
        PopupMenuItem(
            value: 'docs',
            child: Row(children: [
              Icon(Icons.insert_drive_file_outlined),
              SizedBox(width: 8),
              Text('Documents')
            ])),
      ],
    );
    if (result == 'gallery') {
      final list = await AttachmentService.pickFromGallery();
      if (list.isNotEmpty && mounted)
        setState(() => _pendingAttachments.addAll(list));
    } else if (result == 'docs') {
      final list = await AttachmentService.pickDocuments();
      if (list.isNotEmpty && mounted)
        setState(() => _pendingAttachments.addAll(list));
    }
  }

  // ── Message context menu ──────────────────────────────────────────────

  void _showMsgMenu(BuildContext context, ServerMessage msg, Offset offset) {
    final isMe = msg.senderId == _userId;
    final items = <PopupMenuEntry<String>>[
      const PopupMenuItem(
          value: 'reply',
          child: Row(children: [
            Icon(Icons.reply, size: 18),
            SizedBox(width: 8),
            Text('Reply')
          ])),
      const PopupMenuItem(
          value: 'copy',
          child: Row(children: [
            Icon(Icons.copy, size: 18),
            SizedBox(width: 8),
            Text('Copy')
          ])),
      if (isMe) ...[
        const PopupMenuItem(
            value: 'edit',
            child: Row(children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Edit')
            ])),
        const PopupMenuDivider(),
        const PopupMenuItem(
            value: 'delete',
            child: Row(children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red))
            ])),
      ],
    ];
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy, offset.dx + 1, offset.dy + 1),
      color: Colors.white,
      items: items,
    ).then((val) {
      if (val == 'reply')
        setState(() {
          _replyMsg = msg;
          _inputFocus.requestFocus();
        });
      else if (val == 'copy') {
        Clipboard.setData(ClipboardData(text: msg.content));
      } else if (val == 'edit')
        setState(() {
          _editingMsg = msg;
          _inputCtrl.text = msg.content;
          _inputFocus.requestFocus();
        });
      else if (val == 'delete') _deleteMessage(msg);
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:${m} ${dt.hour < 12 ? 'AM' : 'PM'}';
  }

  String _fmtSidebarTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day)
      return _fmtTime(dt);
    return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}';
  }

  String _fmtDateSeparator(DateTime dt) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return '${days[dt.weekday - 1]} ${_fmtTime(dt)}';
  }

  bool _shouldShowDateSep(int index) {
    if (index == 0) return true;
    final prev = _messages[index - 1].timestamp;
    final curr = _messages[index].timestamp;
    return curr.difference(prev).inMinutes > 30;
  }

  // ══════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: _kBodyBg,
      body: Row(
        children: [
          _buildSidebar(),
          const VerticalDivider(
              width: 1, thickness: 1, color: Color(0xFF3A3A3A)),
          Expanded(
              child: _selectedChat == null
                  ? _buildEmptyState()
                  : _buildConversationPane()),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  LEFT SIDEBAR
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: _kSidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSidebarHeader(),
          _buildSidebarSearch(),
          _buildSidebarSectionLabel('Recent'),
          Expanded(child: _buildChatList()),
          _buildSidebarSectionLabel('Contacts'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text('Chat',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
          _sidebarIconBtn(Icons.filter_list, onTap: () {}),
          _sidebarIconBtn(Icons.videocam_outlined, onTap: () {}),
          _sidebarIconBtn(Icons.edit_outlined, onTap: () {}),
        ],
      ),
    );
  }

  Widget _sidebarIconBtn(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: _kSidebarSubText, size: 20),
      ),
    );
  }

  Widget _buildSidebarSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(6),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: _kSidebarSubText, size: 16),
            hintText: 'Search',
            hintStyle: TextStyle(color: _kSidebarSubText, fontSize: 13),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(label,
          style: TextStyle(
              color: _kSidebarSubText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4)),
    );
  }

  Widget _buildChatList() {
    if (_chatsLoading) {
      return const Center(
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white38)));
    }
    if (_filtered.isEmpty) {
      return Center(
          child: Text('No chats',
              style: TextStyle(color: _kSidebarSubText, fontSize: 13)));
    }
    return ListView.builder(
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _buildSidebarTile(_filtered[i]),
    );
  }

  Widget _buildSidebarTile(ChatListItem chat) {
    final selected = _selectedChat?.id == chat.id;
    return InkWell(
      onTap: () => _selectChat(chat),
      child: Container(
        color: selected ? _kSidebarSelected : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Stack(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _avatarColor(chat.name),
                child: Text(
                    chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF92C353),
                    shape: BoxShape.circle,
                    border: Border.all(color: _kSidebarBg, width: 1.5),
                  ),
                ),
              ),
            ]),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(chat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: chat.unreadCount > 0
                                  ? Colors.white
                                  : _kSidebarText,
                              fontSize: 13,
                              fontWeight: chat.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                    ),
                    Text(_fmtSidebarTime(chat.lastMessageTime),
                        style:
                            TextStyle(color: _kSidebarSubText, fontSize: 11)),
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    Expanded(
                      child: Text(chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: chat.unreadCount > 0
                                  ? _kSidebarText
                                  : _kSidebarSubText,
                              fontSize: 12)),
                    ),
                    if (chat.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6264A7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${chat.unreadCount}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF6264A7),
      Color(0xFF0078D4),
      Color(0xFF107C41),
      Color(0xFFD83B01),
      Color(0xFF8764B8),
      Color(0xFF038387),
    ];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  // ══════════════════════════════════════════════════════════════════════
  //  EMPTY STATE
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('Select a conversation to start chatting',
            style: TextStyle(color: Colors.grey[400], fontSize: 15)),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  CONVERSATION PANE
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildConversationPane() {
    final chat = _selectedChat!;
    return Column(
      children: [
        _buildConvHeader(chat),
        const Divider(height: 1, color: _kDivider),
        Expanded(child: _buildMessageArea()),
        _buildInputBar(),
        if (_showEmoji) _buildEmojiPanel(),
      ],
    );
  }

  Widget _buildConvHeader(ChatListItem chat) {
    return Container(
      color: _kHeaderBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              // Avatar with status ring
              Stack(children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _avatarColor(chat.name),
                  child: Text(
                      chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ),
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF92C353),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ]),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chat.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    Text(chat.type == 'group' ? 'Group' : 'Available',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.green)),
                  ],
                ),
              ),
              // Action icons
              // _headerAction(Icons.videocam_outlined),
              // _headerAction(Icons.phone_outlined),
              // _headerAction(Icons.person_add_outlined),
              // _headerAction(Icons.search),
              // _headerAction(Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 4),
          // Tabs: Chat | Files | Photos
          // TabBar(
          //   controller: _tabController,
          //   labelColor: const Color(0xFF6264A7),
          //   unselectedLabelColor: Colors.grey,
          //   indicatorColor: const Color(0xFF6264A7),
          //   indicatorWeight: 2,
          //   isScrollable: true,
          //   labelStyle:
          //       const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          //   unselectedLabelStyle: const TextStyle(fontSize: 13),
          //   tabs: const [
          //     Tab(text: 'Chat'),
          //     Tab(text: 'Files'),
          //     Tab(text: 'Photos')
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _headerAction(IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: Colors.grey[600]),
      ),
    );
  }

  // ── Messages ──────────────────────────────────────────────────────────

  Widget _buildMessageArea() {
    if (_messagesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_messages.isEmpty) {
      return Center(
        child: Text('No messages yet. Start a conversation!',
            style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      itemCount: _messages.length,
      itemBuilder: (ctx, i) {
        final msg = _messages[i];
        return Column(
          children: [
            if (_shouldShowDateSep(i)) _buildDateSeparator(msg.timestamp),
            _buildBubble(ctx, msg),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime dt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(_fmtDateSeparator(dt),
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.normal)),
      ),
    );
  }

  Widget _buildBubble(BuildContext ctx, ServerMessage msg) {
    final isMe = msg.senderId == _userId;

    return GestureDetector(
      onSecondaryTapDown: (d) => _showMsgMenu(ctx, msg, d.globalPosition),
      onLongPressStart: (d) => _showMsgMenu(ctx, msg, d.globalPosition),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              Tooltip(
                message: msg.senderName,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: _avatarColor(msg.senderName),
                  child: Text(
                    msg.senderName.isNotEmpty
                        ? msg.senderName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Sender name (for received messages only)
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 2),
                      child: Text(msg.senderName,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                    ),
                  // Bubble
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.55),
                    decoration: BoxDecoration(
                      color: isMe ? _kSentBubble : const Color(0xFFF3F2F1),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 2),
                        bottomRight: Radius.circular(isMe ? 2 : 12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Reply preview
                          if (msg.replyToText != null &&
                              msg.replyToText!.isNotEmpty)
                            _buildReplyPreview(msg, isMe),
                          // Attachment
                          if (msg.hasAttachment)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: ServerAttachmentWidget(
                                fileUrl: msg.fileUrl,
                                fileName: msg.attachmentName,
                                fileType: msg.attachmentType,
                              ),
                            ),
                          // Text
                          if (msg.content.isNotEmpty)
                            SelectableText(
                              msg.content,
                              style: TextStyle(
                                  fontSize: 13.5,
                                  color: isMe ? Colors.white : Colors.black87,
                                  height: 1.4),
                            ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _fmtTime(msg.timestamp),
                                style: TextStyle(
                                    fontSize: 10,
                                    color: isMe
                                        ? Colors.white60
                                        : Colors.grey[500]),
                              ),
                              if (msg.isEdited)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text('(edited)',
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: isMe
                                              ? Colors.white54
                                              : Colors.grey[400],
                                          fontStyle: FontStyle.italic)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isMe) const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview(ServerMessage msg, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
      decoration: BoxDecoration(
        border: Border(
            left: BorderSide(
                color: isMe ? Colors.white54 : const Color(0xFF6264A7),
                width: 3)),
        color: isMe
            ? Colors.white.withOpacity(0.12)
            : Colors.grey.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(msg.replyToSender ?? '',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isMe ? Colors.white70 : const Color(0xFF6264A7))),
          Text(msg.replyToText ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12,
                  color: isMe ? Colors.white60 : Colors.grey[600])),
        ],
      ),
    );
  }

  // ── Input bar ─────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: _kInputBg,
        border: Border.all(color: _kDivider),
        borderRadius: BorderRadius.circular(6),
      ),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit banner
          if (_editingMsg != null)
            _inlineBanner(
              icon: Icons.edit,
              color: Colors.orange,
              text: 'Editing: ${_editingMsg!.content}',
              onClose: () => setState(() {
                _editingMsg = null;
                _inputCtrl.clear();
              }),
            ),
          // Reply banner
          if (_replyMsg != null)
            _inlineBanner(
              icon: Icons.reply,
              color: const Color(0xFF6264A7),
              text: '${_replyMsg!.senderName}: ${_replyMsg!.content}',
              onClose: () => setState(() => _replyMsg = null),
            ),
          // Attachment preview
          if (_pendingAttachments.isNotEmpty)
            AttachmentPreviewWidget(
              attachments: _pendingAttachments,
              onRemove: (i) => setState(() => _pendingAttachments.removeAt(i)),
            ),
          if (_isUploading)
            const LinearProgressIndicator(
                minHeight: 2, color: Color(0xFF6264A7)),
          // Text field
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  focusNode: _inputFocus,
                  maxLines: 6,
                  minLines: 1,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    hintStyle:
                        TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  textInputAction: TextInputAction.newline,
                ),
              ),
              // Toolbar icons
              _inputAction(Icons.emoji_emotions_outlined, onTap: () {
                if (_showEmoji) {
                  setState(() => _showEmoji = false);
                  _inputFocus.requestFocus();
                } else {
                  FocusScope.of(context).unfocus();
                  setState(() => _showEmoji = true);
                }
              }),
              _inputAction(Icons.image_outlined, onTap: () async {
                final list = await AttachmentService.pickFromGallery();
                if (list.isNotEmpty && mounted)
                  setState(() => _pendingAttachments.addAll(list));
              }),
              _inputAction(Icons.attach_file_outlined, onTap: _pickAttachment),
              _inputAction(Icons.add_circle_outline, onTap: () {}),
              // Send
              GestureDetector(
                onTap: (_isSending || _isUploading) ? null : _sendMessage,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (_inputCtrl.text.trim().isNotEmpty ||
                            _pendingAttachments.isNotEmpty)
                        ? const Color(0xFF6264A7)
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: _isSending
                      ? const Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Icon(Icons.send_rounded,
                          size: 16,
                          color: (_inputCtrl.text.trim().isNotEmpty ||
                                  _pendingAttachments.isNotEmpty)
                              ? Colors.white
                              : Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputAction(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: Colors.grey[600]),
      ),
    );
  }

  Widget _inlineBanner({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onClose,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border(bottom: BorderSide(color: color.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: color))),
          InkWell(
            onTap: onClose,
            child: Icon(Icons.close, size: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPanel() {
    return SizedBox(
      height: 300,
      child: EmojiPicker(
        onEmojiSelected: (_, emoji) {
          final pos = _inputCtrl.selection.baseOffset;
          final text = _inputCtrl.text;
          final newText = pos < 0
              ? text + emoji.emoji
              : text.substring(0, pos) + emoji.emoji + text.substring(pos);
          _inputCtrl.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(
                offset: (pos < 0 ? text.length : pos) + emoji.emoji.length),
          );
        },
        onBackspacePressed: () {
          if (_inputCtrl.text.isNotEmpty) {
            _inputCtrl.text = _inputCtrl.text.characters.skipLast(1).toString();
          }
        },
        config:
            const Config(checkPlatformCompatibility: true, emojiSizeMax: 26),
      ),
    );
  }
}
