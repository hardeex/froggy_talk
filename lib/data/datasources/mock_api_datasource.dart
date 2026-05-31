import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/app_user.dart';
import '../models/country.dart';
import '../models/wallet.dart';
import '../models/wallet_activity.dart';
import '../models/requests.dart';

/// Simulates calls to:
///   POST /api/register
///   GET  /api/countries
///   GET  /api/wallet
///   GET  /api/wallet/activity
///   POST /api/wallet/topup
///
/// All methods throw typed [AppException] subclasses on failure —
/// exactly as a real HTTP layer would after parsing Laravel error responses.
class MockApiDataSource {
  final _uuid = const Uuid();

  // In-memory "database" scoped to the app session
  AppUser? _currentUser;
  Wallet? _wallet;
  final List<WalletActivity> _activities = [];

  // ── POST /api/register ────────────────────────────────────────────────────

  Future<AppUser> register(RegisterRequest req) async {
    await Future.delayed(AppConstants.mockDelayLong);

    // Simulate duplicate email validation
    if (_currentUser != null && _currentUser!.email == req.email) {
      throw const ValidationException(
        'This email address is already registered.',
        fieldErrors: {'email': 'Email already in use.'},
      );
    }

    final countries = await getCountries();
    final country = countries.firstWhere(
      (c) => c.code == req.countryCode,
      orElse: () => throw const ValidationException('Invalid country selected.'),
    );

    final userId = _uuid.v4();
    final user = AppUser(
      id: userId,
      fullName: req.fullName,
      email: req.email,
      phone: req.phone,
      country: country,
      createdAt: DateTime.now(),
    );

    _currentUser = user;

    // Bootstrap wallet for the new user
    _wallet = Wallet(
      id: _uuid.v4(),
      userId: userId,
      balance: 0.0,
      currencyCode: country.currencyCode,
      currencySymbol: country.currencySymbol,
      lastTopUpDate: null,
    );

    // Seed mock activity history
    _activities
      ..clear()
      ..addAll(_generateSeedActivity(country.currencySymbol));

    return user;
  }

  // ── GET /api/countries ────────────────────────────────────────────────────

  Future<List<Country>> getCountries() async {
    await Future.delayed(AppConstants.mockDelay);
    final raw = await rootBundle.loadString('assets/data/countries.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── GET /api/wallet ───────────────────────────────────────────────────────

  Future<Wallet> getWallet() async {
    await Future.delayed(AppConstants.mockDelay);
    if (_wallet == null) throw const ApiException('Wallet not found.', statusCode: 404);
    return _wallet!;
  }

  // ── GET /api/wallet/activity ──────────────────────────────────────────────

  Future<List<WalletActivity>> getWalletActivity() async {
    await Future.delayed(AppConstants.mockDelay);
    return List.unmodifiable(_activities.reversed.toList());
  }

  // ── POST /api/wallet/topup ────────────────────────────────────────────────

  Future<({Wallet wallet, WalletActivity activity})> topUp(
    TopupRequest req,
  ) async {
    await Future.delayed(AppConstants.mockDelayLong);

    if (_wallet == null) throw const ApiException('Wallet not found.', statusCode: 404);
    if (req.amount <= 0) {
      throw const ValidationException('Top-up amount must be greater than zero.');
    }

    // Simulate ~10% chance of payment failure for realism
    final shouldFail = DateTime.now().millisecond % 10 == 0;
    final status = shouldFail ? ActivityStatus.failed : ActivityStatus.success;

    final updatedWallet = shouldFail
        ? _wallet!
        : _wallet!.copyWith(
            balance: _wallet!.balance + req.amount,
            lastTopUpDate: DateTime.now(),
          );

    _wallet = updatedWallet;

    final activity = WalletActivity(
      id: _uuid.v4(),
      type: ActivityType.topUp,
      status: status,
      amount: req.amount,
      currencySymbol: _wallet!.currencySymbol,
      description: shouldFail ? 'Top-up failed' : 'Wallet top-up',
      createdAt: DateTime.now(),
    );

    _activities.add(activity);

    return (wallet: updatedWallet, activity: activity);
  }

  // ── Seed Data Helper ──────────────────────────────────────────────────────

  List<WalletActivity> _generateSeedActivity(String symbol) {
    final now = DateTime.now();
    return [
      WalletActivity(
        id: _uuid.v4(),
        type: ActivityType.topUp,
        status: ActivityStatus.success,
        amount: 20.00,
        currencySymbol: symbol,
        description: 'Wallet top-up',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      WalletActivity(
        id: _uuid.v4(),
        type: ActivityType.callCreditUsed,
        status: ActivityStatus.success,
        amount: 2.50,
        currencySymbol: symbol,
        description: 'Call to +234 812 345 6789',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      WalletActivity(
        id: _uuid.v4(),
        type: ActivityType.paymentSent,
        status: ActivityStatus.success,
        amount: 5.00,
        currencySymbol: symbol,
        description: 'Sent to Adebayo K.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      WalletActivity(
        id: _uuid.v4(),
        type: ActivityType.topUp,
        status: ActivityStatus.failed,
        amount: 50.00,
        currencySymbol: symbol,
        description: 'Top-up failed – card declined',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      WalletActivity(
        id: _uuid.v4(),
        type: ActivityType.callCreditUsed,
        status: ActivityStatus.success,
        amount: 1.20,
        currencySymbol: symbol,
        description: 'Call to +44 7700 900123',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      WalletActivity(
        id: _uuid.v4(),
        type: ActivityType.paymentSent,
        status: ActivityStatus.pending,
        amount: 15.00,
        currencySymbol: symbol,
        description: 'Sent to Chidi O.',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      WalletActivity(
        id: _uuid.v4(),
        type: ActivityType.topUp,
        status: ActivityStatus.success,
        amount: 100.00,
        currencySymbol: symbol,
        description: 'Wallet top-up',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
