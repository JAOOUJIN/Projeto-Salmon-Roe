import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';
import '../services/notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/orders_provider.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationModel> _items = [];
  final NotificationServices _notificationService = NotificationServices();

  StreamSubscription<RemoteMessage>? _subscription;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  NotificationProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    notifyListeners();
  }

  // Método para a tela de configurações alternar o Switch
  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    notifyListeners();
  }

  List<NotificationModel> get items => [..._items];

  int get unreadCount => _items.where((item) => !item.isRead).length;

  /// Captura a notificação que abriu o app e a transforma em um card
  Future<void> verificarMensagemInicial(
    OrdersProvider ordersProvider,
    String token,
  ) async {
    // 1. Checa se o app abriu através de uma notificação (app estava fechado)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      _processarMensagemRemota(
        initialMessage,
        ordersProvider,
        token,
        "INICIAL",
      );
    }

    // 2. Escuta se o app foi aberto pela notificação mas estava em segundo plano (background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _processarMensagemRemota(
        message,
        ordersProvider,
        token,
        "BACKGROUND_CLICK",
      );
    });
  }

  /// Centraliza o processamento de mensagens para evitar repetição de código
  void _processarMensagemRemota(
    RemoteMessage message,
    OrdersProvider ordersProvider,
    String token,
    String origem,
  ) {
    print("NOTIF_PROVIDER: Processando mensagem via $origem");

    if (message.data['type'] == 'order_status') {
      ordersProvider.fetchOrders(token);
      ordersProvider.fetchLastOrderStatus(token);
    }

    // Só adiciona o card se estiver ativado
    if (_notificationsEnabled) {
      String title = message.notification?.title ?? "Salmon Roe";
      String body =
          message.notification?.body ?? "O status do seu pedido mudou.";
      addNotification(title, body);
    }
  }

  void configurarOuvinte(OrdersProvider ordersProvider, String token) {
    if (_subscription != null) {
      print("NOTIF_PROVIDER: Cancelando escuta duplicada...");
      _subscription!.cancel();
    }

    _subscription = _notificationService.onMessageStream.listen((
      RemoteMessage message,
    ) {
      _processarMensagemRemota(message, ordersProvider, token, "STREAM_ATIVA");
    });
  }

  void markAsReadSingle(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].isRead = true;
      notifyListeners();
    }
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
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
      print("NOTIF_PROVIDER: Escuta encerrada com sucesso.");
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
