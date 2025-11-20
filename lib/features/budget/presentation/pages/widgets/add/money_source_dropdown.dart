import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/utils/size_utils.dart';
import '../../../bloc/budget_bloc.dart';
import '../../../bloc/budget_event.dart';

class MoneySourceDropdown extends StatelessWidget {
  const MoneySourceDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BudgetBloc>().state;
    final h = SizeUtils.height(context);
    final w = SizeUtils.width(context);

    return DropdownButtonFormField<String>(
      value: state.addSource,
      dropdownColor: AppColors.widget,
      iconEnabledColor: AppColors.white,
      style: const TextStyle(color: AppColors.white),

      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.main),
          borderRadius: BorderRadius.circular(12),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: h * 0.02,
        ),
      ),

      items: const [
        DropdownMenuItem(
          value: "Cash",
          child: Text("Cash", style: TextStyle(color: AppColors.white)),
        ),
        DropdownMenuItem(
          value: "Bank",
          child: Text("Bank", style: TextStyle(color: AppColors.white)),
        ),
        DropdownMenuItem(
          value: "All",
          child: Text("All", style: TextStyle(color: AppColors.white)),
        ),
      ],

      onChanged: (value) {
        if (value != null) {
          context.read<BudgetBloc>().add(AddSourceChanged(value));
        }
      },
    );
  }
}
