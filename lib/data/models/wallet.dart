import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  const Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.currencyCode,
    required this.currencySymbol,
    required this.lastTopUpDate,
  });

  final String id;
  final String userId;
  final double balance;
  final String currencyCode;
  final String currencySymbol;
  final DateTime? lastTopUpDate;

  Wallet copyWith({
    double? balance,
    DateTime? lastTopUpDate,
  }) {
    return Wallet(
      id: id,
      userId: userId,
      balance: balance ?? this.balance,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      lastTopUpDate: lastTopUpDate ?? this.lastTopUpDate,
    );
  }

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    balance: (json['balance'] as num).toDouble(),
    currencyCode: json['currency_code'] as String,
    currencySymbol: json['currency_symbol'] as String,
    lastTopUpDate: json['last_top_up_date'] != null
        ? DateTime.parse(json['last_top_up_date'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'balance': balance,
    'currency_code': currencyCode,
    'currency_symbol': currencySymbol,
    'last_top_up_date': lastTopUpDate?.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, balance, currencyCode];
}
