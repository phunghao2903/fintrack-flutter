import 'package:fintrack/features/add_transaction/domain/repositories/add_tx_repository.dart';

class DeleteTransactionUsecase {
  final AddTxRepository repo;

  DeleteTransactionUsecase(this.repo);

  Future<void> call({
    required String id,
    required String moneySourceId,
    required double amount,
    required bool isIncome,
  }) {
    return repo.deleteTransactionWithBalance(
      id: id,
      moneySourceId: moneySourceId,
      amount: amount,
      isIncome: isIncome,
    );
  }
}
