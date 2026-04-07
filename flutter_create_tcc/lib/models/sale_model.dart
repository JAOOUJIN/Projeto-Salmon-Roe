// SaleModel & SaleItem: Estes arquivos definem a estrutura de como as informações de uma venda
// são organizadas (Venda e seus Itens)
// Eles são usados para enviar dados de uma nova venda para o servidor e para ler o histórico de vendas

// --- Item da Venda  ---
class SaleItem {
  final String productId;
  final int quantity;
  final double? unitPrice; 
  final String? productName;
  final String? productImageUrl;

  SaleItem({
    required this.productId,
    required this.quantity,
    this.unitPrice,
    this.productName,
    this.productImageUrl,
  });

  // Prepara o item para ser enviado à API (POST /sales)
  Map<String, dynamic> toJson() {
    return {'cd_produto': productId, 'qt_item': quantity, 'vl_unitario': unitPrice};
  }

  // Constrói o item a partir do JSON recebido do Backend Node (com populate)
  factory SaleItem.fromJson(Map<String, dynamic> item) {
    // cd_produto vira um Map com os dados do produto
    final productData = item['cd_produto'];

    String id = '';
    String? name;
    String? imageUrl;

    if (productData is Map<String, dynamic>) {
      // Caso populado: extrai os dados usando as chaves canônicas do seu ProductModel
      id = productData['_id']?.toString() ?? '';
      name = productData['name_produto'];
      imageUrl = productData['image_url'];
    } else {
      // Caso não populado: o campo contém apenas a String do ID
      id = productData?.toString() ?? '';
    }

    return SaleItem(
      productId: id,
      quantity: (item['qt_item'] ?? 0).toInt(),
      unitPrice: (item['vl_unitario'] ?? 0).toDouble(),
      productName: name,
      productImageUrl: imageUrl,
    );
  }
}

// --- Modelo Principal da Venda ---
class SaleModel {
  // Atributos principais que definem a transação de venda
  final int saleCode;
  final double totalValue;
  final DateTime date;
  final String status;
  final List<SaleItem> items; // Lista de todos os itens vendidos.
  final String address; // Endereço de entrega
  final String delivery; // Método de entrega
  final String payment; // Método de pagamento

  SaleModel({
    required this.saleCode,
    required this.totalValue,
    required this.date,
    required this.status,
    required this.items,
    required this.address,
    required this.delivery,
    required this.payment,
  });

  // Constrói um objeto SaleModel a partir dos dados (Map/JSON) recebidos do servidor
  factory SaleModel.fromJson(Map<String, dynamic> json) {
    DateTime utcDate = DateTime.parse(json['createdAt']);
    DateTime brazilDate = utcDate.subtract(const Duration(hours: 3));

    return SaleModel(
      saleCode:
          json['cd_venda'] ?? 0, // Pega o código da venda. Se for nulo, usa 0.
      // Pega o valor total. Se for nulo, usa 0. Converte para número decimal (double)
      totalValue: (json['vl_venda'] ?? 0).toDouble(),
      // Converte a data de texto (string) para o formato de data (DateTime)
      date: brazilDate,
      status:
          json['status'] ?? 'pending', // Novo: pega o status, padrão 'pending'
      // Mapeia a lista de itens:
      // 1. Tenta obter a lista 'itens' e, se for nula, usa uma lista vazia.
      items: (json['itens'] as List<dynamic>? ?? [])
          .map((item) => SaleItem.fromJson(item))
          .toList(),
      address: json['address'] ?? '',
      delivery: json['delivery'] ?? '',
      payment: json['payment'] ?? '',
    );
  }
}
