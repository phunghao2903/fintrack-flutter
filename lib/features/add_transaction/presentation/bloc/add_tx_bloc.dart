import 'package:fintrack/features/add_transaction/data/datasource/category.dart';
import 'package:fintrack/features/add_transaction/presentation/bloc/add_tx_event.dart';
import 'package:fintrack/features/add_transaction/presentation/bloc/add_tx_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddTxBloc extends Bloc<AddTxEvent, AddTxState> {
  AddTxBloc() : super(AddTxInitial()) {
    on<AddTxInitEvent>(_onInit);
    on<AddTxTabChangedEvent>(_onTabChanged);
    on<AddTxTypeChangedEvent>(_onTypeChanged);
    on<AddTxCategorySelectedEvent>(_onCategorySelected);
    on<AddTxAmountChangedEvent>(_onAmountChanged);
    on<AddTxDateChangedEvent>(_onDateChanged);
    on<AddTxMoneySourceChangedEvent>(_onMoneySourceChanged);
    on<AddTxNoteChangedEvent>(_onNoteChanged);
  }

  void _onInit(AddTxInitEvent event, Emitter<AddTxState> emit) {
    emit(AddTxLoading());
    emit(
      AddTxLoaded(
        tab: EntryTab.manual,
        type: TransactionType.expense,
        categories: expenseCategories,
        selectedCategoryIndex: null,
      ),
    );
  }

  void _onTabChanged(AddTxTabChangedEvent event, Emitter<AddTxState> emit) {
    final s = state;
    if (s is AddTxLoaded) {
      emit(s.copyWith(tab: event.tab));
    }
  }

  void _onTypeChanged(AddTxTypeChangedEvent event, Emitter<AddTxState> emit) {
    final s = state;
    if (s is AddTxLoaded) {
      final cats = event.type == TransactionType.expense
          ? expenseCategories
          : incomeCategories;
      emit(
        s.copyWith(
          type: event.type,
          categories: cats,
          selectedCategoryIndex: null,
        ),
      );
    }
  }

  void _onCategorySelected(
    AddTxCategorySelectedEvent event,
    Emitter<AddTxState> emit,
  ) {
    final s = state;
    if (s is AddTxLoaded) {
      emit(s.copyWith(selectedCategoryIndex: event.index));
    }
  }

  void _onAmountChanged(
    AddTxAmountChangedEvent event,
    Emitter<AddTxState> emit,
  ) {
    final s = state;
    if (s is AddTxLoaded) emit(s.copyWith(amount: event.amount));
  }

  void _onDateChanged(AddTxDateChangedEvent event, Emitter<AddTxState> emit) {
    final s = state;
    if (s is AddTxLoaded) emit(s.copyWith(date: event.date));
  }

  void _onMoneySourceChanged(
    AddTxMoneySourceChangedEvent event,
    Emitter<AddTxState> emit,
  ) {
    final s = state;
    if (s is AddTxLoaded) emit(s.copyWith(moneySource: event.moneySource));
  }

  void _onNoteChanged(AddTxNoteChangedEvent event, Emitter<AddTxState> emit) {
    final s = state;
    if (s is AddTxLoaded) emit(s.copyWith(note: event.note));
  }
}
