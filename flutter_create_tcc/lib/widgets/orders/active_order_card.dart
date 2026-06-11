import 'package:flutter/material.dart';
import '../../../models/sale_model.dart';
import 'order_widgets.dart';
import 'order_utils.dart';

class ActiveOrderCard extends StatefulWidget {
  final SaleModel order;
  final VoidCallback onTap;

  const ActiveOrderCard({super.key, required this.order, required this.onTap});

  @override
  State<ActiveOrderCard> createState() => _ActiveOrderCardState();
}

class _ActiveOrderCardState extends State<ActiveOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Função para mapear status para progresso (0.0 a 1.0)
  double _getProgress(String status) {
    switch (status) {
      case 'pending':
        return 0.2;
      case 'confirmed':
        return 0.4;
      case 'shipped':
        return 0.6;
      case 'on_the_way':
        return 0.8;
      case 'delivered':
        return 1.0;
      default:
        return 0.1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrderCardContainer(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: OrderUtils.getStatusColor(widget.order.status),
                child: Icon(
                  OrderUtils.getStatusIcon(widget.order.status),
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pedido #${widget.order.saleCode}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      OrderUtils.translateStatus(widget.order.status),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${widget.order.date.day.toString().padLeft(2, '0')}/${widget.order.date.month.toString().padLeft(2, '0')}",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnimatedProgress(_getProgress(widget.order.status)),
        ],
      ),
    );
  }

  Widget _buildAnimatedProgress(double progress) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                color: Colors.grey[200],
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  color: OrderUtils.getStatusColor(widget.order.status),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: progress,
                    child: SizedBox(
                      height: 8,
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [
                              _controller.value - 0.2,
                              _controller.value,
                              _controller.value + 0.2,
                            ],
                            colors: [
                              Colors.white.withValues(alpha: 0.5),
                              Colors.white.withValues(alpha: 0.5),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ).createShader(rect);
                        },
                        child: Container(
                          width: double.infinity,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
