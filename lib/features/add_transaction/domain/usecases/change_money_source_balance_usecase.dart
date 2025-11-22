import 'package:fintrack/features/add_transaction/domain/repositories/%20moneysource_repository.dart';
// import 'package:fintrack/features/add_transaction/domain/repositories/moneysource_repository.dart';

class ChangeMoneySourceBalanceUsecase {
  final MoneySourceRepository repo;

  ChangeMoneySourceBalanceUsecase(this.repo);

  /// amount: số tiền transaction
  /// isIncome: true = thu nhập (cộng), false = chi tiêu (trừ)
  Future<void> call({
    required String moneySourceId,
    required double amount,
    required bool isIncome,
  }) {
    final delta = isIncome ? amount : -amount;
    return repo.changeBalance(moneySourceId, delta);
  }
}
