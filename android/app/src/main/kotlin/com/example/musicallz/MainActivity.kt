package com.example.musicallz

import android.media.MediaMetadataRetriever
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "musicallz/metadata"
        ).setMethodCallHandler { call, result ->
            if (call.method != "readMetadata") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val filePath = call.argument<String>("filePath")
            if (filePath == null) {
                result.error("INVALID_ARGUMENT", "filePath is required", null)
                return@setMethodCallHandler
            }
            readMetadata(filePath, result)
        }
    }

    private fun readMetadata(filePath: String, result: MethodChannel.Result) {
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(filePath)
            result.success(buildMap(retriever))
        } catch (e: Exception) {
            result.error("METADATA_READ_FAILED", e.message, null)
        } finally {
            retriever.release()
        }
    }

    private fun buildMap(r: MediaMetadataRetriever): Map<String, Any?> {
        val track = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER)
        return mapOf(
            "title" to r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE),
            "artist" to r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST),
            "album" to r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM),
            "duration" to r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                ?.toLongOrNull(),
            "track" to track?.substringBefore('/')?.trim()?.toIntOrNull(),
            "year" to r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_YEAR)
                ?.toIntOrNull(),
            "albumArt" to r.embeddedPicture
        )
    }
}