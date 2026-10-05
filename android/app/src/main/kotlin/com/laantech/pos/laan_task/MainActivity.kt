package com.laantech.pos.laan_task

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "public_download_storage"
    }

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "moveToDownloads" -> {
                    val sourcePath =
                        call.argument<String>("sourcePath")

                    val fileName =
                        call.argument<String>("fileName")

                    if (sourcePath == null ||
                        fileName == null
                    ) {
                        result.error(
                            "INVALID_ARGUMENT",
                            "sourcePath and fileName are required",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val output =
                            moveToDownloads(
                                sourcePath,
                                fileName
                            )

                        result.success(
                            mapOf(
                                "uri" to output.uri,
                                "size" to output.size
                            )
                        )
                    } catch (e: Exception) {
                        result.error(
                            "DOWNLOAD_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private data class DownloadResult(
        val uri: String,
        val size: Long
    )

    private fun moveToDownloads(
        sourcePath: String,
        fileName: String
    ): DownloadResult {

        val sourceFile = File(sourcePath)

        if (!sourceFile.exists()) {
            throw IllegalStateException(
                "Source file does not exist: $sourcePath"
            )
        }

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            moveToDownloadsModern(
                sourceFile,
                fileName
            )
        } else {
            moveToDownloadsLegacy(
                sourceFile,
                fileName
            )
        }
    }

    /**
     * Android 10+
     *
     * Uses MediaStore.
     *
     * No storage permission is required.
     */
    @RequiresApi(Build.VERSION_CODES.Q)
    private fun moveToDownloadsModern(
        sourceFile: File,
        fileName: String
    ): DownloadResult {

        val resolver = contentResolver

        val mimeType =
            getMimeType(fileName)

        val values = ContentValues().apply {
            put(
                MediaStore.Downloads.DISPLAY_NAME,
                fileName
            )

            put(
                MediaStore.Downloads.MIME_TYPE,
                mimeType
            )

            put(
                MediaStore.Downloads.RELATIVE_PATH,
                Environment.DIRECTORY_DOWNLOADS
            )

            put(
                MediaStore.Downloads.IS_PENDING,
                1
            )
        }

        val collection =
            MediaStore.Downloads.EXTERNAL_CONTENT_URI

        val uri = resolver.insert(
            collection,
            values
        ) ?: throw IllegalStateException(
            "Failed to create Downloads MediaStore entry."
        )

        try {
            resolver.openOutputStream(uri).use { output ->

                if (output == null) {
                    throw IllegalStateException(
                        "Could not open Downloads output stream."
                    )
                }

                FileInputStream(sourceFile).use { input ->

                    val buffer = ByteArray(
                        DEFAULT_BUFFER_SIZE
                    )

                    while (true) {
                        val count = input.read(buffer)

                        if (count == -1) {
                            break
                        }

                        output.write(
                            buffer,
                            0,
                            count
                        )
                    }

                    output.flush()
                }
            }

            // Make the file visible to the user.
            val updateValues =
                ContentValues().apply {
                    put(
                        MediaStore.Downloads.IS_PENDING,
                        0
                    )
                }

            resolver.update(
                uri,
                updateValues,
                null,
                null
            )

            val size =
                resolver.openAssetFileDescriptor(
                    uri,
                    "r"
                )?.use {
                    it.length
                } ?: sourceFile.length()

            // Source is no longer needed.
            sourceFile.delete()

            return DownloadResult(
                uri = uri.toString(),
                size = size
            )

        } catch (e: Exception) {

            // Remove incomplete MediaStore entry.
            resolver.delete(
                uri,
                null,
                null
            )

            throw e
        }
    }

    /**
     * Android 9 and below.
     *
     * Requires WRITE_EXTERNAL_STORAGE.
     */
    private fun moveToDownloadsLegacy(
        sourceFile: File,
        fileName: String
    ): DownloadResult {

        val permission =
            android.Manifest.permission.WRITE_EXTERNAL_STORAGE

        if (
            checkSelfPermission(permission) !=
            android.content.pm.PackageManager.PERMISSION_GRANTED
        ) {
            throw SecurityException(
                "WRITE_EXTERNAL_STORAGE permission is required."
            )
        }

        val downloadsDir =
            Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS
            )

        if (!downloadsDir.exists()) {
            downloadsDir.mkdirs()
        }

        val destination =
            File(
                downloadsDir,
                fileName
            )

        if (destination.exists()) {
            destination.delete()
        }

        sourceFile.copyTo(
            destination,
            overwrite = true
        )

        val size = destination.length()

        sourceFile.delete()

        return DownloadResult(
            uri = destination.absolutePath,
            size = size
        )
    }

    private fun getMimeType(
        fileName: String
    ): String {

        val extension =
            fileName.substringAfterLast(
                '.',
                ""
            ).lowercase()

        return when (extension) {

            "mp3" ->
                "audio/mpeg"

            "wav" ->
                "audio/wav"

            "m4a" ->
                "audio/mp4"

            "aac" ->
                "audio/aac"

            "flac" ->
                "audio/flac"

            "ogg" ->
                "audio/ogg"

            "opus" ->
                "audio/opus"

            "mp4" ->
                "video/mp4"

            "mkv" ->
                "video/x-matroska"

            "avi" ->
                "video/x-msvideo"

            "jpg", "jpeg" ->
                "image/jpeg"

            "png" ->
                "image/png"

            "gif" ->
                "image/gif"

            "webp" ->
                "image/webp"

            "pdf" ->
                "application/pdf"

            "zip" ->
                "application/zip"

            "rar" ->
                "application/vnd.rar"

            "7z" ->
                "application/x-7z-compressed"

            "txt" ->
                "text/plain"

            "json" ->
                "application/json"

            else ->
                "application/octet-stream"
        }
    }
}
