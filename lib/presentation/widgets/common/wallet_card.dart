import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/wallet.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.wallet,
    required this.userName,
    required this.countryName,
    required this.countryFlag,
  });

  final Wallet wallet;
  final String userName;
  final String countryName;
  final String countryFlag;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: wallet.currencySymbol,
      decimalDigits: 2,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      Text(countryFlag, style: const TextStyle(fontSize: 14)),
                      const Gap(6),
                      Text(
                        countryName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  wallet.currencyCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const Gap(28),
          Text(
            'Wallet Balance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(6),
          Text(
            formatter.format(wallet.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const Gap(20),
          if (wallet.lastTopUpDate != null) ...[
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Colors.white.withOpacity(0.65),
                ),
                const Gap(5),
                Text(
                  'Last top-up: ${DateFormat('d MMM yyyy').format(wallet.lastTopUpDate!)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Colors.white.withOpacity(0.65),
                ),
                const Gap(5),
                Text(
                  'No top-ups yet',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
