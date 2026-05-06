import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:secondhand_app/config/theme.dart';
import 'package:secondhand_app/providers/notification_provider.dart';
import 'package:secondhand_app/widgets/common/loading_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thong bao'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) => TextButton(
              onPressed: provider.notifications.isEmpty ? null : provider.markAllRead,
              child: const Text('Doc het', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const LoadingWidget();
          }
          if (provider.notifications.isEmpty) {
            return const EmptyWidget(
              message: 'Chua co thong bao nao',
              icon: Icons.notifications_none,
            );
          }
          return ListView.separated(
            itemCount: provider.notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = provider.notifications[index];
              return ListTile(
                tileColor: item.isRead ? null : AppTheme.primaryColor.withOpacity(0.06),
                leading: CircleAvatar(
                  backgroundColor: item.isRead ? Colors.grey.shade300 : AppTheme.primaryColor,
                  child: Icon(
                    item.isRead ? Icons.notifications_none : Icons.notifications,
                    color: item.isRead ? Colors.grey.shade700 : Colors.white,
                  ),
                ),
                title: Text(item.title ?? 'Thong bao', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((item.content ?? '').isNotEmpty) Text(item.content!),
                    const SizedBox(height: 4),
                    Text(
                      timeago.format(item.createdAt, locale: 'vi'),
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                    ),
                  ],
                ),
                trailing: item.isRead
                    ? null
                    : const Icon(Icons.fiber_manual_record, color: AppTheme.primaryColor, size: 12),
                onTap: item.isRead ? null : () => provider.markRead(item.id),
              );
            },
          );
        },
      ),
    );
  }
}
