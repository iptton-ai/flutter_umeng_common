package com.umeng.flutter_umeng_common

import android.content.Context
import com.umeng.analytics.MobclickAgent
import com.umeng.commonsdk.UMConfigure
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** FlutterUmengCommonPlugin */
class FlutterUmengCommonPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var application: Context

    // init 时暂存，供用户同意隐私政策后的 startTracking 做全量初始化
    private var appKey: String = ""
    private var umengChannel: String = ""
    private var inited = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_umeng_common")
        channel.setMethodCallHandler(this)
        application = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> {
                // 合规语义（与 OHOS 侧一致）：仅 preInit，不读取/上报任何设备信息。
                // 全量 init 必须等用户同意隐私政策后由 startTracking 触发——
                // 华为审核机会在同意前自动授予已声明权限并跑 SDK，preInit+init
                // 连调会被判「用户同意隐私政策前采集 ICCID/IMSI/IMEI/ANDROID ID」
                // （审核指南 7.5，cchess hw v130 打回根因）。
                appKey = call.argument<String>("androidAppKey") ?: ""
                umengChannel = call.argument("channel") ?: ""
                UMConfigure.preInit(application, appKey, umengChannel)
                result.success(true)
            }

            "startTracking" -> {
                // 用户已同意隐私政策：全量初始化，开始正式采集
                if (!inited) {
                    UMConfigure.init(application, appKey, umengChannel, UMConfigure.DEVICE_TYPE_PHONE, "")
                    inited = true
                }
                result.success(true)
            }

            "onEvent" -> {
                val event = call.argument<String>("event") ?: ""
                val properties = call.argument<Map<String, Any>>("properties") ?: emptyMap()
                MobclickAgent.onEventObject(application, event, properties)
                result.success(true)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
