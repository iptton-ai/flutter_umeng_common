import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { agree, init, InternalPlugin, onEventObject, preInit, setLogEnabled } from '@umeng/analytics';

const IS_DEBUG: boolean = false
const TAG = 'UMengPlugin'
const DOMAIN = 0xFF00

function debugLog(msg: string): void {
  if (IS_DEBUG) {
    hilog.debug(DOMAIN, TAG, msg)
  }
}

export default class FlutterUmengCommonPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private uiContext: common.UIAbilityContext | null = null;

  constructor() {
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.uiContext = binding.getAbility().context;
  }

  onDetachedFromAbility(): void {
    this.uiContext = null;
  }

  getUniqueClassName(): string {
    return "FlutterUmengCommonPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    debugLog('onAttachedToEngine')
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_umeng_common");
    this.channel.setMethodCallHandler(this)
    debugLog('MethodChannel registered')
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    debugLog(`onMethodCall: ${call.method}`)
    if (call.method == "init") {
      const appKey: string = call.argument("androidAppKey") ?? call.argument("iosAppKey") ?? ""
      const channel: string = call.argument("channel") ?? "default"
      debugLog(`init appKey=${appKey} channel=${channel}`)
      preInit({
        appKey: appKey,
        channel: channel,
        context: this.uiContext?.getApplicationContext(),
        plugins: [new InternalPlugin()]
      });
      setLogEnabled(IS_DEBUG)
      debugLog('preInit done')
      result.success(true)
    } else if (call.method == "startTracking") {
      debugLog('startTracking: agree + init')
      agree()
      init().then(() => {
        hilog.info(DOMAIN, TAG, 'startTracking done (init resolved)')
        result.success(true)
      }).catch((err: Error) => {
        hilog.error(DOMAIN, TAG, `startTracking failed: ${err.message}`)
        result.success(false)
      })
    } else if (call.method == "onEvent") {
      const event: string = call.argument("event")
      const properties: Record<string, string | number> = call.argument("properties") as Record<string, string | number>
      debugLog(`onEvent: ${event}, params: ${JSON.stringify(properties)}`)
      onEventObject(event, properties);
      debugLog(`onEvent done: ${event}`)
      result.success(true)
    } else {
      result.notImplemented()
    }
  }
}
