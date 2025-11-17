// Comente aqui explicando a funcionalidade do arquivo
// Este arquivo define o modelo ProductModel, que representa um produto com atributos como nome, descrição, URL da imagem, preço, preço antigo, destaque e novidade.

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double oldPrice;
  final bool isFeatured;
  final bool isNew;

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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name_produto'] ?? '',
      description: json['ds_produto'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: (json['vl_produto'] ?? 0).toDouble(),
      oldPrice: (json['vl_antigo'] ?? 0).toDouble(),
      isFeatured: json['is_destaque'] ?? false,
      isNew: json['is_novo'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
