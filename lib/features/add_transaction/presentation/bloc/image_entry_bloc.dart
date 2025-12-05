import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fintrack/features/add_transaction/domain/entities/money_source_entity.dart';
import 'package:fintrack/features/add_transaction/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/change_money_source_balance_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/sync_is_income_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/update_budgets_with_transaction_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/upload_image_usecase.dart';
import 'image_entry_event.dart';
import 'image_entry_state.dart';

class ImageEntryBloc extends Bloc<ImageEntryEvent, ImageEntryState> {
  final UploadImageUsecase uploadImageUsecase;
  final ChangeMoneySourceBalanceUsecase changeMoneySourceBalanceUsecase;
  final SyncIsIncomeUseCase syncIsIncomeUseCase;
  final UpdateBudgetsWithTransactionUsecase updateBudgetsWithTransactionUsecase;
  final FirebaseAuth auth;

  ImageEntryBloc({
    required this.uploadImageUsecase,
    required this.changeMoneySourceBalanceUsecase,
    required this.syncIsIncomeUseCase,
    required this.updateBudgetsWithTransactionUsecase,
    required this.auth,
  }) : super(ImageEntryInitial()) {
    on<UploadImageRequested>(_onUploadImageRequested);
  }

  Future<void> _onUploadImageRequested(
    UploadImageRequested event,
    Emitter<ImageEntryState> emit,
  ) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) {
      emit(ImageEntryFailure('User not logged in'));
      return;
    }

    emit(ImageEntryUploading());
    try {
      final result = await uploadImageUsecase(
        image: event.image,
        userId: userId,
        moneySources: event.moneySources,
      );
      await result.fold<Future<void>>(
        (failure) async => emit(ImageEntryFailure(failure.message)),
        (tx) async {
          if (event.moneySources.isEmpty) {
            emit(ImageEntryFailure('No money source available'));
            return;
          }

          final normalizedTx =
              _normalizeMoneySource(tx, event.moneySources.toList());
          await changeMoneySourceBalanceUsecase(
            moneySourceId: normalizedTx.moneySource.id,
            amount: normalizedTx.amount,
            isIncome: normalizedTx.isIncome,
          );
          if (!normalizedTx.isIncome) {
            await updateBudgetsWithTransactionUsecase(normalizedTx);
            await syncIsIncomeUseCase(normalizedTx);
          }
          emit(ImageEntryUploadSuccess(normalizedTx));
        },
      );
    } catch (e) {
      emit(ImageEntryFailure(e.toString()));
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
