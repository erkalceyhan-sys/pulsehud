import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WallpaperService {
  static const MethodChannel _channel = MethodChannel('com.pulsehud.app/wallpaper');

  static Future<bool> setLiveWallpaper() async {
    try {
      final bool result = await _channel.invokeMethod('setLiveWallpaper');
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to set live wallpaper: '${e.message}'.");
      return false;
    }
  }

  static Future<bool> activateIosLockScreenWidget() async {
    try {
      final bool result = await _channel.invokeMethod('openWidgetGuide');
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to open widget guide: '${e.message}'.");
      return false;
    }
  }
}
