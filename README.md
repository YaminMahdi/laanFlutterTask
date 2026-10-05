# Flutter POS Background Upload & Download Module

Technical assessment submission for the Android POS Developer position at LAAN TECH USA Limited.

This project delivers a resilient file transfer engine tailored for point-of-sale environments, mirroring heavy enterprise workloads such as synchronizing master product catalogs (>50MB), importing multimedia assets, and exporting financial audit batches under unstable retail network conditions.

---

## 1. Architecture & Key Design Decisions

The application strictly implements Clean Architecture and separation of concerns, structured under `lib/core/` and `lib/features/`:

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart          # Endpoints, timeouts, buffers
│   ├── network/
│   │   ├── api_client.dart             # Dio HTTP client, timeouts, logging
│   │   ├── auth_interceptor.dart       # Bearer token injection and session recovery
│   │   ├── error_interceptor.dart      # Failure mapping from API and socket errors
│   │   └── network_info.dart           # Connection state verification
│   ├── database/
│   │   ├── app_database.dart           # SQLite database provider and schema migrations
│   │   ├── transfer_dao.dart           # Floor/DAO pattern for task queue CRUD
│   │   └── transfer_entity.dart        # Database entity model
│   ├── notifications/
│   │   └── notification_service.dart   # System tray notifications with progress and deep links
│   ├── theme/
│   │   └── app_theme.dart              # Material 3 POS high-contrast color scheme
│   └── router/
│       ├── app_router.dart             # Declarative AutoRoute configuration
│       └── app_router.gr.dart          # Generated type-safe routes
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_api_service.dart   # /api/token and /api/register requests
│   │   │   └── token_storage.dart      # Token persistence
│   │   └── presentation/
│   │       └── auth_notifier.dart      # Riverpod authentication state notifier
│   └── transfer/
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── transfer_task.dart  # Immutable domain model with progress/speed math
│       │   │   ├── transfer_status.dart# Status enum (queued, running, paused, completed, failed, cancelled)
│       │   │   ├── transfer_type.dart  # Transfer type enum (upload, download)
│       │   │   └── remote_file_item.dart# Server catalog file model
│       │   ├── repositories/
│       │   │   └── transfer_repository.dart # Abstract repository interface
│       │   └── usecases/               # Granular domain interactors
│       ├── data/
│       │   ├── api/
│       │   │   └── transfer_api_service.dart # Multipart upload & HTTP byte-stream downloading
│       │   ├── local/
│       │   │   └── transfer_local_data_source.dart # SQLite Floor-style DAO bridge
│       │   ├── workers/
│       │   │   └── transfer_worker.dart# Background transfer execution engine
│       │   └── repositories/
│       │       └── transfer_repository_impl.dart
│       └── presentation/
│           ├── notifiers/
│           │   ├── transfer_queue_notifier.dart # Global queue NotifierProvider
│           │   └── file_list_notifier.dart      # Remote catalog AsyncNotifierProvider
│           ├── widgets/
│           │   ├── transfer_progress_card.dart  # Real-time progress card with pause/resume
│           │   ├── transfer_summary_banner.dart # Persistent floating status banner
│           │   ├── pos_transfer_drawer.dart     # POS slide-over transfer manager
│           │   └── file_item_card.dart          # Remote catalog item card with thumbnails
│           └── screens/
│               ├── dashboard_screen.dart        # Adaptive POS master-detail / tab shell
│               ├── upload_screen.dart           # File picking (>50MB) and upload flow
│               ├── download_screen.dart         # Catalog browser and resumable downloads
│               └── transfer_queue_screen.dart   # Queue management and history
└── main.dart                                    # App entry point, services bootstrap
```

### Key Technical Decisions

1. State Management (Riverpod):
   - Uses `NotifierProvider` and `AsyncNotifierProvider` without legacy `StateNotifier`.
   - Immutable state models ensure deterministic widget tree rebuilds.
   - Fine-grained selectors isolate rebuilds to cards whose progress changed.

2. Resumable Chunked Downloads via HTTP Range Headers:
   - Partial downloads write to `<storage_dir>/<filename>.part`.
   - When resumed, the engine reads the byte length of `.part` on disk and sends:
     `Range: bytes=<existing_bytes>-`
   - Data streams directly into `FileMode.append` sink, avoiding loading large buffers into Dart isolate memory.
   - Upon completion, the `.part` file is atomically renamed to the destination file.

3. Background Upload Streaming:
   - Large files (>50MB) are streamed via `MultipartFile.fromFile` rather than reading entire byte arrays into RAM, preventing Out-Of-Memory (OOM) faults on constrained POS hardware.
   - `onSendProgress` streams byte counts to calculate smoothed transfer velocity.

4. Database Engine & Queue Persistence:
   - Transfer states are stored in local SQLite (`transfers` table) via Floor DAO architectural pattern.
   - Queue records survive application restarts, power drops, or OS process reclamation.

5. System Tray Notifications & Deep Linking:
   - Active transfers display low-priority, ongoing progress notifications.
   - Completed transfers display high-priority persistent notifications with payload routing.
   - Progress notification calls are throttled to a 500ms cadence to avoid saturating Android's NotificationManager IPC binder transactions.

6. Responsive POS Layout:
   - Uses `LayoutBuilder` and `MediaQuery.sizeOf(context)` with a 600dp breakpoint.
   - Countertop POS terminals / tablets (>= 600dp) display dual-pane master-detail navigation.
   - Handheld POS devices (< 600dp) use adaptive bottom navigation with a persistent floating transfer banner.

---

## 2. Background Execution Strategy & Android Platform Limits

Operating large file transfers reliably on Android requires navigating strict operating system battery optimizations and lifecycle restrictions:

### 1. Foreground Service & Android 14+ Restrictions (API 34)
- Foreground Service Type: Starting in Android 14, apps using foreground services must declare explicit `foregroundServiceType` attributes. For file synchronization, `android:foregroundServiceType="dataSync"` is mandatory.
- Policy Time Limits: Android 14 enforces a runtime execution quota on `dataSync` services (typically 6 hours within a rolling 24-hour window when in the background). Long transfers must implement chunk checkpoints to resume seamlessly across restarts.
- System Tray Visibility: Running as a foreground service requires posting a user-visible notification via `startForeground()`. This project integrates `flutter_local_notifications` to keep the user informed with ongoing progress.

### 2. Doze Mode and App Standby Buckets
- Doze Mode (introduced in Android 6.0): When a POS tablet remains stationary on a counter unplugged and with the screen turned off, Android enters Deep Doze. Network access is suspended, wakelocks are ignored, and jobs are deferred to brief maintenance windows.
- Mitigation: Active transfers hold a `WAKE_LOCK` and register ongoing foreground notifications. For kiosk POS deployments, device administrators should whitelist the POS app from battery optimizations (`android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`).
- Standby Buckets: Rare or restricted buckets limit network access to specific execution windows. Running an ongoing user-initiated transfer with an active foreground notification elevates the app to the active bucket.

### 3. Cleartext HTTP Traffic (Android 9+)
- The assessment backend operates over unencrypted HTTP (`http://15.232.228.139`).
- Android 9 (API 28) and higher block cleartext HTTP by default.
- This project configures `android:usesCleartextTraffic="true"` in `android/app/src/main/AndroidManifest.xml` to allow secure interaction with the assessment server.

### 4. Storage Access & Android 13+ Scoped Storage
- Android 10+ (API 29+) deprecated raw filesystem access in favor of Scoped Storage.
- Downloads are placed into app-specific external storage (`getExternalStorageDirectory()/downloads`) or app documents directory (`getApplicationDocumentsDirectory()`). This requires no runtime storage permissions while keeping files accessible to the POS operator via `open_filex`.

---

## 3. Known Limitations & Future Improvements

1. Chunked Upload Support:
   - The current upload module streams files via standard `multipart/form-data`. While this handles >50MB files efficiently and supports cancellation, upload resumption requires server-side support for chunked upload protocols (such as TUS or multipart presigned upload tokens).
2. WorkManager Fallback:
   - For transfers scheduled during store closing or offline shifts, integrating Android `WorkManager` with exponential backoff constraints (`NetworkType.CONNECTED`) would provide background execution even after device reboots.
3. MD5 / SHA-256 Checksums:
   - Adding cryptographic hashing before and after file transmission would guarantee zero data corruption during catalog imports.

---

## 4. Run Instructions

### Prerequisites
- Flutter SDK 3.13+ / 3.47+
- Dart SDK 3.13+
- Android Studio / Android SDK (Platform 34+)
- Connected Android device, emulator, or Windows desktop target

### Build Steps

1. Clone repository:
```bash
git clone https://github.com/yamin-mahdi/pos-transfer-module.git
cd pos-transfer-module
```

2. Fetch dependencies:
```bash
flutter pub get
```

3. Run code generation (AutoRoute, Freezed):
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Run static analysis:
```bash
dart analyze
```

5. Run test suite:
```bash
flutter test
```

6. Run the application:
```bash
# Run on connected Android device/emulator
flutter run -d android

# Or run on Windows desktop
flutter run -d windows
```

7. Build Release APK:
```bash
flutter build apk --release
```
The output APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 5. License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
