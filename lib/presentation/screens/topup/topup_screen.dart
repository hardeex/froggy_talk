import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/requests.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/common/app_button.dart';

class TopupScreen extends ConsumerStatefulWidget {
  const TopupScreen({super.key});

  @override
  ConsumerState<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends ConsumerState<TopupScreen> {
  double? _selectedAmount;
  String? _selectedPaymentId;
  final _customAmountCtrl = TextEditingController();
  bool _useCustomAmount = false;
  _TopupStep _step = _TopupStep.select;

  @override
  void dispose() {
    _customAmountCtrl.dispose();
    super.dispose();
  }

  double? get _effectiveAmount {
    if (_useCustomAmount) {
      return double.tryParse(_customAmountCtrl.text.replaceAll(',', ''));
    }
    return _selectedAmount;
  }

  Future<void> _confirmTopUp() async {
    final amount = _effectiveAmount;
    if (amount == null || amount <= 0) {
      _showSnack('Please enter a valid amount.');
      return;
    }
    if (_selectedPaymentId == null) {
      _showSnack('Please select a payment method.');
      return;
    }

    final result = await ref
        .read(walletProvider.notifier)
        .topUp(
          TopupRequest(amount: amount, paymentMethodId: _selectedPaymentId!),
        );

    setState(
      () => _step = result == TopUpResult.success
          ? _TopupStep.success
          : _TopupStep.failed,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user!;
    final walletState = ref.watch(walletProvider);
    final currency = user.country.currencyCode;
    final symbol = user.country.currencySymbol;
    final presets =
        AppConstants.topupPresets[currency] ?? [10.0, 20.0, 50.0, 100.0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up Wallet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: switch (_step) {
        _TopupStep.select => _buildSelectStep(
          currency,
          symbol,
          presets,
          walletState,
        ),
        _TopupStep.success => _buildResultStep(isSuccess: true, symbol: symbol),
        _TopupStep.failed => _buildResultStep(isSuccess: false, symbol: symbol),
      },
    );
  }

  Widget _buildSelectStep(
    String currency,
    String symbol,
    List<double> presets,
    WalletState walletState,
  ) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current balance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                const Text('💰', style: TextStyle(fontSize: 24)),
                const Gap(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Balance',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      walletState.wallet != null
                          ? formatter.format(walletState.wallet!.balance)
                          : '—',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
          const Gap(28),
          Text(
            'Select Amount',
            style: Theme.of(context).textTheme.titleMedium,
          ).animate().fadeIn(delay: 80.ms),
          const Gap(12),
          // Preset grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemCount: presets.length,
            itemBuilder: (_, i) {
              final amount = presets[i];
              final isSelected = !_useCustomAmount && _selectedAmount == amount;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedAmount = amount;
                  _useCustomAmount = false;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.15)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$symbol${amount % 1 == 0 ? amount.toInt() : amount}',
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              );
            },
          ).animate().fadeIn(delay: 120.ms),
          const Gap(12),
          // Custom amount toggle
          GestureDetector(
            onTap: () => setState(() {
              _useCustomAmount = !_useCustomAmount;
              if (!_useCustomAmount) _customAmountCtrl.clear();
            }),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _useCustomAmount
                        ? AppColors.primary
                        : AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _useCustomAmount
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const Gap(8),
                Text(
                  'Enter custom amount',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _useCustomAmount
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_useCustomAmount) ...[
            const Gap(12),
            TextField(
              controller: _customAmountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Amount ($currency)',
                prefixText: '$symbol ',
                prefixStyle: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
          const Gap(28),
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.titleMedium,
          ).animate().fadeIn(delay: 160.ms),
          const Gap(12),
          ...AppConstants.paymentMethods.map((method) {
                final isSelected = _selectedPaymentId == method['id'];
                return GestureDetector(
                  onTap: () => setState(
                    () => _selectedPaymentId = method['id'] as String,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Text(
                        //   method['icon'] as String,
                        //   style: const TextStyle(fontSize: 22),
                        // ),
                        Icon(
                          method['icon'] as IconData,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 22,
                        ),
                        const Gap(12),
                        Text(
                          method['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList()
              as List<Widget>,
          const Gap(12),
          // Summary
          if (_effectiveAmount != null && _effectiveAmount! > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'You will top up:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    formatter.format(_effectiveAmount!),
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms),
          const Gap(24),
          AppButton(
            label: 'Confirm Top-Up',
            onPressed: _effectiveAmount != null && _effectiveAmount! > 0
                ? _confirmTopUp
                : null,
            isLoading: walletState.isTopUpLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildResultStep({required bool isSuccess, required String symbol}) {
    final walletState = ref.watch(walletProvider);
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: (isSuccess ? AppColors.success : AppColors.error)
                    .withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  isSuccess ? '✅' : '❌',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ).animate().scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.elasticOut,
            ),
            const Gap(24),
            Text(
              isSuccess ? 'Top-Up Successful!' : 'Top-Up Failed',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isSuccess ? AppColors.success : AppColors.error,
              ),
            ).animate().fadeIn(delay: 150.ms),
            const Gap(12),
            if (isSuccess && walletState.wallet != null)
              Text(
                'Your new balance is\n${formatter.format(walletState.wallet!.balance)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(delay: 250.ms),
            if (!isSuccess)
              Text(
                'Your payment could not be processed.\nPlease check your payment details and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 250.ms),
            const Gap(36),
            AppButton(
              label: isSuccess ? 'Back to Wallet' : 'Try Again',
              onPressed: () {
                if (isSuccess) {
                  context.pop();
                } else {
                  setState(() => _step = _TopupStep.select);
                }
              },
            ).animate().fadeIn(delay: 350.ms),
            if (!isSuccess) ...[
              const Gap(12),
              AppButton(
                label: 'Back to Wallet',
                onPressed: () => context.pop(),
                variant: AppButtonVariant.ghost,
              ).animate().fadeIn(delay: 400.ms),
            ],
          ],
        ),
      ),
    );
  }
}

enum _TopupStep { select, success, failed }
