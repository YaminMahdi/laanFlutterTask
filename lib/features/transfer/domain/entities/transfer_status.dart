enum TransferStatus {
  queued,
  running,
  paused,
  completed,
  failed,
  cancelled;

  bool get isActive => this == TransferStatus.queued || this == TransferStatus.running;
  bool get isPaused => this == TransferStatus.paused;
  bool get isCompleted => this == TransferStatus.completed;
  bool get isFailed => this == TransferStatus.failed;
  bool get isCancelled => this == TransferStatus.cancelled;

  String get displayName {
    switch (this) {
      case TransferStatus.queued:
        return 'Queued';
      case TransferStatus.running:
        return 'In Progress';
      case TransferStatus.paused:
        return 'Paused';
      case TransferStatus.completed:
        return 'Completed';
      case TransferStatus.failed:
        return 'Failed';
      case TransferStatus.cancelled:
        return 'Cancelled';
    }
  }

  static TransferStatus fromString(String value) {
    return TransferStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TransferStatus.queued,
    );
  }
}
