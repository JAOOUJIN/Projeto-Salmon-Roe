// SaleModel & SaleItem: Estes arquivos definem a estrutura de como as informações de uma venda
// são organizadas (Venda e seus Itens)
// Eles são usados para enviar dados de uma nova venda para o servidor e para ler o histórico de vendas

// --- Item da Venda (O que foi comprado) ---
class SaleItem {
  final String productId; // O ID único do produto vendido.
  final int quantity; // A quantidade desse produto na venda.

  SaleItem({required this.productId, required this.quantity});

  // Prepara o item da venda para ser enviado como JSON na requisição à API
  Map<String, dynamic> toJson() {
    return {
      'cd_produto': productId, // O servidor o ID como 'cd_produto'
      'qt_item': quantity,
    }; // O servidor espera 'qt_item' para quantidade
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

  SaleModel({
    required this.saleCode,
    required this.totalValue,
    required this.date,
    required this.status,
    required this.items,
  });

  // Constrói um objeto SaleModel a partir dos dados (Map/JSON) recebidos do servidor
  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      saleCode:
          json['cd_venda'] ?? 0, // Pega o código da venda. Se for nulo, usa 0.
      // Pega o valor total. Se for nulo, usa 0. Converte para número decimal (double)
      totalValue: (json['vl_venda'] ?? 0).toDouble(),
      // Converte a data de texto (string) para o formato de data (DateTime)
      date: DateTime.parse(json['createdAt']),
      status: json['status'] ?? 'pending', // Novo: pega o status, padrão 'pending'
      // Mapeia a lista de itens:
      // 1. Tenta obter a lista 'itens' e, se for nula, usa uma lista vazia.
      items: (json['itens'] as List<dynamic>? ?? [])
          .map(
            // 2. Para cada item da lista, cria um novo objeto SaleItem.
            (item) => SaleItem(
              // O ID do produto está aninhado dentro de 'cd_produto'.
              productId: item['cd_produto']['_id'] ?? '',
              quantity: item['qt_item'] ?? 0,
            ),
          )
          .toList(), // 3. Converte o resultado de volta para uma lista.
    );
  }
}
