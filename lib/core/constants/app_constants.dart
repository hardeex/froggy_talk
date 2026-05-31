class AppConstants {
  AppConstants._();

  // API Base URL (mocked — swap for real Laravel base)
  static const apiBaseUrl = 'https://api.froggytalk.app/api';

  // Shared Pref Keys
  static const prefKeyUser = 'current_user';
  static const prefKeyWallet = 'wallet_data';

  // Mock Delays
  static const mockDelay = Duration(milliseconds: 900);
  static const mockDelayLong = Duration(milliseconds: 1400);

  // Payment methods
  static const paymentMethods = [
    {'id': 'card', 'label': 'Debit / Credit Card', 'icon': '💳'},
    {'id': 'bank', 'label': 'Bank Transfer', 'icon': '🏦'},
    {'id': 'apple_pay', 'label': 'Apple Pay', 'icon': '🍎'},
    {'id': 'google_pay', 'label': 'Google Pay', 'icon': '🟡'},
  ];

  // Top-up presets by currency
  static const topupPresets = {
    'GBP': [5.0, 10.0, 20.0, 50.0, 100.0],
    'NGN': [500.0, 1000.0, 2000.0, 5000.0, 10000.0],
    'USD': [5.0, 10.0, 25.0, 50.0, 100.0],
    'GHS': [10.0, 20.0, 50.0, 100.0, 200.0],
    'KES': [100.0, 250.0, 500.0, 1000.0, 2500.0],
  };
}
