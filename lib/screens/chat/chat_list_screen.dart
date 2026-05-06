import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:secondhand_app/config/theme.dart';
import 'package:secondhand_app/providers/chat_provider.dart';
import 'package:secondhand_app/widgets/common/loading_widget.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tin nhắn')),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.conversations.isEmpty) return const LoadingWidget();
          if (provider.conversations.isEmpty) {
            return const EmptyWidget(
              message: 'Chưa có cuộc trò chuyện nào\nHãy tìm sản phẩm và nhắn tin với người bán',
              icon: Icons.chat_bubble_outline,
            );
          }
          return ListView.separated(
            itemCount: provider.conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final conv = provider.conversations[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  backgroundImage: conv.otherUserAvatar != null
                      ? NetworkImage(conv.otherUserAvatar!)
                      : null,
                  child: conv.otherUserAvatar == null
                      ? Text(
                          conv.otherUserName.isNotEmpty ? conv.otherUserName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        conv.otherUserName,
                        style: TextStyle(
                          fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    Text(
                      timeago.format(conv.lastMessageTime, locale: 'vi'),
                      style: const TextStyle(color: AppTheme.textMedium, fontSize: 11),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conv.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: conv.unreadCount > 0 ? AppTheme.textDark : AppTheme.textMedium,
                        fontWeight: conv.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    Text(
                      '📦 ${conv.productTitle}',
                      style: const TextStyle(color: AppTheme.textMedium, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: conv.unreadCount > 0
                    ? Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          conv.unreadCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      )
                    : null,
                onTap: () => context.push('/chat/${conv.userId}/${conv.productId}'),
              );
            },
          );
        },
      ),
    );
  }
}
