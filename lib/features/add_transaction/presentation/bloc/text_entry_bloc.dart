import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fintrack/features/add_transaction/domain/usecases/change_money_source_balance_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/get_money_sources_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/sync_is_income_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/update_budgets_with_transaction_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/upload_text_usecase.dart';
import 'text_entry_event.dart';
import 'text_entry_state.dart';

class TextEntryBloc extends Bloc<TextEntryEvent, TextEntryState> {
  final UploadTextUsecase uploadTextUsecase;
  final GetMoneySourcesUsecase getMoneySourcesUsecase;
  final ChangeMoneySourceBalanceUsecase changeMoneySourceBalanceUsecase;
  final UpdateBudgetsWithTransactionUsecase updateBudgetsWithTransactionUsecase;
  final SyncIsIncomeUseCase syncIsIncomeUseCase;
  final FirebaseAuth auth;

  TextEntryBloc({
    required this.uploadTextUsecase,
    required this.getMoneySourcesUsecase,
    required this.changeMoneySourceBalanceUsecase,
    required this.updateBudgetsWithTransactionUsecase,
    required this.syncIsIncomeUseCase,
    required this.auth,
  }) : super(TextEntryInitial()) {
    on<SubmitTextRequested>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubmitTextRequested event,
    Emitter<TextEntryState> emit,
  ) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) {
      emit(TextEntryFailure('User not logged in'));
      return;
    }

    emit(TextEntrySubmitting());
    try {
      final moneySources = await getMoneySourcesUsecase();

      final result = await uploadTextUsecase(
        text: event.text,
        userId: userId,
        moneySources: moneySources,
      );

      await result.fold<Future<void>>(
        (failure) async => emit(TextEntryFailure(failure.message)),
        (tx) async {
          await changeMoneySourceBalanceUsecase(
            moneySourceId: tx.moneySource.id,
            amount: tx.amount,
            isIncome: tx.isIncome,
          );
          await updateBudgetsWithTransactionUsecase(tx);
          await syncIsIncomeUseCase(tx);
          emit(TextEntrySuccess(tx));
        },
      );
    } catch (e) {
      emit(TextEntryFailure(e.toString()));
    }
  }
}
