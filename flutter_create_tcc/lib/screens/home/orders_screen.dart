import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sale_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/orders/active_order_card.dart';
import '../../widgets/orders/order_card.dart';
import 'orders_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOrders();
    });
  }

  Future<void> _refreshOrders() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    if (auth.token != null) {
      await Future.wait([
        ordersProvider.fetchOrders(auth.token!),
        ordersProvider.fetchLastOrderStatus(auth.token!),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'Meus Pedidos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4C4C)),
            );
          }

          if (provider.errorMessage.isNotEmpty && provider.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: _refreshOrders,
                      child: const Text("Tentar novamente"),
                    ),
                  ],
                ),
              ),
            );
          }

          final activeOrders = provider.orders
              .where(
                (order) =>
                    order.status != 'delivered' && order.status != 'cancelled',
              )
              .toList();

          return RefreshIndicator(
            onRefresh: _refreshOrders,
            color: const Color(0xFFFF4C4C),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // SEÇÃO DE PEDIDOS ATIVOS (Múltiplos)
                if (activeOrders.isNotEmpty) ...[
                  Text(
                    activeOrders.length > 1
                        ? "Pedidos em andamento"
                        : "Pedido em andamento",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...activeOrders
                      .map(
                        (order) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ActiveOrderCard(
                            order: order,
                            onTap: () => _navigateToDetails(order),
                          ),
                        ),
                      ),
                  const SizedBox(height: 12),
                ],

                // SEÇÃO DE HISTÓRICO
                const Text(
                  "Histórico",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (provider.orders.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text("Você ainda não fez nenhum pedido."),
                    ),
                  )
                else
                  ...provider.orders
                      .where(
                        (order) =>
                            order.status == 'delivered' ||
                            order.status == 'cancelled',
                      )
                      .map(
                        (order) => OrderCard(
                          order: order,
                          onTap: () => _navigateToDetails(order),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetails(SaleModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
    ).then((_) => _refreshOrders());
  }
}
