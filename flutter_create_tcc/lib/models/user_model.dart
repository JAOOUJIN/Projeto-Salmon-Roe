// UserModel: Modelo de dados principal que representa um usuário na aplicação
// Contém as informações de perfil (nome, email, etc.) e o relacionamento com a lista de endereços
// Este modelo é usado para manter o estado do usuário logado (gerenciado pelo AuthProvider)

import 'package:flutter_create_tcc/models/address_model.dart';

class UserModel {
  // Atributos finais (final) garantem que o objeto de Usuário seja imutável
  // o que é crucial para a segurança e previsibilidade do estado
  final String id;
  final String email;
  final String? phone; // Campos opcionais, podem ser nulos
  final String? name;
  final String? cpf;
  final List<AddressModel>? addresses; // Lista de sub-modelos (endereços)
  final String? defaultAddressId; // ID do endereço marcado como padrão

  // Construtor principal. Define valores padrão seguros para listas (endereços)
  UserModel({
    required this.id,
    required this.email,
    this.phone,
    this.name,
    this.cpf,
    this.addresses =
        const [], // Garante que a lista comece como vazia se não for fornecida
    this.defaultAddressId,
  });

  // Constrói um objeto UserModel a partir dos dados (Map/JSON) recebidos do servidor
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Tenta buscar o ID usando '_id' ou 'id' (robustez)
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'],
      cpf: json['cpf'],
      // Processa a lista de endereços aninhada:
      addresses:
          (json['addresses'] as List<dynamic>?)
              // Mapeia cada item da lista para o modelo AddressModel.
              ?.map((e) => AddressModel.fromJson(e))
              .toList() ??
          [], // Se a lista for nula no JSON, retorna uma lista vazia.
      defaultAddressId: json['defaultAddressId'],
    );
  }

  // Converte o objeto UserModel para um Map (JSON), usado para salvar no disco
  // (SharedPreferences) ou enviar dados de atualização para o servidor
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'cpf': cpf,
      // Converte a lista de AddressModel de volta para uma lista de Maps (JSON)
      'addresses': addresses?.map((e) => e.toJson()).toList(),
      'defaultAddressId': defaultAddressId,
    };
  }

  // Método copyWith: Cria uma nova instância de UserModel com base na atual,
  // permitindo alterar apenas os campos desejados (mantendo a imutabilidade)
  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    String? cpf,
    List<AddressModel>? addresses,
    String? defaultAddressId,
  }) {
    return UserModel(
      // Usa o novo valor se fornecido; caso contrário, mantém o valor antigo ('this.id')
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      addresses: addresses ?? this.addresses,
      defaultAddressId: defaultAddressId ?? this.defaultAddressId,
    );
  }

  @override
  String toString() =>
      'User(id: $id, email: $email, phone: $phone, name: $name, cpf: $cpf, addresses: $addresses, defaultAddressId: $defaultAddressId)';
}
