import 'package:fintrack/features/add_transaction/domain/entities/transaction_entity.dart';

abstract class TextEntryState {}

class TextEntryInitial extends TextEntryState {}

class TextEntrySubmitting extends TextEntryState {}

class TextEntrySuccess extends TextEntryState {
  final TransactionEntity transaction;

  TextEntrySuccess(this.transaction);
}

class TextEntryFailure extends TextEntryState {
  final String message;

  TextEntryFailure(this.message);
}
