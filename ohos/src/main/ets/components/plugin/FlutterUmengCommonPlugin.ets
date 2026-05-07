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
import { init, InternalPlugin, onEventObject, preInit, setLogEnabled } from '@umeng/analytics';

/** FlutterUmengCommonPlugin **/
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
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_umeng_common");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "init") {
      const appKey: string = call.argument("androidAppKey") ?? call.argument("iosAppKey") ?? ""
      const channel: string = call.argument("channel") ?? "default"
      preInit({
        appKey: appKey,
        channel: channel,
        context: this.uiContext?.getApplicationContext(),
        plugins: [new InternalPlugin()]
      });
      init()
      setLogEnabled(false)
      result.success(true)
    } else if (call.method == "onEvent") {
      const event: string = call.argument("event")
      const properties: Record<string, string | number> = call.argument("properties") as Record<string, string | number>
      onEventObject(event, properties);
      result.success(true)
    } else {
      result.notImplemented()
    }
  }
}