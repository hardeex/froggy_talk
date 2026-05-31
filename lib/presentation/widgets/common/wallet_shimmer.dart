import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_theme.dart';

class WalletLoadingShimmer extends StatelessWidget {
  const WalletLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceElevated,
      highlightColor: AppColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card shimmer
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const Gap(24),
          // Activity shimmer items
          for (int i = 0; i < 5; i++) ...[
            Container(
              height: 72,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const Gap(10),
          ],
        ],
      ),
    );
  }
}
