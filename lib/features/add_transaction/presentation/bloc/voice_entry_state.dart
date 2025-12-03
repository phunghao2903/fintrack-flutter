import 'package:fintrack/features/add_transaction/domain/entities/transaction_entity.dart';

abstract class VoiceEntryState {}

class VoiceEntryInitial extends VoiceEntryState {}

class VoiceEntryUploading extends VoiceEntryState {}

class VoiceEntrySuccess extends VoiceEntryState {
  final TransactionEntity transaction;

  VoiceEntrySuccess(this.transaction);
}

class VoiceEntryFailure extends VoiceEntryState {
  final String message;

  VoiceEntryFailure(this.message);
}
