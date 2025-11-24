import 'dart:io';

import 'package:fintrack/features/add_transaction/data/datasource/image_entry_remote_datasource.dart';
import 'package:fintrack/features/add_transaction/domain/entities/upload_image_result.dart';
import 'package:fintrack/features/add_transaction/domain/repositories/image_entry_repository.dart';

class ImageEntryRepositoryImpl implements ImageEntryRepository {
  final ImageEntryRemoteDataSource remoteDataSource;

  ImageEntryRepositoryImpl(this.remoteDataSource);

  @override
  Future<UploadImageResult> uploadImage(File file) {
    return remoteDataSource.uploadImage(file);
  }
}
