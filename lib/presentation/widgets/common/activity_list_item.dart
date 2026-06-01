import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/wallet_activity.dart';

class ActivityListItem extends StatelessWidget {
  const ActivityListItem({super.key, required this.activity});

  final WalletActivity activity;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: activity.currencySymbol,
      decimalDigits: 2,
    );

    final isCredit = activity.type.isCredit;
    final statusColor = _statusColor(activity.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          // Type icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _iconBg(activity.type),
              borderRadius: BorderRadius.circular(12),
            ),
            // child: Center(
            //   child: Text(
            //     activity.type.icon,
            //     style: const TextStyle(fontSize: 20),
            //   ),
            // ),
            child: Center(
              child: Icon(
                _typeIcon(activity.type),
                color: _typeIconColor(activity.type),
                size: 20,
              ),
            ),
          ),
          const Gap(12),
          // Description & status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.type.label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontSize: 14),
                ),
                const Gap(2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        activity.status.label,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Gap(6),
                    Expanded(
                      child: Text(
                        DateFormat('d MMM, HH:mm').format(activity.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(8),
          // Amount
          Text(
            '${isCredit ? '+' : '-'}${formatter.format(activity.amount)}',
            style: TextStyle(
              color: isCredit ? AppColors.success : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(ActivityStatus status) => switch (status) {
    ActivityStatus.success => AppColors.success,
    ActivityStatus.failed => AppColors.error,
    ActivityStatus.pending => AppColors.pending,
  };

  // Color _iconBg(ActivityType type) => switch (type) {
  //   ActivityType.topUp => AppColors.success.withOpacity(0.12),
  //   ActivityType.callCreditUsed => AppColors.primary.withOpacity(0.12),
  //   ActivityType.paymentSent => AppColors.accent.withOpacity(0.12),
  // };
  IconData _typeIcon(ActivityType type) => switch (type) {
    ActivityType.topUp => Icons.arrow_downward_rounded,
    ActivityType.callCreditUsed => Icons.call_rounded,
    ActivityType.paymentSent => Icons.arrow_upward_rounded,
  };

  Color _typeIconColor(ActivityType type) => switch (type) {
    ActivityType.topUp => AppColors.success,
    ActivityType.callCreditUsed => AppColors.primary,
    ActivityType.paymentSent => AppColors.accent,
  };

  Color _iconBg(ActivityType type) => switch (type) {
    ActivityType.topUp => AppColors.success.withOpacity(0.12),
    ActivityType.callCreditUsed => AppColors.primary.withOpacity(0.12),
    ActivityType.paymentSent => AppColors.accent.withOpacity(0.12),
  };
}
