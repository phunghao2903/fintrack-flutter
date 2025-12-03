import 'package:dartz/dartz.dart';
import 'package:fintrack/core/error/failure.dart';
import 'package:fintrack/features/add_transaction/domain/entities/money_source_entity.dart';
import 'package:fintrack/features/add_transaction/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/add_transaction/domain/repositories/voice_entry_repository.dart';

class UploadVoiceUsecase {
  final VoiceEntryRepository repository;

  UploadVoiceUsecase(this.repository);

  Future<Either<Failure, TransactionEntity>> call({
    required String voiceText,
    required String userId,
    required List<MoneySourceEntity> moneySources,
    String? languageCode,
  }) {
    return repository.uploadVoice(
      voiceText,
      userId,
      moneySources,
      languageCode: languageCode,
    );
  }
}
