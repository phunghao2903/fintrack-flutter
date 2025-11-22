import 'package:fintrack/features/add_transaction/domain/entities/transaction_entity.dart';

abstract class TransactionDetailEvent {}

class TransactionDeleteRequested extends TransactionDetailEvent {
  final TransactionEntity transaction;
  TransactionDeleteRequested(this.transaction);
}

class TransactionDetailUpdated extends TransactionDetailEvent {
  final TransactionEntity transaction;
  TransactionDetailUpdated(this.transaction);
}
