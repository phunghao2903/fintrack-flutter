// // lib/features/budget/presentation/bloc/budget_state.dart
// import 'package:equatable/equatable.dart';
// import '../../domain/entities/budget_entity.dart';

// class BudgetState extends Equatable {
//   final String selectedTab;
//   final List<BudgetEntity> budgets;
//   final bool isLoading;
//   final BudgetEntity? selectedBudget;

//   const BudgetState({
//     required this.selectedTab,
//     required this.budgets,
//     this.isLoading = false,
//     this.selectedBudget,
//   });

//   factory BudgetState.initial() => const BudgetState(
//     selectedTab: "Active",
//     budgets: [],
//     isLoading: true,
//     selectedBudget: null,
//   );

//   BudgetState copyWith({
//     String? selectedTab,
//     List<BudgetEntity>? budgets,
//     bool? isLoading,
//     BudgetEntity? selectedBudget,
//   }) {
//     return BudgetState(
//       selectedTab: selectedTab ?? this.selectedTab,
//       budgets: budgets ?? this.budgets,
//       isLoading: isLoading ?? this.isLoading,
//       selectedBudget: selectedBudget ?? this.selectedBudget,
//     );
//   }

//   @override
//   List<Object?> get props => [selectedTab, budgets, isLoading, selectedBudget];
// }

// lib/features/budget/presentation/bloc/budget_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_entity.dart';

class BudgetState extends Equatable {
  final String selectedTab;
  final List<BudgetEntity> budgets;
  final bool isLoading;
  final BudgetEntity? selectedBudget;

  final String addAmount;
  final String addName;
  final String? addCategory;
  final String addSource;
  final DateTime addStartDate;
  final DateTime addEndDate;

  const BudgetState({
    required this.selectedTab,
    required this.budgets,
    this.isLoading = false,
    this.selectedBudget,
    this.addAmount = "",
    this.addName = "",
    this.addCategory,
    this.addSource = "Cash",
    required this.addStartDate,
    required this.addEndDate,
  });

  factory BudgetState.initial() => BudgetState(
    selectedTab: "Active",
    budgets: [],
    isLoading: true,
    selectedBudget: null,
    addAmount: "",
    addName: "",
    addCategory: null,
    addSource: "Cash",
    addStartDate: DateTime.now(),
    addEndDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
  );

  BudgetState copyWith({
    String? selectedTab,
    List<BudgetEntity>? budgets,
    bool? isLoading,
    BudgetEntity? selectedBudget,

    // Add Budget Form
    String? addAmount,
    String? addName,
    String? addCategory,
    String? addSource,
    DateTime? addStartDate,
    DateTime? addEndDate,
  }) {
    return BudgetState(
      selectedTab: selectedTab ?? this.selectedTab,
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      selectedBudget: selectedBudget ?? this.selectedBudget,

      addAmount: addAmount ?? this.addAmount,
      addName: addName ?? this.addName,
      addCategory: addCategory ?? this.addCategory,
      addSource: addSource ?? this.addSource,
      addStartDate: addStartDate ?? this.addStartDate,
      addEndDate: addEndDate ?? this.addEndDate,
    );
  }

  @override
  List<Object?> get props => [selectedTab, budgets, isLoading, selectedBudget];
}
