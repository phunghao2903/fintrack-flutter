import 'package:dartz/dartz.dart';
import 'package:fintrack/core/error/failure.dart';
import 'package:fintrack/features/add_transaction/domain/entities/money_source_entity.dart';
import 'package:fintrack/features/add_transaction/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/add_transaction/domain/repositories/image_entry_repository.dart';

class UploadTextUsecase {
  final ImageEntryRepository repository;

  UploadTextUsecase(this.repository);

  Future<Either<Failure, TransactionEntity>> call({
    required String text,
    required String userId,
    required List<MoneySourceEntity> moneySources,
  }) {
    return repository.uploadText(text, userId, moneySources);
  }
}
