import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/downloaded_file_dao.dart';
import '../../../../core/database/downloaded_file_entity.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/auth_api_service.dart';
import '../../../auth/data/token_storage.dart';
import '../../data/api/transfer_api_service.dart';
import '../../data/local/transfer_local_data_source.dart';
import '../../data/repositories/transfer_repository_impl.dart';
import '../../data/workers/transfer_worker.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../domain/usecases/cancel_transfer_usecase.dart';
import '../../domain/usecases/delete_remote_file_usecase.dart';
import '../../domain/usecases/get_remote_files_usecase.dart';
import '../../domain/usecases/pause_transfer_usecase.dart';
import '../../domain/usecases/resume_transfer_usecase.dart';
import '../../domain/usecases/start_download_usecase.dart';
import '../../domain/usecases/start_upload_usecase.dart';

// Database Provider (overridden at app startup in main.dart)
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in ProviderScope');
});

// Downloaded File DAO
final downloadedFileDaoProvider = Provider<DownloadedFileDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.downloadedFileDao;
});

// Token Storage
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage();
});

// ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenProvider: () => tokenStorage.getToken());
});

// Auth API Service
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApiService(apiClient.dio);
});

// Transfer API Service
final transferApiServiceProvider = Provider<TransferApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransferApiService(apiClient.dio);
});

// Local Data Source
final transferLocalDataSourceProvider = Provider<TransferLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return TransferLocalDataSourceImpl(db.transferDao);
});

// Transfer Worker
final transferWorkerProvider = Provider<TransferWorker>((ref) {
  final apiService = ref.watch(transferApiServiceProvider);
  final localDataSource = ref.watch(transferLocalDataSourceProvider);
  final downloadedDao = ref.watch(downloadedFileDaoProvider);
  return TransferWorker(
    apiService: apiService,
    localDataSource: localDataSource,
    downloadedFileDao: downloadedDao,
  );
});

// Transfer Repository
final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  final apiService = ref.watch(transferApiServiceProvider);
  final localDataSource = ref.watch(transferLocalDataSourceProvider);
  final worker = ref.watch(transferWorkerProvider);
  final downloadedDao = ref.watch(downloadedFileDaoProvider);

  return TransferRepositoryImpl(
    apiService: apiService,
    localDataSource: localDataSource,
    worker: worker,
    downloadedFileDao: downloadedDao,
  );
});

// Use Cases
final startUploadUseCaseProvider = Provider<StartUploadUseCase>((ref) {
  return StartUploadUseCase(ref.watch(transferRepositoryProvider));
});

final startDownloadUseCaseProvider = Provider<StartDownloadUseCase>((ref) {
  return StartDownloadUseCase(ref.watch(transferRepositoryProvider));
});

final pauseTransferUseCaseProvider = Provider<PauseTransferUseCase>((ref) {
  return PauseTransferUseCase(ref.watch(transferRepositoryProvider));
});

final resumeTransferUseCaseProvider = Provider<ResumeTransferUseCase>((ref) {
  return ResumeTransferUseCase(ref.watch(transferRepositoryProvider));
});

final cancelTransferUseCaseProvider = Provider<CancelTransferUseCase>((ref) {
  return CancelTransferUseCase(ref.watch(transferRepositoryProvider));
});

final getRemoteFilesUseCaseProvider = Provider<GetRemoteFilesUseCase>((ref) {
  return GetRemoteFilesUseCase(ref.watch(transferRepositoryProvider));
});

final deleteRemoteFileUseCaseProvider = Provider<DeleteRemoteFileUseCase>((ref) {
  return DeleteRemoteFileUseCase(ref.watch(transferRepositoryProvider));
});

// Downloaded Files Providers
final downloadedFilesStreamProvider = StreamProvider<List<DownloadedFileEntity>>((ref) {
  final repo = ref.watch(transferRepositoryProvider);
  return repo.watchDownloadedFiles();
});

final downloadedFilesMapProvider = Provider<Map<int, DownloadedFileEntity>>((ref) {
  final asyncFiles = ref.watch(downloadedFilesStreamProvider);
  return asyncFiles.maybeWhen(
    data: (files) => {for (final f in files) f.fileId: f},
    orElse: () => {},
  );
});
