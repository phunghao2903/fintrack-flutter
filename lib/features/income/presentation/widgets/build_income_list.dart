// Widget cho danh sách thu nhập
import 'package:fintrack/features/income/domain/entities/income_entity.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/core/theme/app_colors.dart';

// Chấp nhận danh sách từ bên ngoài thay vì sử dụng danh sách tĩnh
Widget buildIncomeList(List<IncomeEntity> incomeItems) {
  return Column(
    children: incomeItems.map((income) => buildIncomeListItem(income)).toList(),
  );
}

// Widget cho một mục trong danh sách
Widget buildIncomeListItem(IncomeEntity income) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: _getCategoryColor(income.categoryName).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: income.categoryIcon != null
                ? Image.asset(
                    income.categoryIcon!,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => Icon(
                      _getCategoryIcon(income.categoryName),
                      color: _getCategoryColor(income.categoryName),
                    ),
                  )
                : Icon(
                    _getCategoryIcon(income.categoryName),
                    color: _getCategoryColor(income.categoryName),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              income.categoryName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  income.formattedAmount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

IconData _getCategoryIcon(String categoryName) {
  final category = categoryName.toLowerCase();
  if (category.contains('food')) return Icons.restaurant;
  if (category.contains('taxi') || category.contains('transport'))
    return Icons.local_taxi;
  if (category.contains('shopping')) return Icons.shopping_bag;
  if (category.contains('transfer')) return Icons.swap_horiz;
  if (category.contains('salary')) return Icons.attach_money;
  if (category.contains('entertainment')) return Icons.movie;
  if (category.contains('health')) return Icons.local_hospital;
  if (category.contains('education')) return Icons.school;
  return Icons.receipt;
}

Color _getCategoryColor(String categoryName) {
  final category = categoryName.toLowerCase();
  if (category.contains('food')) return Colors.red;
  if (category.contains('taxi') || category.contains('transport'))
    return Colors.blue;
  if (category.contains('shopping')) return Colors.orange;
  if (category.contains('transfer') || category.contains('salary'))
    return Colors.green;
  if (category.contains('entertainment')) return Colors.purple;
  if (category.contains('health')) return Colors.pink;
  if (category.contains('education')) return Colors.teal;
  return AppColors.grey;
}

Widget buildEmptyIncomeList() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_off, color: Colors.grey, size: 50),
        const SizedBox(height: 16),
        Text(
          "Không tìm thấy khoản thu nhập nào",
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      ],
    ),
  );
}
