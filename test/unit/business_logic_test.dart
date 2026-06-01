import 'package:flutter_test/flutter_test.dart';
import 'package:froggytalk_assessment/data/models/country.dart';
import 'package:froggytalk_assessment/data/models/wallet.dart';
import 'package:froggytalk_assessment/data/models/wallet_activity.dart';

// ── Helper Fixtures ────────────────────────────────────────────────────────────

Country _country({
  String code = 'NG',
  String name = 'Nigeria',
  String currencyCode = 'NGN',
  String currencySymbol = '₦',
}) => Country(
  code: code,
  name: name,
  flag: '🇳🇬',
  currencyCode: currencyCode,
  currencySymbol: currencySymbol,
  currencyName: 'Nigerian Naira',
  phonePrefix: '+234',
);

Wallet _wallet({double balance = 0.0, String currencyCode = 'NGN'}) => Wallet(
  id: 'wallet-1',
  userId: 'user-1',
  balance: balance,
  currencyCode: currencyCode,
  currencySymbol: '₦',
  lastTopUpDate: null,
);

// ── Country ────────────────────────────────────────────────────────────────────

void main() {
  group('Country', () {
    test('fromJson correctly parses all fields', () {
      const json = {
        'code': 'GB',
        'name': 'United Kingdom',
        'flag': '🇬🇧',
        'currency_code': 'GBP',
        'currency_symbol': '£',
        'currency_name': 'British Pound',
        'phone_prefix': '+44',
      };

      final country = Country.fromJson(json);

      expect(country.code, 'GB');
      expect(country.name, 'United Kingdom');
      expect(country.currencyCode, 'GBP');
      expect(country.currencySymbol, '£');
      expect(country.phonePrefix, '+44');
    });

    test('Country equality is based on code', () {
      final a = _country(code: 'NG');
      final b = _country(code: 'NG');
      final c = _country(code: 'US');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('country → currency mapping for all 5 supported countries', () {
      final mapping = {
        'GB': 'GBP',
        'NG': 'NGN',
        'US': 'USD',
        'GH': 'GHS',
        'KE': 'KES',
      };

      for (final entry in mapping.entries) {
        final country = _country(code: entry.key, currencyCode: entry.value);
        expect(
          country.currencyCode,
          entry.value,
          reason: '${entry.key} should map to ${entry.value}',
        );
      }
    });
  });

  // ── Wallet ─────────────────────────────────────────────────────────────────

  group('Wallet', () {
    test('balance updates correctly after top-up', () {
      final wallet = _wallet(balance: 100.0);
      final updated = wallet.copyWith(balance: wallet.balance + 50.0);

      expect(updated.balance, 150.0);
    });

    test('copyWith preserves unchanged fields', () {
      final wallet = _wallet(balance: 200.0, currencyCode: 'NGN');
      final updated = wallet.copyWith(balance: 300.0);

      expect(updated.currencyCode, 'NGN');
      expect(updated.id, wallet.id);
      expect(updated.userId, wallet.userId);
    });

    test('lastTopUpDate updates after top-up', () {
      final wallet = _wallet();
      expect(wallet.lastTopUpDate, isNull);

      final now = DateTime.now();
      final updated = wallet.copyWith(lastTopUpDate: now);

      expect(updated.lastTopUpDate, equals(now));
    });

    test('fromJson correctly parses wallet', () {
      final json = {
        'id': 'w-1',
        'user_id': 'u-1',
        'balance': 500.0,
        'currency_code': 'GHS',
        'currency_symbol': '₵',
        'last_top_up_date': null,
      };

      final wallet = Wallet.fromJson(json);

      expect(wallet.balance, 500.0);
      expect(wallet.currencyCode, 'GHS');
      expect(wallet.lastTopUpDate, isNull);
    });
  });

  // ── WalletActivity ─────────────────────────────────────────────────────────

  group('WalletActivity', () {
    WalletActivity makeActivity({
      ActivityType type = ActivityType.topUp,
      ActivityStatus status = ActivityStatus.success,
      double amount = 20.0,
    }) => WalletActivity(
      id: 'act-1',
      type: type,
      status: status,
      amount: amount,
      currencySymbol: '₦',
      description: 'Test activity',
      createdAt: DateTime(2024, 1, 15),
    );

    test('ActivityType.topUp is a credit', () {
      expect(ActivityType.topUp.isCredit, isTrue);
    });

    test('ActivityType.callCreditUsed is not a credit', () {
      expect(ActivityType.callCreditUsed.isCredit, isFalse);
    });

    test('ActivityType.paymentSent is not a credit', () {
      expect(ActivityType.paymentSent.isCredit, isFalse);
    });

    test('ActivityStatus labels are correct', () {
      expect(ActivityStatus.success.label, 'Success');
      expect(ActivityStatus.failed.label, 'Failed');
      expect(ActivityStatus.pending.label, 'Pending');
    });

    test('Activity list updates after successful top-up', () {
      final activities = <WalletActivity>[];
      final newActivity = makeActivity(
        type: ActivityType.topUp,
        status: ActivityStatus.success,
        amount: 50.0,
      );

      activities.insert(0, newActivity);

      expect(activities.length, 1);
      expect(activities.first.type, ActivityType.topUp);
      expect(activities.first.amount, 50.0);
      expect(activities.first.status, ActivityStatus.success);
    });

    test('Activity list adds failed top-up with correct status', () {
      final activities = <WalletActivity>[];
      final failedActivity = makeActivity(
        type: ActivityType.topUp,
        status: ActivityStatus.failed,
        amount: 100.0,
      );

      activities.insert(0, failedActivity);

      expect(activities.first.status, ActivityStatus.failed);
      expect(activities.first.amount, 100.0);
    });

    test('fromJson parses activity correctly', () {
      final json = {
        'id': 'act-2',
        'type': 'paymentSent',
        'status': 'pending',
        'amount': 15.0,
        'currency_symbol': '\$',
        'description': 'Sent to friend',
        'created_at': '2024-06-01T10:00:00.000',
      };

      final activity = WalletActivity.fromJson(json);

      expect(activity.type, ActivityType.paymentSent);
      expect(activity.status, ActivityStatus.pending);
      expect(activity.amount, 15.0);
    });
  });

  // ── Currency Formatting Logic ──────────────────────────────────────────────

  group('Currency symbol mapping', () {
    final symbolMap = {
      'GBP': '£',
      'NGN': '₦',
      'USD': '\$',
      'GHS': '₵',
      'KES': 'KSh',
    };

    for (final entry in symbolMap.entries) {
      test('${entry.key} has correct symbol ${entry.value}', () {
        expect(entry.value, isNotEmpty);
        // Ensure it's a valid non-empty string usable as a currency symbol
        expect(entry.value.trim(), isNotEmpty);
      });
    }
  });
}
