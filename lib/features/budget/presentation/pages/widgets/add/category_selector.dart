import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/utils/size_utils.dart';
import '../../../bloc/budget_bloc.dart';
import '../../../bloc/budget_event.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;

  const CategorySelector({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final h = SizeUtils.height(context);
    final w = SizeUtils.width(context);
    final state = context.watch<BudgetBloc>().state;

    return SizedBox(
      height: h * 0.07,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: w * 0.03),
        itemBuilder: (context, index) {
          final title = categories[index];
          final isSelected = state.addCategory == title;

          return GestureDetector(
            onTap: () {
              context.read<BudgetBloc>().add(AddCategoryChanged(title));
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.015,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.main : AppColors.widget,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.main : AppColors.grey,
                  width: 1,
                ),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black : AppColors.white,
                  fontSize: h * 0.018,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
