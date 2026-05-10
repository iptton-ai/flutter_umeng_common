import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FlutterUmengCommon {
  static const MethodChannel _channel = MethodChannel('flutter_umeng_common');

  static Future<bool?> init({
    required String androidAppKey,
    required String iosAppKey,
    required String channel,
  }) async {
    try {
      if (kDebugMode) debugPrint('[UMeng] calling init');
      final result = await _channel.invokeMethod<bool>('init', {
        'androidAppKey': androidAppKey,
        'iosAppKey': iosAppKey,
        'channel': channel,
      });
      if (kDebugMode) debugPrint('[UMeng] init result = $result');
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('[UMeng] init failed: $e');
      return false;
    }
  }

  static Future<bool?> startTracking() async {
    try {
      if (kDebugMode) debugPrint('[UMeng] calling startTracking');
      final result = await _channel.invokeMethod<bool>('startTracking');
      if (kDebugMode) debugPrint('[UMeng] startTracking result = $result');
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('[UMeng] startTracking failed: $e');
      return false;
    }
  }

  static Future<bool> onEvent(String event, Map<String, dynamic> properties) async {
    try {
      return await _channel.invokeMethod('onEvent', {"event": event, "properties": properties});
    } catch (e) {
      if (kDebugMode) debugPrint('[UMeng] onEvent failed: $e');
      return false;
    }
  }
}
