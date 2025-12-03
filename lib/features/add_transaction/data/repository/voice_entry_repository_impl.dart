import 'package:dartz/dartz.dart';
import 'package:fintrack/core/error/failure.dart';
import 'package:fintrack/features/add_transaction/data/datasource/voice_entry_remote_datasource.dart';
import 'package:fintrack/features/add_transaction/data/model/transaction_model.dart';
import 'package:fintrack/features/add_transaction/domain/entities/money_source_entity.dart';
import 'package:fintrack/features/add_transaction/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/add_transaction/domain/repositories/voice_entry_repository.dart';

class VoiceEntryRepositoryImpl implements VoiceEntryRepository {
  final VoiceEntryRemoteDataSource remoteDataSource;

  VoiceEntryRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, TransactionEntity>> uploadVoice(
    String voiceText,
    String userId,
    List<MoneySourceEntity> moneySources, {
    String? languageCode,
  }) async {
    final serializedSources = moneySources
        .map((e) => {'id': e.id, 'name': e.name})
        .toList();
    try {
      final TransactionModel model = await remoteDataSource.uploadVoice(
        voiceText: voiceText,
        userId: userId,
        moneySources: serializedSources,
        languageCode: languageCode,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<void> syncIsIncomeIfNeeded(TransactionEntity tx) {
    return remoteDataSource.syncIsIncomeIfNeeded(tx);
  }
}
