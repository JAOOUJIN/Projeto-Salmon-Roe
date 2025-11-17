// Comente aqui explicando a funcionalidade do arquivo
// Este arquivo define o modelo AddressModel, que representa um endereço com atributos como rua, número, cidade, estado, CEP, bairro e complemento.

class AddressModel {
  final String id;
  final String street;
  final String number;
  final String city;
  final String state;
  final String zip;
  final String neighborhood;
  final String? complement;

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

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
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
