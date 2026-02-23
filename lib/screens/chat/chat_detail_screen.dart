import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../services/chat_service.dart';
import '../../controllers/paginated_controller.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  const ChatDetailScreen({super.key, required this.chatId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final PaginatedController<RecordModel> _controller;
  final _chatService = ChatService.instance;

  @override
  void initState() {
    super.initState();
    _initController();
    _chatService.subscribeToMessages(widget.chatId, (msg) {
      if (mounted) {
        _controller.insertAtTop(msg);
        _chatService.markAsRead(widget.chatId);
      }
    });
  }

  void _initController() {
    _controller = PaginatedController<RecordModel>(
      fetcher: (page, perPage) => _chatService.getMessages(widget.chatId, page: page, perPage: perPage),
      mapper: (r) => r,
    );
    _controller.loadInitial().then((_) => _chatService.markAsRead(widget.chatId));
  }

  @override
  void dispose() {
    _chatService.unsubscribeFromMessages(widget.chatId);
    _messageController.dispose();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendText() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    await _chatService.sendMessage(widget.chatId, content: text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(child: Container()), // Placeholder for messages list
           _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.image), onPressed: () {}),
          Expanded(child: TextField(controller: _messageController)),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendText),
        ],
      ),
    );
  }
}
