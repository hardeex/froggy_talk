import 'package:equatable/equatable.dart';

enum ActivityType { topUp, callCreditUsed, paymentSent }

enum ActivityStatus { success, failed, pending }

extension ActivityTypeX on ActivityType {
  String get label => switch (this) {
    ActivityType.topUp => 'Top-Up',
    ActivityType.callCreditUsed => 'Call Credit Used',
    ActivityType.paymentSent => 'Payment Sent',
  };

  String get icon => switch (this) {
    ActivityType.topUp => '⬆️',
    ActivityType.callCreditUsed => '📞',
    ActivityType.paymentSent => '💸',
  };

  bool get isCredit => this == ActivityType.topUp;
}

extension ActivityStatusX on ActivityStatus {
  String get label => switch (this) {
    ActivityStatus.success => 'Success',
    ActivityStatus.failed => 'Failed',
    ActivityStatus.pending => 'Pending',
  };
}

class WalletActivity extends Equatable {
  const WalletActivity({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.currencySymbol,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final ActivityType type;
  final ActivityStatus status;
  final double amount;
  final String currencySymbol;
  final String description;
  final DateTime createdAt;

  factory WalletActivity.fromJson(Map<String, dynamic> json) => WalletActivity(
    id: json['id'] as String,
    type: ActivityType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => ActivityType.topUp,
    ),
    status: ActivityStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => ActivityStatus.pending,
    ),
    amount: (json['amount'] as num).toDouble(),
    currencySymbol: json['currency_symbol'] as String,
    description: json['description'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'status': status.name,
    'amount': amount,
    'currency_symbol': currencySymbol,
    'description': description,
    'created_at': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id];
}
