// ProductModel: Modelo de dados imutável (Value Object) que representa um produto
// Este modelo é a fonte canônica para os atributos de um produto na aplicação,
// incluindo informações de preço, imagem e status de destaque/novidade

class ProductModel {
  // Atributos finais (final) garantem que o objeto seja imutável após a criação
  // Isso previne alterações de estado inesperadas e simplifica a gestão de dados
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double oldPrice;
  final bool isFeatured;
  final bool isNew;

  // Construtor principal para inicialização de todos os atributos obrigatórios
  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.oldPrice,
    required this.isFeatured,
    required this.isNew,
  });

  // Construtor de fábrica (Factory) para desserialização de Map (JSON) recebido do backend
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      // Mapeamento entre os nomes de campo do backend (JSON) e os nomes de campo do model
      // Usa o operador '??' para fornecer valores padrão seguros em caso de dados nulos ou ausentes
      id: json['_id'] ?? '',
      name: json['name_produto'] ?? '',
      description: json['ds_produto'] ?? '',
      imageUrl: json['image_url'] ?? '',
      // Converte o valor para double de forma segura.
      price: (json['vl_produto'] ?? 0).toDouble(),
      oldPrice: (json['vl_antigo'] ?? 0).toDouble(),
      // Valores booleanos com fallback para false
      isFeatured: json['is_destaque'] ?? false,
      isNew: json['is_novo'] ?? false,
    );
  }

  // Converte a instância do modelo para um Map (JSON), pronto para ser usado
  // em requisições à API ou armazenamento local
  Map<String, dynamic> toJson() {
    return {
      // Mapeamento inverso para os nomes de campo esperados pelo backend/serialização
      '_id': id,
      'name_produto': name,
      'ds_produto': description,
      'image_url': imageUrl,
      'vl_produto': price,
      'vl_antigo': oldPrice,
      'is_destaque': isFeatured,
      'is_novo': isNew,
    };
  }
}
