class UserModel {
  final String id;
  final String email;
  final String? phone;
  final String? name;

  UserModel({
    required this.id,
    required this.email,
    this.phone,
    this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
    };
  }

  @override
  String toString() => 'User(id: $id, email: $email, phone: $phone, name: $name)';
}
