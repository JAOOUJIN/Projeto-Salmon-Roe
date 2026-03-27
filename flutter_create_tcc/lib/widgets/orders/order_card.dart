import 'package:flutter/material.dart';
import '../../../models/sale_model.dart';
import 'order_widgets.dart';
import 'order_card_helpers.dart';

class OrderCard extends StatelessWidget {
  final SaleModel order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  // Traduz status
  String _translateStatus(String status) {
    if (status == 'delivered') return 'Pedido concluído';
    if (status == 'cancelled') return 'Pedido cancelado';
    return 'Em andamento';
  }

  // Cor do status
  Color _getStatusColor(String status) {
    if (status == 'delivered') return Colors.green;
    if (status == 'cancelled') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final items = order.items;

    return OrderCardContainer(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LOGO DO RESTAURANTE
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Image(image: AssetImage('assets/images/logo2.png')),
            ),
          ),

          const SizedBox(width: 12),

          // INFORMAÇÕES DO PEDIDO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NOME RESTAURANTE
                const Text(
                  "Salmon Roe ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                const SizedBox(height: 2),

                // NÚMERO DO PEDIDO
                Text(
                  "Pedido #${order.saleCode}",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),

                const SizedBox(height: 6),

                // LISTA DE ITENS
                ...buildItemsList(items),

                const SizedBox(height: 8),

                // STATUS
                Row(
                  children: [
                    Icon(
                      order.status == 'delivered'
                          ? Icons.check_circle
                          : order.status == 'cancelled'
                          ? Icons.cancel
                          : Icons.access_time,
                      size: 14,
                      color: _getStatusColor(order.status),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _translateStatus(order.status),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // DATA
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // DATA
              Text(
                "${order.date.day.toString().padLeft(2, '0')}/"
                "${order.date.month.toString().padLeft(2, '0')}/"
                "${order.date.year}",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),

              const SizedBox(height: 12),

              // IMAGENS DOS PRODUTOS
              SizedBox(
                width: 80,
                height: 45,
                child: Stack(
                  children: [
                    if (items.length > 1)
                      Positioned(
                        left: 0,
                        child: buildProductCircle(items[1].productImageUrl),
                      ),

                    Positioned(
                      right: 0,
                      child: buildProductCircle(
                        items.isNotEmpty ? items[0].productImageUrl : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
