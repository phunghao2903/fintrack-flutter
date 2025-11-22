import 'package:fintrack/features/add_transaction/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/add_transaction/domain/repositories/add_tx_repository.dart';

class UpdateTransactionUsecase {
  final AddTxRepository repo;

  UpdateTransactionUsecase(this.repo);

  Future<void> call({
    required TransactionEntity oldTx,
    required TransactionEntity newTx,
  }) {
    return repo.updateTransactionWithBalance(oldTx: oldTx, newTx: newTx);
  }
}
