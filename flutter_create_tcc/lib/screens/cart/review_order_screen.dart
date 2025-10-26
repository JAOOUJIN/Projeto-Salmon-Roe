import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';

class ReviewOrderScreen extends StatefulWidget {
  const ReviewOrderScreen({super.key});

  @override
  State<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  String selectedPayment = "Pagar quando chegar";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Recebe argumentos da tela anterior
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
      }
    });
  }

  void _showReviewModal() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final address = args?['address'] ?? "Endereço não selecionado";
    final delivery = args?['delivery'] ?? "Entrega padrão";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Revisar Pedido",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text("Endereço: $address"),
              Text("Entrega: $delivery"),
              Text("Pagamento: $selectedPayment"),
              Text("Total: R\$ ${cartProvider.totalPrice.toStringAsFixed(2)}"),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _createSale(cartProvider, authProvider),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Fazer Pedido"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); 
                      },
                      child: const Text("Alterar Pedido"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createSale(
    CartProvider cartProvider,
    AuthProvider authProvider,
  ) async {
    setState(() => _isLoading = true);

    // Gera um código de venda único 
    final saleCode = DateTime.now().millisecondsSinceEpoch;

    final result = await cartProvider.createSale(authProvider.token!, saleCode);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pop(context); // Fecha modal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pedido realizado com sucesso!")),
      );
      Navigator.popUntil(context, ModalRoute.withName('/menuClient')); 
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: ${result['error']}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Revisar Pedido'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Forma de Pagamento",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red),
              ),
              child: const ListTile(
                title: Text("Pagar quando chegar"),
                subtitle: Text("Pagamento na entrega"),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Resumo do Pedido",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...cartProvider.items.map((item) {
              final product = item['product'];
              final quantity = item['quantity'];
              return ListTile(
                title: Text(product.name),
                subtitle: Text("Quantidade: $quantity"),
                trailing: Text(
                  "R\$ ${(product.price * quantity).toStringAsFixed(2)}",
                ),
              );
            }),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "R\$ ${cartProvider.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _showReviewModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Revisar Pedido",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
