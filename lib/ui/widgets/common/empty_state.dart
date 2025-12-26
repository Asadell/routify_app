import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sizer/sizer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../../core/utils/size_config.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.h,
              height: 20.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppSizes.iconXl * 2,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              title,
              style: AppTextStyles.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSizes.lg),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Iconsax.add_circle),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingLg,
                    vertical: AppSizes.paddingMd,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}