import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';
import '../services/notification_services.dart';
import '../providers/orders_provider.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationModel> _items = [];
  final NotificationServices _notificationService = NotificationServices();

  List<NotificationModel> get items => [..._items];

  int get unreadCount => _items.where((item) => !item.isRead).length;

  // Inicia a escuta do Firebase e popula a lista automaticamente
  void configurarOuvinte(OrdersProvider ordersProvider, String token) {
    _notificationService.onMessageStream.listen((RemoteMessage message) {
      print("NOTIF_PROVIDER: Mensagem recebida via Stream");

      // Tenta pegar o título e corpo da notificação padrão
      String title = message.notification?.title ?? "Salmon Roe";
      String body =
          message.notification?.body ?? "O status do seu pedido mudou.";

      // Se a mensagem tiver dados personalizados, podemos usá-los para criar uma notificação mais específica
      if (message.data['type'] == 'order_status') {
        ordersProvider.fetchOrders(
          token,
        ); // Isso atualiza a lista na OrdersScreen
        ordersProvider.fetchLastOrderStatus(
          token,
        ); // Isso atualiza o card da Home
      }

      addNotification(title, body);
    });
  }

  void addNotification(String title, String body) {
    _items.insert(
      0,
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void markAsRead() {
    for (var item in _items) {
      item.isRead = true;
    }
    notifyListeners();
  }

  // Limpa a lista (útil no logout)
  void clearNotifications() {
    _items.clear();
    notifyListeners();
  }
}
