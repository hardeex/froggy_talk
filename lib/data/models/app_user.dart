import 'package:equatable/equatable.dart';
import 'country.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.country,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final Country country;
  final DateTime createdAt;

  String get firstName => fullName.split(' ').first;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    country: Country.fromJson(json['country'] as Map<String, dynamic>),
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'country': country.toJson(),
    'created_at': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, email];
}
