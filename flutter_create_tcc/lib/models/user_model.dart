class UserModel {
  final String id;
  final String email;
  final String? phone;
  final String? name;
  final String? cpf;

  UserModel({
    required this.id,
    required this.email,
    this.phone,
    this.name,
    this.cpf,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      name: json['name'],
      cpf: json['cpf'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'cpf': cpf,
    };
  }

  @override
  String toString() => 'User(id: $id, email: $email, phone: $phone, name: $name, cpf: $cpf)';
}
