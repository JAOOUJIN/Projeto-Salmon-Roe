import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification_provider.dart';

class ManageNotificationsScreen extends StatelessWidget {
  const ManageNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();

    const primaryColor = Color(0xFFFF4C4C);
    const titleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
    const subtitleStyle = TextStyle(
      color: Colors.grey,
      fontSize: 14,
      height: 1.4,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "GERENCIAR NOTIFICAÇÕES",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Comunicações de pedidos", style: titleStyle),
            const SizedBox(height: 8),
            const Text(
              "Notificações sobre os pedidos são importantes para acompanhar as etapas do seu pedido em tempo real.",
              style: subtitleStyle,
            ),
            const SizedBox(height: 16),

            // O SWITCH QUE CONTROLA TUDO
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text(
                  "Notificações no app",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  notificationProvider.notificationsEnabled
                      ? "Você receberá avisos visuais"
                      : "Atualizações serão apenas silenciosas",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                value: notificationProvider.notificationsEnabled,
                activeThumbColor: Colors.white,
                activeTrackColor: primaryColor,
                onChanged: (bool value) {
                  // Chama o método no Provider
                  notificationProvider.setNotificationsEnabled(value);
                },
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // Informação de rodapé para o usuário entender o comportamento
            Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.grey[400]),
                const SizedBox(width: 8),
                const Text(
                  "Como funciona?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Mesmo com as notificações desativadas, suas telas de pedidos e acompanhamento continuarão sendo atualizadas automaticamente sempre que houver uma mudança de status.",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
