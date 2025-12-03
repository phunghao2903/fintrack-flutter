import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          await changeMoneySourceBalanceUsecase(
            moneySourceId: tx.moneySource.id,
            amount: tx.amount,
            isIncome: tx.isIncome,
          );
          await updateBudgetsWithTransactionUsecase(tx);
          await syncIsIncomeUseCase(tx);
          emit(VoiceEntrySuccess(tx));
        },
      );
    } catch (e) {
      emit(VoiceEntryFailure(e.toString()));
    }
  }

  void _onReset(VoiceEntryReset event, Emitter<VoiceEntryState> emit) {
    emit(VoiceEntryInitial());
  }
}
