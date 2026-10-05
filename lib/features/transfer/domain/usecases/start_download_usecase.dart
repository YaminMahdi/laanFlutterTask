import '../repositories/transfer_repository.dart';

class StartDownloadUseCase {
  const StartDownloadUseCase(this._repository);
  final TransferRepository _repository;

  Future<String> call({
    required String fileUrl,
    required String fileName,
    int? totalSize,
  }) {
    return _repository.startDownload(
      fileUrl: fileUrl,
      fileName: fileName,
      totalSize: totalSize,
    );
  }
}
