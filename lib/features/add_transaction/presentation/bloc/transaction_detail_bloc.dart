import 'package:fintrack/features/add_transaction/domain/usecases/delete_transaction_usecase.dart';
import 'package:fintrack/features/add_transaction/presentation/bloc/transaction_detail_event.dart';
import 'package:fintrack/features/add_transaction/presentation/bloc/transaction_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionDetailBloc
    extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  final DeleteTransactionUsecase deleteTx;

  TransactionDetailBloc({
    required this.deleteTx,
    required TransactionDetailState initialState,
  }) : super(initialState) {
    on<TransactionDeleteRequested>(_onDelete);
    on<TransactionDetailUpdated>(_onUpdated);
  }

  void _onUpdated(
    TransactionDetailUpdated event,
    Emitter<TransactionDetailState> emit,
  ) {
    emit(state.copyWith(transaction: event.transaction, error: null));
  }

  Future<void> _onDelete(
    TransactionDeleteRequested event,
    Emitter<TransactionDetailState> emit,
  ) async {
    final tx = event.transaction;
    if (tx.id == null || tx.id!.isEmpty) {
      emit(state.copyWith(error: 'Transaction ID missing'));
      return;
    }

    try {
      emit(state.copyWith(isDeleting: true, error: null));
      await deleteTx(
        id: tx.id!,
        moneySourceId: tx.moneySource.id,
        amount: tx.amount,
        isIncome: tx.isIncome,
      );
      emit(state.copyWith(isDeleting: false, deleted: true));
    } catch (e) {
      emit(state.copyWith(isDeleting: false, error: e.toString()));
    }
  }
}
