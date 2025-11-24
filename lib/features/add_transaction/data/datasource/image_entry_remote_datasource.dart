import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fintrack/features/add_transaction/domain/entities/upload_image_result.dart';
import 'package:path/path.dart';

abstract class ImageEntryRemoteDataSource {
  Future<UploadImageResult> uploadImage(File file);
}

class ImageEntryRemoteDataSourceImpl implements ImageEntryRemoteDataSource {
  final Dio dio;
  final String webhookUrl;

  ImageEntryRemoteDataSourceImpl({
    required this.dio,
    required this.webhookUrl,
  });

  @override
  Future<UploadImageResult> uploadImage(File file) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        file.path,
        filename: basename(file.path),
      ),
    });

    final response = await dio.post(
      webhookUrl,
      data: formData,
      options: Options(validateStatus: (status) => true),
    );

    return UploadImageResult(
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  }
}
