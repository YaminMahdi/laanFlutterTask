import '../entities/remote_file_item.dart';
import '../repositories/transfer_repository.dart';

class GetRemoteFilesUseCase {
  const GetRemoteFilesUseCase(this._repository);
  final TransferRepository _repository;

  Future<List<RemoteFileItem>> call() => _repository.getRemoteFiles();
}
