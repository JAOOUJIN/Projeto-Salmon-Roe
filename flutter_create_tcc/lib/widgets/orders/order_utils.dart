import 'package:flutter/material.dart';

class OrderUtils {
  static String translateStatus(String status) {
    switch (status) {
      case 'pending': return 'Aguardando confirmação';
      case 'confirmed': return 'Pedido confirmado';
      case 'shipped': return 'Em preparo';
      case 'on_the_way': return 'A caminho';
      case 'delivered': return 'Pedido concluído';
      case 'cancelled': return 'Pedido cancelado';
      default: return 'Em andamento';
    }
  }

  static Color getStatusColor(String status) {
    if (status == 'delivered') return Colors.green;
    if (status == 'cancelled') return Colors.red;
    if (status == 'pending') return Colors.orange;
    return const Color(0xFFFF4C4C); 
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'confirmed': return Icons.receipt_long;
      case 'shipped': return Icons.restaurant;
      case 'on_the_way': return Icons.delivery_dining;
      case 'delivered': return Icons.check_circle;
      case 'cancelled': return Icons.cancel;
      default: return Icons.access_time;
    }
  }
}