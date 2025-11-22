import 'package:fintrack/core/constants/assets.dart';
import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/utils/size_utils.dart';

import 'package:fintrack/features/add_transaction/domain/entities/category_entity.dart';
import 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryEntity category;
  final bool selected;
  final bool showError;

  const CategoryWidget({
    super.key,
    required this.category,
    this.selected = false,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    final h = SizeUtils.height(context);
    final w = SizeUtils.width(context);
    final iconPath = category.icon.trim().isNotEmpty
        ? category.icon
        : kDefaultIconAsset;
    return Container(
      height: h * 0.08,
      width: w * 0.25,
      decoration: BoxDecoration(
        // color: AppColors.main,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? AppColors.main
              : (showError ? Colors.red : AppColors.grey),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath),
          Text(
            category.name,
            style: AppTextStyles.caption.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
