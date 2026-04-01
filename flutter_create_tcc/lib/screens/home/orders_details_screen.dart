import 'package:flutter/material.dart';
import '../../models/sale_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/orders/order_details_widgets.dart';
import '../../widgets/orders/order_utils.dart';

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
            // CABEÇALHO (LOGO E NOME)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      image: DecorationImage(
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

            // STATUS E HORÁRIO 
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
                        OrderUtils.getStatusIcon(order.status),
                        color: OrderUtils.getStatusColor(order.status),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        OrderUtils.translateStatus(order.status),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: OrderUtils.getStatusColor(order.status),
                        ),
                      ),
                      const Spacer(),
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

            // LISTA DE ITENS
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
                          // Tratamento de imagem para evitar erro de URL vazia
                          if (item.productImageUrl != null &&
                              item.productImageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.productImageUrl!,
                                width: 45,
                                height: 45,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.fastfood,
                                  color: Colors.grey,
                                ),
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
                children: [
                  Builder(
                    builder: (context) {
                      return Column(
                        children: [
                          InfoSection(
                            icon: Icons.location_on_outlined,
                            title: "Endereço de entrega",
                            content: order.address,
                          ),
                          const SizedBox(height: 20),
                          InfoSection(
                            icon: FontAwesomeIcons.creditCard,
                            title: "Forma de pagamento",
                            content: order.payment,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // RESUMO DE VALORES 
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SummaryRow(
                    title: "Subtotal",
                    value:
                        "R\$ ${order.totalValue.toStringAsFixed(2).replaceAll('.', ',')}",
                  ),
                  const SummaryRow(
                    title: "Taxa de entrega",
                    value: "Grátis",
                    isGreen: true,
                  ),
                  const SizedBox(height: 8),
                  SummaryRow(
                    title: "Total",
                    value:
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
}
