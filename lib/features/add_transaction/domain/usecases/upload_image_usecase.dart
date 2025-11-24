import 'dart:io';

import 'package:fintrack/features/add_transaction/domain/entities/upload_image_result.dart';
import 'package:fintrack/features/add_transaction/domain/repositories/image_entry_repository.dart';

class UploadImageUsecase {
  final ImageEntryRepository repository;

  UploadImageUsecase(this.repository);

  Future<UploadImageResult> call(File file) {
    return repository.uploadImage(file);
  }
}
