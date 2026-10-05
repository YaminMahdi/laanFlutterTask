import '../repositories/transfer_repository.dart';

class ResumeTransferUseCase {
  const ResumeTransferUseCase(this._repository);
  final TransferRepository _repository;

  Future<void> call(String id) => _repository.resumeTransfer(id);
}
