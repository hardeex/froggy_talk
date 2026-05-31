import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/common/wallet_card.dart';
import '../../widgets/common/activity_list_item.dart';
import '../../widgets/common/wallet_shimmer.dart';
import '../../widgets/common/state_widgets.dart';
import '../../widgets/common/app_button.dart';

class WalletHomeScreen extends ConsumerStatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  ConsumerState<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends ConsumerState<WalletHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load wallet data on first render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).loadWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final walletState = ref.watch(walletProvider);
    final user = authState.user!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              '🐸 ',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'FroggyTalk',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          // Avatar
          GestureDetector(
            onTap: () => _showProfileSheet(context, user.fullName),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.firstName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(walletProvider.notifier).loadWallet(),
        child: walletState.isLoading
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: WalletLoadingShimmer(),
              )
            : walletState.error != null && walletState.wallet == null
                ? ErrorStateWidget(
                    message: walletState.error!.message,
                    onRetry: () =>
                        ref.read(walletProvider.notifier).loadWallet(),
                  )
                : _buildContent(walletState, user),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildContent(walletState, user) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        // Greeting
        RichText(
          text: TextSpan(
            text: 'Hey, ',
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: '${user.firstName} 👋',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms),
        const Gap(16),
        // Wallet Card
        if (walletState.wallet != null)
          WalletCard(
            wallet: walletState.wallet!,
            userName: user.fullName,
            countryName: user.country.name,
            countryFlag: user.country.flag,
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.08, end: 0),
        const Gap(20),
        // Top Up CTA
        AppButton(
          label: 'Top Up Wallet',
          onPressed: () async {
            await context.push('/topup');
            // Reload after returning from topup
          },
          icon: const Icon(Icons.add_rounded, size: 20),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 300.ms),
        const Gap(28),
        // Quick stats
        _buildQuickStats(walletState),
        const Gap(28),
        // Activity
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${walletState.activities.length} items',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 300.ms),
        const Gap(12),
        _buildActivityList(walletState.activities),
      ],
    );
  }

  Widget _buildQuickStats(walletState) {
    if (walletState.wallet == null) return const SizedBox.shrink();
    final activities = walletState.activities as List;
    final successTopUps = activities
        .where((a) =>
            a.type.name == 'topUp' && a.status.name == 'success')
        .length;

    return Row(
      children: [
        _StatCard(
          label: 'Successful Top-Ups',
          value: '$successTopUps',
          icon: '✅',
        ),
        const Gap(12),
        _StatCard(
          label: 'Currency',
          value: walletState.wallet!.currencyCode,
          icon: '💱',
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 250.ms, duration: 300.ms);
  }

  Widget _buildActivityList(List activities) {
    if (activities.isEmpty) {
      return const EmptyStateWidget(
        emoji: '📭',
        title: 'No transactions yet',
        subtitle: 'Your activity will appear here once you make your first top-up or call.',
      );
    }

    return Column(
      children: [
        for (int i = 0; i < activities.length; i++) ...[
          ActivityListItem(activity: activities[i])
              .animate()
              .fadeIn(delay: Duration(milliseconds: 350 + i * 60), duration: 300.ms)
              .slideX(begin: 0.05, end: 0),
          if (i < activities.length - 1) const Gap(10),
        ],
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 12,
        top: 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Wallet', active: true),
          _NavItem(icon: Icons.phone_rounded, label: 'Calls', active: false),
          _NavItem(icon: Icons.send_rounded, label: 'Send', active: false),
          _NavItem(icon: Icons.person_rounded, label: 'Profile', active: false),
        ],
      ),
    );
  }

  void _showProfileSheet(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            const Gap(24),
            AppButton(
              label: 'Sign Out',
              onPressed: () {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).logout();
              },
              variant: AppButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const Gap(8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 22,
                color: AppColors.primary,
              ),
            ),
            const Gap(2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? AppColors.primary : AppColors.textMuted,
          size: 24,
        ),
        const Gap(4),
        Text(
          label,
          style: TextStyle(
            color: active ? AppColors.primary : AppColors.textMuted,
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
