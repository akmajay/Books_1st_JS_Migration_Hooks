import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../widgets/shared/paginated_list_view.dart';
import '../../controllers/paginated_controller.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final PaginatedController<RecordModel> _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaginatedController<RecordModel>(
      fetcher: (page, perPage) => ChatService.instance.getChats(
        page: page,
        perPage: perPage,
      ),
      mapper: (record) => record,
    );
    _controller.loadInitial();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: PaginatedListView<RecordModel>(
        controller: _controller,
        itemBuilder: (chat, index) {
          final users = chat.get<List<RecordModel>>('expand.users');
          final otherUser = users.firstWhere(
            (u) => u.id != AuthService().currentUser?.id,
            orElse: () => RecordModel(), 
          );

          if (otherUser.id.isEmpty) return const SizedBox.shrink();

          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(otherUser.getStringValue('name').isEmpty ? 'User' : otherUser.getStringValue('name')),
            subtitle: Text(
              chat.getStringValue('expand.last_message.content').isEmpty ? 'No messages yet' : chat.getStringValue('expand.last_message.content'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => context.push('/chat/${chat.id}'),
          );
        },
      ),
    );
  }
}
