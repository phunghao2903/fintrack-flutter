import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fintrack/features/add_transaction/domain/entities/money_source_entity.dart';
import 'package:fintrack/features/add_transaction/domain/entities/transaction_entity.dart';
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
      if (moneySources.isEmpty) {
        emit(TextEntryFailure('No money source available'));
        return;
      }

      final result = await uploadTextUsecase(
        text: event.text,
        userId: userId,
        moneySources: moneySources,
      );

      await result.fold<Future<void>>(
        (failure) async => emit(TextEntryFailure(failure.message)),
        (tx) async {
          final normalizedTx = _normalizeMoneySource(tx, moneySources);
          await changeMoneySourceBalanceUsecase(
            moneySourceId: normalizedTx.moneySource.id,
            amount: normalizedTx.amount,
            isIncome: normalizedTx.isIncome,
          );
          if (!normalizedTx.isIncome) {
            await updateBudgetsWithTransactionUsecase(normalizedTx);
          }
          await syncIsIncomeUseCase(normalizedTx);
          emit(TextEntrySuccess(normalizedTx));
        },
      );
    } catch (e) {
      emit(TextEntryFailure(e.toString()));
    }
  }

  // Ensure the transaction references an existing money source to avoid
  // Firestore not-found errors when updating balances.
  TransactionEntity _normalizeMoneySource(
    TransactionEntity tx,
    List<MoneySourceEntity> availableSources,
  ) {
    final resolvedSource = _matchMoneySource(tx.moneySource, availableSources);
    if (resolvedSource.id == tx.moneySource.id) return tx;

    return TransactionEntity(
      id: tx.id,
      amount: tx.amount,
      dateTime: tx.dateTime,
      merchant: tx.merchant,
      category: tx.category,
      moneySource: resolvedSource,
      isIncome: tx.isIncome,
    );
  }

  MoneySourceEntity _matchMoneySource(
    MoneySourceEntity incoming,
    List<MoneySourceEntity> availableSources,
  ) {
    if (availableSources.isEmpty) {
      throw Exception('No money source available for current user');
    }

    for (final ms in availableSources) {
      if (ms.id == incoming.id) return ms;
    }

    final incomingName = incoming.name.trim().toLowerCase();
    for (final ms in availableSources) {
      if (ms.name.trim().toLowerCase() == incomingName) return ms;
    }

    return availableSources.first;
  }
}
