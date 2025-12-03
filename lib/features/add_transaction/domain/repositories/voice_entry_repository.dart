import 'package:dartz/dartz.dart';
import 'package:fintrack/core/error/failure.dart';
import 'package:fintrack/features/add_transaction/domain/entities/money_source_entity.dart';
import 'package:fintrack/features/add_transaction/domain/entities/transaction_entity.dart';

abstract class VoiceEntryRepository {
  Future<Either<Failure, TransactionEntity>> uploadVoice(
    String voiceText,
    String userId,
    List<MoneySourceEntity> moneySources, {
    String? languageCode,
  });

  Future<void> syncIsIncomeIfNeeded(TransactionEntity tx);
}
