// AddressModel: Modelo de dados imutável (Value Object) que representa
// um endereço completo na aplicação.
// Fornece métodos para serialização e desserialização de/para JSON

class AddressModel {
  // Campos finais garantem que o objeto seja imutável após a criação,
  // o que facilita o gerenciamento do estado no Provider.
  final String id;
  final String street;
  final String number;
  final String city;
  final String state;
  final String zip;
  final String neighborhood;
  final String? complement; // Campo opcional (nullable)

  // Construtor principal para criação do objeto, garantindo a inicialização de campos obrigatórios
  AddressModel({
    required this.id,
    required this.street,
    required this.number,
    required this.city,
    required this.state,
    required this.zip,
    required this.neighborhood,
    this.complement,
  });

  // Construtor de fábrica (Factory) para criar uma instância a partir de um Map (JSON)
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      // Usa o operador '??' para fornecer um valor padrão ('') caso o campo esteja nulo ou ausente no JSON
      id: json['_id'] ?? '',
      street: json['street'] ?? '',
      number: json['number'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      zip: json['zip'] ?? '',
      complement: json['complement'] ?? '',
    );
  }

  // Converte a instância do modelo para um Map (JSON), pronto para ser enviado à API
  // ou salvo em SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'street': street,
      'number': number,
      'city': city,
      'state': state,
      'neighborhood': neighborhood,
      'zip': zip,
      'complement': complement,
    };
  }
}
