import '../repositories/transfer_repository.dart';

class DeleteRemoteFileUseCase {
  const DeleteRemoteFileUseCase(this._repository);
  final TransferRepository _repository;

  Future<bool> call(String fileName) => _repository.deleteRemoteFile(fileName);
}
