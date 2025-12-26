
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../../core/utils/size_config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
              color: AppColors.textPrimary,
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineLarge),
          if (subtitle != null) ...[
            SizedBox(height: AppSizes.xs),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 8.h : 7.h);
}