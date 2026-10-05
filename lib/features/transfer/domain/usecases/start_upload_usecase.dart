import 'dart:io';
import '../repositories/transfer_repository.dart';

class StartUploadUseCase {
  const StartUploadUseCase(this._repository);
  final TransferRepository _repository;

  Future<String> call(File file) => _repository.startUpload(file);
}
