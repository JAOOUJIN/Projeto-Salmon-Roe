import 'package:flutter_create_tcc/models/address_model.dart';

class UserModel {
  final String id;
  final String email;
  final String? phone;
  final String? name;
  final String? cpf;
  final List<AddressModel>? addresses;

  UserModel({
    required this.id,
    required this.email,
    this.phone,
    this.name,
    this.cpf,
    this.addresses = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'],
      cpf: json['cpf'],
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => AddressModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'cpf': cpf,
      'addresses': addresses?.map((e) => e.toJson()).toList(),
    };
  }

  // Método copyWith adicionado
  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    String? cpf,
    List<AddressModel>? addresses,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      addresses: addresses ?? this.addresses,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, phone: $phone, name: $name, cpf: $cpf, addresses: $addresses)';
}