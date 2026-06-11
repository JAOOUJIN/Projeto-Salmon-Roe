class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime dateTime;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.dateTime,
    this.isRead = false,
  });

  factory NotificationModel.fromFirebase(Map<String, dynamic> data) {
    DateTime now = DateTime.now();
    DateTime brazilDate = now.subtract(const Duration(hours: 3));

    return NotificationModel(
      id: data['saleId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title'] ?? 'Salmon Roe',
      body: data['body'] ?? 'Atualização no seu pedido',
      dateTime: brazilDate,
      isRead: false,
    );
  }

  // Propriedade para formatar a hora no formato "HH:mm"
  String get formattedTime {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
}
