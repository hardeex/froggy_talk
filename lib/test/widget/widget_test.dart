import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:froggytalk/core/constants/app_theme.dart';
import 'package:froggytalk/data/models/country.dart';
import 'package:froggytalk/data/models/wallet.dart';
import 'package:froggytalk/data/models/wallet_activity.dart';
import 'package:froggytalk/presentation/widgets/common/wallet_card.dart';
import 'package:froggytalk/presentation/widgets/common/activity_list_item.dart';
import 'package:froggytalk/presentation/widgets/common/app_button.dart';
import 'package:froggytalk/presentation/widgets/common/state_widgets.dart';

// Disable network font loading during tests
void _disableGoogleFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;
}

Widget _wrapWidget(Widget child) {
  _disableGoogleFonts();
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    ),
  );
}

// ── Fixtures ───────────────────────────────────────────────────────────────────

Wallet makeWallet({
  double balance = 250.0,
  String currencyCode = 'GBP',
  String currencySymbol = '£',
  DateTime? lastTopUpDate,
}) =>
    Wallet(
      id: 'w-1',
      userId: 'u-1',
      balance: balance,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      lastTopUpDate: lastTopUpDate,
    );

WalletActivity makeActivity({
  ActivityType type = ActivityType.topUp,
  ActivityStatus status = ActivityStatus.success,
  double amount = 25.0,
  String currencySymbol = '£',
}) =>
    WalletActivity(
      id: 'act-1',
      type: type,
      status: status,
      amount: amount,
      currencySymbol: currencySymbol,
      description: 'Test',
      createdAt: DateTime(2024, 6, 15, 10, 30),
    );

Country makeCountry({
  String code = 'GB',
  String currencyCode = 'GBP',
  String currencySymbol = '£',
}) =>
    Country(
      code: code,
      name: 'United Kingdom',
      flag: '🇬🇧',
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      currencyName: 'British Pound',
      phonePrefix: '+44',
    );

// ── WalletCard tests ───────────────────────────────────────────────────────────

void main() {
  group('WalletCard', () {
    testWidgets('renders correct currency symbol', (tester) async {
      final wallet = makeWallet(currencyCode: 'NGN', currencySymbol: '₦', balance: 5000);

      await tester.pumpWidget(_wrapWidget(
        SingleChildScrollView(
          child: WalletCard(
            wallet: wallet,
            userName: 'Jamiu Adeyemi',
            countryName: 'Nigeria',
            countryFlag: '🇳🇬',
          ),
        ),
      ));

      // Currency symbol should be present
      expect(find.textContaining('₦'), findsWidgets);
    });

    testWidgets('renders correct currency code badge', (tester) async {
      final wallet = makeWallet(currencyCode: 'GBP', currencySymbol: '£');

      await tester.pumpWidget(_wrapWidget(
        SingleChildScrollView(
          child: WalletCard(
            wallet: wallet,
            userName: 'Test User',
            countryName: 'United Kingdom',
            countryFlag: '🇬🇧',
          ),
        ),
      ));

      expect(find.text('GBP'), findsOneWidget);
    });

    testWidgets('renders user name correctly', (tester) async {
      final wallet = makeWallet();

      await tester.pumpWidget(_wrapWidget(
        SingleChildScrollView(
          child: WalletCard(
            wallet: wallet,
            userName: 'Adebayo Williams',
            countryName: 'Nigeria',
            countryFlag: '🇳🇬',
          ),
        ),
      ));

      expect(find.text('Adebayo Williams'), findsOneWidget);
    });

    testWidgets('shows "No top-ups yet" when lastTopUpDate is null',
        (tester) async {
      final wallet = makeWallet(lastTopUpDate: null);

      await tester.pumpWidget(_wrapWidget(
        SingleChildScrollView(
          child: WalletCard(
            wallet: wallet,
            userName: 'Test',
            countryName: 'UK',
            countryFlag: '🇬🇧',
          ),
        ),
      ));

      expect(find.text('No top-ups yet'), findsOneWidget);
    });

    testWidgets('shows last top-up date when available', (tester) async {
      final wallet = makeWallet(
        lastTopUpDate: DateTime(2024, 6, 10),
      );

      await tester.pumpWidget(_wrapWidget(
        SingleChildScrollView(
          child: WalletCard(
            wallet: wallet,
            userName: 'Test',
            countryName: 'UK',
            countryFlag: '🇬🇧',
          ),
        ),
      ));

      expect(find.textContaining('10 Jun 2024'), findsOneWidget);
    });

    testWidgets('balance reflects updated amount', (tester) async {
      final wallet = makeWallet(
        balance: 1500.0,
        currencyCode: 'NGN',
        currencySymbol: '₦',
      );

      await tester.pumpWidget(_wrapWidget(
        SingleChildScrollView(
          child: WalletCard(
            wallet: wallet,
            userName: 'Test',
            countryName: 'Nigeria',
            countryFlag: '🇳🇬',
          ),
        ),
      ));

      expect(find.textContaining('1,500'), findsWidgets);
    });
  });

  // ── ActivityListItem tests ──────────────────────────────────────────────────

  group('ActivityListItem', () {
    testWidgets('renders Top-Up label', (tester) async {
      final activity = makeActivity(type: ActivityType.topUp);

      await tester.pumpWidget(_wrapWidget(ActivityListItem(activity: activity)));

      expect(find.text('Top-Up'), findsOneWidget);
    });

    testWidgets('renders Call Credit Used label', (tester) async {
      final activity = makeActivity(type: ActivityType.callCreditUsed);

      await tester.pumpWidget(_wrapWidget(ActivityListItem(activity: activity)));

      expect(find.text('Call Credit Used'), findsOneWidget);
    });

    testWidgets('renders Payment Sent label', (tester) async {
      final activity = makeActivity(type: ActivityType.paymentSent);

      await tester.pumpWidget(_wrapWidget(ActivityListItem(activity: activity)));

      expect(find.text('Payment Sent'), findsOneWidget);
    });

    testWidgets('renders success status badge', (tester) async {
      final activity = makeActivity(status: ActivityStatus.success);

      await tester.pumpWidget(_wrapWidget(ActivityListItem(activity: activity)));

      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('renders failed status badge', (tester) async {
      final activity = makeActivity(status: ActivityStatus.failed);

      await tester.pumpWidget(_wrapWidget(ActivityListItem(activity: activity)));

      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('renders pending status badge', (tester) async {
      final activity = makeActivity(status: ActivityStatus.pending);

      await tester.pumpWidget(_wrapWidget(ActivityListItem(activity: activity)));

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('shows + prefix for top-up amount', (tester) async {
      final activity = makeActivity(
        type: ActivityType.topUp,
        amount: 50.0,
        currencySymbol: '£',
      );

      await tester.pumpWidget(_wrapWidget(ActivityListItem(activity: activity)));

      expect(find.textContaining('+'), findsOneWidget);
    });

    testWidgets('shows - prefix for payment sent', (tester) async {
      final activity = makeActivity(
        type: ActivityType.paymentSent,
        amount: 10.0,
        currencySymbol: '£',
      );

      await tester.pumpWidget(_wrapWidget(ActivityListItem(activity: activity)));

      expect(find.textContaining('-'), findsOneWidget);
    });
  });

  // ── AppButton tests ──────────────────────────────────────────────────────────

  group('AppButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrapWidget(
        AppButton(label: 'Top Up', onPressed: () {}),
      ));

      expect(find.text('Top Up'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(_wrapWidget(
        AppButton(label: 'Top Up', onPressed: () {}, isLoading: true),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Top Up'), findsNothing);
    });

    testWidgets('fires onPressed callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrapWidget(
        AppButton(label: 'Go', onPressed: () => tapped = true),
      ));

      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not fire callback when disabled (null onPressed)',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrapWidget(
        AppButton(label: 'Go', onPressed: null),
      ));

      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      expect(tapped, isFalse);
    });
  });

  // ── EmptyStateWidget ────────────────────────────────────────────────────────

  group('EmptyStateWidget', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(_wrapWidget(
        const EmptyStateWidget(
          title: 'No transactions',
          subtitle: 'Top up to get started',
        ),
      ));

      expect(find.text('No transactions'), findsOneWidget);
      expect(find.text('Top up to get started'), findsOneWidget);
    });
  });

  // ── ErrorStateWidget ────────────────────────────────────────────────────────

  group('ErrorStateWidget', () {
    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(_wrapWidget(
        const ErrorStateWidget(message: 'Something went wrong'),
      ));

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      var retried = false;
      await tester.pumpWidget(_wrapWidget(
        ErrorStateWidget(
          message: 'Failed',
          onRetry: () => retried = true,
        ),
      ));

      expect(find.text('Try again'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(_wrapWidget(
        const ErrorStateWidget(message: 'Failed'),
      ));

      expect(find.text('Try again'), findsNothing);
    });
  });
}
