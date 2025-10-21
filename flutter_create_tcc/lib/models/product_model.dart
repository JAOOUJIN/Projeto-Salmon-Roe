class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name_produto'] ?? '',
      description: json['ds_produto'] ?? '',
      price: (json['vl_produto'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name_produto': name,
      'ds_produto': description,
      'vl_produto': price,
    };
  }
}
