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
      debugPrint('[UMeng] Dart: calling init via MethodChannel');
      final result = await _channel.invokeMethod<bool>('init', {
        'androidAppKey': androidAppKey,
        'iosAppKey': iosAppKey,
        'channel': channel,
      });
      debugPrint('[UMeng] Dart: init result = $result');
      return result;
    } catch (e) {
      debugPrint('[UMeng] Dart: init FAILED: $e');
      return false;
    }
  }

  static Future<bool> onEvent(String event, Map<String, dynamic> properties) async {
    try {
      return await _channel.invokeMethod('onEvent', {"event": event, "properties": properties});
    } catch (e) {
      debugPrint('[UMeng] Dart: onEvent FAILED: $e');
      return false;
    }
  }
}
