enum TransferType {
  upload,
  download;

  String get displayName {
    switch (this) {
      case TransferType.upload:
        return 'Upload';
      case TransferType.download:
        return 'Download';
    }
  }

  static TransferType fromString(String value) {
    return TransferType.values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TransferType.upload,
    );
  }
}
