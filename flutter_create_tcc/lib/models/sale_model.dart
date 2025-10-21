class SaleItem {
  final String productId;
  final int quantity;

  SaleItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'cd_produto': productId, 'qt_item': quantity};
  }
}

class SaleModel {
  final int saleCode;
  final double totalValue;
  final DateTime date;
  final List<SaleItem> items;

  SaleModel({
    required this.saleCode,
    required this.totalValue,
    required this.date,
    required this.items,
  });
  
  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      saleCode: json['cd_venda'] ?? 0,
      totalValue: (json['vl_venda'] ?? 0).toDouble(),
      date: DateTime.parse(json['dt_emissao']),
      items: (json['itens'] as List<dynamic>? ?? [])
          .map(
            (item) => SaleItem(
              productId: item['cd_produto']['_id'] ?? '',
              quantity: item['qt_item'] ?? 0,
            ),
          )
          .toList(),
    );
  }
}
