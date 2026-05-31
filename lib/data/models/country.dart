import 'package:equatable/equatable.dart';

class Country extends Equatable {
  const Country({
    required this.code,
    required this.name,
    required this.flag,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencyName,
    required this.phonePrefix,
  });

  final String code;
  final String name;
  final String flag;
  final String currencyCode;
  final String currencySymbol;
  final String currencyName;
  final String phonePrefix;

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    code: json['code'] as String,
    name: json['name'] as String,
    flag: json['flag'] as String,
    currencyCode: json['currency_code'] as String,
    currencySymbol: json['currency_symbol'] as String,
    currencyName: json['currency_name'] as String,
    phonePrefix: json['phone_prefix'] as String,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'flag': flag,
    'currency_code': currencyCode,
    'currency_symbol': currencySymbol,
    'currency_name': currencyName,
    'phone_prefix': phonePrefix,
  };

  @override
  List<Object?> get props => [code];
}
