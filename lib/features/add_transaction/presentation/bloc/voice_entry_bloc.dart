import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fintrack/features/add_transaction/domain/entities/money_source_entity.dart';
import 'package:fintrack/features/add_transaction/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/change_money_source_balance_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/get_money_sources_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/sync_is_income_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/update_budgets_with_transaction_usecase.dart';
import 'package:fintrack/features/add_transaction/domain/usecases/upload_voice_usecase.dart';
import 'voice_entry_event.dart';
import 'voice_entry_state.dart';

class VoiceEntryBloc extends Bloc<VoiceEntryEvent, VoiceEntryState> {
  final UploadVoiceUsecase uploadVoiceUsecase;
  final GetMoneySourcesUsecase getMoneySourcesUsecase;
  final ChangeMoneySourceBalanceUsecase changeMoneySourceBalanceUsecase;
  final UpdateBudgetsWithTransactionUsecase updateBudgetsWithTransactionUsecase;
  final SyncIsIncomeUseCase syncIsIncomeUseCase;
  final FirebaseAuth auth;

  VoiceEntryBloc({
    required this.uploadVoiceUsecase,
    required this.getMoneySourcesUsecase,
    required this.changeMoneySourceBalanceUsecase,
    required this.updateBudgetsWithTransactionUsecase,
    required this.syncIsIncomeUseCase,
    required this.auth,
  }) : super(VoiceEntryInitial()) {
    on<UploadVoiceRequested>(_onUploadVoiceRequested);
    on<VoiceEntryReset>(_onReset);
  }

  Future<void> _onUploadVoiceRequested(
    UploadVoiceRequested event,
    Emitter<VoiceEntryState> emit,
  ) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) {
      emit(VoiceEntryFailure('User not logged in'));
      return;
    }

    emit(VoiceEntryUploading());
    try {
      final moneySources = await getMoneySourcesUsecase();
      if (moneySources.isEmpty) {
        emit(VoiceEntryFailure('No money source available'));
        return;
      }

      final result = await uploadVoiceUsecase(
        transcript: event.transcript,
        userId: userId,
        moneySources: moneySources,
        languageCode: event.languageCode,
        audioPath: event.audioPath,
      );

      await result.fold<Future<void>>(
        (failure) async => emit(VoiceEntryFailure(failure.message)),
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
          emit(VoiceEntrySuccess(normalizedTx));
        },
      );
    } catch (e) {
      emit(VoiceEntryFailure(e.toString()));
    }
  }

  void _onReset(VoiceEntryReset event, Emitter<VoiceEntryState> emit) {
    emit(VoiceEntryInitial());
  }

  // Always align the returned money source with an existing one to avoid
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
