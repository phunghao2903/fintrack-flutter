import 'package:fintrack/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:fintrack/features/budget/presentation/pages/widgets/add/amount_input_field.dart';
import 'package:fintrack/features/budget/presentation/pages/widgets/add/budget_name_field.dart';
import 'package:fintrack/features/budget/presentation/pages/widgets/add/category_selector.dart';
import 'package:fintrack/features/budget/presentation/pages/widgets/add/date_input_field.dart';
import 'package:fintrack/features/budget/presentation/pages/widgets/add/money_source_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/utils/size_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// class AddBudgetPage extends StatefulWidget {
//   const AddBudgetPage({super.key});

//   @override
//   State<AddBudgetPage> createState() => _AddBudgetPageState();
// }

// class _AddBudgetPageState extends State<AddBudgetPage> {
//   String selectedSource = "Cash";

//   final List<String> categories = [
//     "Groceries",
//     "Food",
//     "Shopping",
//     "Health",
//     "Transport",
//     "Bills",
//     "Entertainment",
//   ];
//   String? selectedCategory;

//   late DateTime startDate;
//   late DateTime endDate;

//   @override
//   void initState() {
//     super.initState();

//     // Today
//     startDate = DateTime.now();

//     // End of month = ngày 0 của tháng sau
//     final now = DateTime.now();
//     endDate = DateTime(now.year, now.month + 1, 0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final h = SizeUtils.height(context);
//     final w = SizeUtils.width(context);

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           "Budget",
//           style: AppTextStyles.body1.copyWith(color: AppColors.white),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         color: AppColors.widget, // nền cho toàn bộ bottomNavigationBar
//         padding: EdgeInsets.fromLTRB(w * 0.03, h * 0.02, w * 0.03, h * 0.02),
//         child: SizedBox(
//           width: double.infinity,
//           height: h * 0.06,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.main, // nền button vẫn là main
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             onPressed: () {},
//             child: Text(
//               "Add Expense Transaction",
//               style: AppTextStyles.body2.copyWith(
//                 color: Colors.black,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),

//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
//         child: Column(
//           children: [
//             // Amount
//             TextFormField(
//               keyboardType: TextInputType.number,
//               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               style: const TextStyle(color: AppColors.white),
//               decoration: InputDecoration(
//                 labelText: "Amount",
//                 hintText: "0đ",
//                 hintStyle: const TextStyle(color: AppColors.grey),
//                 labelStyle: const TextStyle(color: AppColors.grey),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: AppColors.grey),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: AppColors.main),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: w * 0.04,
//                   vertical: h * 0.02,
//                 ),
//               ),
//             ),

//             SizedBox(height: h * 0.02),

//             // Budget name
//             TextFormField(
//               style: const TextStyle(color: AppColors.white),
//               decoration: InputDecoration(
//                 labelText: "Budget",
//                 hintText: "Enter Budget Name",
//                 hintStyle: const TextStyle(color: AppColors.grey),
//                 labelStyle: const TextStyle(color: AppColors.grey),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: AppColors.grey),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: AppColors.main),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: w * 0.04,
//                   vertical: h * 0.02,
//                 ),
//               ),
//             ),

//             SizedBox(height: h * 0.03),

//             // Category
//             // Category label
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Category",
//                 style: AppTextStyles.body2.copyWith(color: AppColors.grey),
//               ),
//             ),
//             SizedBox(height: h * 0.01),

//             SizedBox(
//               height: h * 0.07, // chiều cao của chip row
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 separatorBuilder: (_, __) => SizedBox(width: w * 0.03),
//                 itemBuilder: (context, index) {
//                   return _categoryItem(categories[index], w, h);
//                 },
//               ),
//             ),

//             SizedBox(height: h * 0.03),

//             // Money Source
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Money Source",
//                 style: AppTextStyles.body2.copyWith(color: AppColors.grey),
//               ),
//             ),
//             SizedBox(height: h * 0.01),

//             DropdownButtonFormField<String>(
//               value: selectedSource,
//               dropdownColor: AppColors.widget,
//               iconEnabledColor: AppColors.white,
//               style: const TextStyle(color: AppColors.white),

//               decoration: InputDecoration(
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: AppColors.grey),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: AppColors.main),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: w * 0.04,
//                   vertical: h * 0.02,
//                 ),
//               ),

//               items: const [
//                 DropdownMenuItem(
//                   value: "Cash",
//                   child: Text("Cash", style: TextStyle(color: AppColors.white)),
//                 ),
//                 DropdownMenuItem(
//                   value: "Bank",
//                   child: Text("Bank", style: TextStyle(color: AppColors.white)),
//                 ),
//                 DropdownMenuItem(
//                   value: "All",
//                   child: Text("All", style: TextStyle(color: AppColors.white)),
//                 ),
//               ],

//               onChanged: (value) {
//                 setState(() => selectedSource = value!);
//               },
//             ),

//             SizedBox(height: h * 0.03),

//             _dateInput(
//               context: context,
//               label: "Start Date",
//               value: _formatDate(startDate),
//               h: h,
//             ),

//             SizedBox(height: h * 0.02),

//             _dateInput(
//               context: context,
//               label: "End Date",
//               value: _formatDate(endDate),
//               h: h,
//             ),

//             SizedBox(height: h * 0.04),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _categoryItem(String title, double w, double h) {
//     final bool isSelected = selectedCategory == title;

//     return GestureDetector(
//       onTap: () {
//         setState(() => selectedCategory = title);
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: w * 0.04,
//           vertical: h * 0.015,
//         ),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.main : AppColors.widget,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? AppColors.main : AppColors.grey,
//             width: 1,
//           ),
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//             color: isSelected ? Colors.black : AppColors.white,
//             fontSize: h * 0.018,
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return "${date.day.toString().padLeft(2, '0')}/"
//         "${date.month.toString().padLeft(2, '0')}/"
//         "${date.year}";
//   }

//   Widget _dateInput({
//     required BuildContext context,
//     required String label,
//     required String value,
//     required double h,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: AppTextStyles.body2.copyWith(color: AppColors.grey)),
//         const SizedBox(height: 6),

//         Container(
//           height: h * 0.07,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             border: Border.all(color: AppColors.grey),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(value, style: const TextStyle(color: AppColors.white)),
//               const Icon(Icons.calendar_today, color: AppColors.grey),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

class AddBudgetPage extends StatelessWidget {
  AddBudgetPage({super.key});

  final categories = [
    "Groceries",
    "Food",
    "Shopping",
    "Health",
    "Transport",
    "Bills",
    "Entertainment",
  ];

  @override
  Widget build(BuildContext context) {
    final h = SizeUtils.height(context);
    final w = SizeUtils.width(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: const BackButton(color: AppColors.white),
        title: Text(
          "Budget",
          style: AppTextStyles.body1.copyWith(color: AppColors.white),
        ),
      ),
      bottomNavigationBar: _submitButton(h, w),
      body: _body(context, h, w),
    );
  }

  Widget _body(BuildContext context, double h, double w) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
      child: Column(
        children: [
          const AmountInputField(),
          SizedBox(height: h * 0.02),
          const BudgetNameField(),
          SizedBox(height: h * 0.03),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Category",
              style: AppTextStyles.body2.copyWith(color: AppColors.grey),
            ),
          ),
          SizedBox(height: h * 0.01),
          CategorySelector(categories: categories),
          SizedBox(height: h * 0.03),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Money Source",
              style: AppTextStyles.body2.copyWith(color: AppColors.grey),
            ),
          ),
          SizedBox(height: h * 0.01),
          const MoneySourceDropdown(),
          SizedBox(height: h * 0.03),
          _dateFields(context, h),
        ],
      ),
    );
  }

  Widget _dateFields(BuildContext context, double h) {
    final state = context.watch<BudgetBloc>().state;

    String fmt(DateTime d) =>
        "${d.day.toString().padLeft(2, '0')}/${d.month}/${d.year}";

    return Column(
      children: [
        DateInputField(label: "Start Date", value: fmt(state.addStartDate)),
        SizedBox(height: h * 0.02),
        DateInputField(label: "End Date", value: fmt(state.addEndDate)),
      ],
    );
  }

  Widget _submitButton(double h, double w) {
    return Container(
      padding: EdgeInsets.all(16),
      color: AppColors.widget,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.main,
          minimumSize: Size(double.infinity, h * 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {},
        child: Text(
          "Add Expense Transaction",
          style: AppTextStyles.body2.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
