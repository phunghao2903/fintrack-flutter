import 'package:fintrack/features/add_transaction/domain/entities/transaction_entity.dart';

class TransactionDetailState {
  final TransactionEntity transaction;
  final bool isDeleting;
  final bool deleted;
  final String? error;

  const TransactionDetailState({
    required this.transaction,
    this.isDeleting = false,
    this.deleted = false,
    this.error,
  });

  TransactionDetailState copyWith({
    TransactionEntity? transaction,
    bool? isDeleting,
    bool? deleted,
    String? error,
  }) {
    return TransactionDetailState(
      transaction: transaction ?? this.transaction,
      isDeleting: isDeleting ?? this.isDeleting,
      deleted: deleted ?? this.deleted,
      error: error,
    );
  }
}
