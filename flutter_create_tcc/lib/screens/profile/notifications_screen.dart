import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/notification/notification_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificações", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all, color: Color(0xFFE15B1D)),
              onPressed: () => notificationProvider.markAsRead(),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("Nenhuma notificação por enquanto"))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return NotificationCard(notification: notifications[index]);
              },
            ),
    );
  }
}