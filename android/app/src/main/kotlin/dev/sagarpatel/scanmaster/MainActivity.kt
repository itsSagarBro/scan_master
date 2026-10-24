package dev.sagarpatel.scanmaster

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val TILE_CHANNEL = "dev.sagarpatel.scanmaster/tile"
    private val SHORTCUT_CHANNEL = "dev.sagarpatel.scanmaster/shortcuts"

    private var tileMethodChannel: MethodChannel? = null
    private var shortcutMethodChannel: MethodChannel? = null

    private var pendingTileTrigger = false
    private var pendingShortcutAction: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Quick Settings Tile Channel
        tileMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TILE_CHANNEL)
        tileMethodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "checkTileLaunch") {
                result.success(pendingTileTrigger)
                pendingTileTrigger = false
            } else {
                result.notImplemented()
            }
        }
        if (intent?.action == "dev.sagarpatel.scanmaster.ACTION_SCAN_TILE") {
            pendingTileTrigger = true
        }

        // 2. Launcher Shortcuts Channel
        shortcutMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHORTCUT_CHANNEL)
        shortcutMethodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "getInitialShortcut") {
                result.success(pendingShortcutAction)
                pendingShortcutAction = null
            } else {
                result.notImplemented()
            }
        }
        handleShortcutIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        // Handle Quick Settings Tile
        if (intent.action == "dev.sagarpatel.scanmaster.ACTION_SCAN_TILE") {
            tileMethodChannel?.invokeMethod("onTileClicked", null)
        }

        // Handle Launcher Shortcut while app is in memory
        val action = extractShortcutAction(intent)
        if (action != null) {
            shortcutMethodChannel?.invokeMethod("onShortcutTriggered", action)
        }
    }

    private fun handleShortcutIntent(intent: Intent?) {
        val action = extractShortcutAction(intent)
        if (action != null) {
            pendingShortcutAction = action
        }
    }

    private fun extractShortcutAction(intent: Intent?): String? {
        return when (intent?.action) {
            "dev.sagarpatel.scanmaster.ACTION_SCAN_CAMERA" -> "scan_camera"
            "dev.sagarpatel.scanmaster.ACTION_SCAN_GALLERY" -> "scan_gallery"
            "dev.sagarpatel.scanmaster.ACTION_CREATE_QR" -> "create_qr"
            else -> null
        }
    }
}