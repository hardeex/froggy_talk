class RegisterRequest {
  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.countryCode,
  });

  final String fullName;
  final String email;
  final String phone;
  final String countryCode;

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'country_code': countryCode,
  };
}

class TopupRequest {
  const TopupRequest({required this.amount, required this.paymentMethodId});

  final double amount;
  final String paymentMethodId;

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'payment_method_id': paymentMethodId,
  };
}
