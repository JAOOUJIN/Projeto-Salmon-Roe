import 'package:flutter/material.dart';
import '../../models/sale_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderDetailsScreen extends StatelessWidget {
  final SaleModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Detalhes do Pedido",
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABEÇALHO COM LOGO E NOME 
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/logo2.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Salmon Roe Sushi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Pedido #${order.saleCode}",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            //  STATUS E HORÁRIO 
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "STATUS DO PEDIDO",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: _getStatusColor(order.status),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _translateStatus(order.status),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _getStatusColor(order.status),
                        ),
                      ),
                      const Spacer(),
                      // Horário da conclusão 
                      Text(
                        "${order.date.hour}:${order.date.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // ITENS COM IMAGEM 
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ITENS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 30),
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "${item.quantity.toInt()}x",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.productName ?? "Produto",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          if (item.productImageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.productImageUrl!,
                                width: 45,
                                height: 45,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // ENTREGA E PAGAMENTO 
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoSection(
                    icon: Icons.location_on_outlined,
                    title: "Endereço de entrega",
                    content: w
                  ),
                  const SizedBox(height: 20),
                  _infoSection(
                    icon: FontAwesomeIcons.creditCard,
                    title: "Forma de pagamento",
                    content: "Pagar quando chegar",
                  ),
                ],
              ),
            ),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // --- 5. RESUMO DE VALORES ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSummaryRow(
                    "Subtotal",
                    "R\$ ${order.totalValue.toStringAsFixed(2).replaceAll('.', ',')}",
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow("Taxa de entrega", "Grátis", isGreen: true),
                  const SizedBox(height: 15),
                  _buildSummaryRow(
                    "Total",
                    "R\$ ${order.totalValue.toStringAsFixed(2).replaceAll('.', ',')}",
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _infoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String title,
    String value, {
    bool isBold = false,
    bool isGreen = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isGreen ? Colors.green : Colors.black,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'delivered') return Colors.green;
    if (status == 'cancelled') return Colors.red;
    return const Color(0xFFFF4C4C);
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'delivered':
        return 'Pedido concluído';
      case 'cancelled':
        return 'Pedido cancelado';
      case 'on_the_way':
        return 'A caminho';
      case 'shipped':
        return 'Em preparo';
      default:
        return 'Em andamento';
    }
  }
}
