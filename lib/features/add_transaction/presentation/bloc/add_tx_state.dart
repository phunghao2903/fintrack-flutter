import 'package:fintrack/features/add_transaction/data/datasource/category.dart';
import 'package:fintrack/features/add_transaction/presentation/bloc/add_tx_event.dart';

abstract class AddTxState {}

class AddTxInitial extends AddTxState {}

class AddTxLoading extends AddTxState {}



class AddTxLoaded extends AddTxState {
  final EntryTab tab;
  final TransactionType type;

  final List<Category> categories;
  final int? selectedCategoryIndex;

  final String amount;
  final String date;
  final String moneySource;
  final String note;

  AddTxLoaded({
    required this.tab,
    required this.type,
    required this.categories,
    this.selectedCategoryIndex,
    this.amount = '',
    this.date = '',
    this.moneySource = '',
    this.note = '',
  });

  AddTxLoaded copyWith({
    EntryTab? tab,
    TransactionType? type,
    List<Category>? categories,
    int? selectedCategoryIndex,
    String? amount,
    String? date,
    String? moneySource,
    String? note,
  }) {
    return AddTxLoaded(
      tab: tab ?? this.tab,
      type: type ?? this.type,
      categories: categories ?? this.categories,
      selectedCategoryIndex: selectedCategoryIndex,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      moneySource: moneySource ?? this.moneySource,
      note: note ?? this.note,
    );
  }
}

class AddTxError extends AddTxState {
  final String error;
  AddTxError(this.error);
}