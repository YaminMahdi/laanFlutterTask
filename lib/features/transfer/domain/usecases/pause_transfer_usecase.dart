import '../repositories/transfer_repository.dart';

class PauseTransferUseCase {
  const PauseTransferUseCase(this._repository);
  final TransferRepository _repository;

  Future<void> call(String id) => _repository.pauseTransfer(id);
}
