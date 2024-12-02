package com.a2soft.rutoken_flutter

import android.content.Context
import com.a2soft.rutoken_flutter.models.DeviceEvent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import ru.rutoken.rtpcscbridge.RtPcscBridge
import ru.rutoken.rttransport.InitParameters
import ru.rutoken.rttransport.RtTransport
import ru.rutoken.rttransport.TokenInterface

/** RutokenFlutterPlugin */
class RutokenFlutterPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var eventChannel: EventChannel

  private var transport: RtTransport? = null
  private var observer: RtTransport.PcscReaderObserver? = null
  private val coroutineScope = CoroutineScope(Dispatchers.Main)

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "rutoken_flutter")
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "rutoken_flutter_devices")
    channel.setMethodCallHandler(this)
    eventChannel.setStreamHandler(this)
    context = flutterPluginBinding.applicationContext

    // Инициализация RtPcscBridge
    RtPcscBridge.setAppContext(context)

  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    try {
      when (call.method) {
        "initialize" -> {
          val isUSBEnabled = call.argument<Boolean>("isUSBEnabled")!!
          val isBluetoothEnabled = call.argument<Boolean>("isBluetoothEnabled")!!
          val isNFCEnabled = call.argument<Boolean>("isNFCEnabled")!!
          initializeTransport(result, isUSBEnabled, isBluetoothEnabled, isNFCEnabled)
        }
        else -> {
          result.notImplemented()
        }
      }
    } catch (e: Exception) {
      result.error("UNEXCEPCTED_ERROR", e.message, null)
    }
  }

  private fun initializeTransport(
    result: Result,
    isUSBEnabled: Boolean,
    isBluetoothEnabled: Boolean,
    isNFCEnabled: Boolean,
  ) {
    try {
      val initParamsBuilder = InitParameters.Builder()

      val interfacesToAdd = mutableListOf<TokenInterface>()
      if (isUSBEnabled) {
        interfacesToAdd.add(TokenInterface.USB)
      }
      if (isBluetoothEnabled) {
        interfacesToAdd.add(TokenInterface.BLUETOOTH)
      }
      if (isNFCEnabled) {
        interfacesToAdd.add(TokenInterface.NFC)
      }
      initParamsBuilder.setEnabledTokenInterfaces(*interfacesToAdd.toTypedArray())

      val initParams = initParamsBuilder.build()
      transport = RtPcscBridge.getTransport()
      transport?.initialize(context, initParams)

      result.success("Transport initialized")
    } catch (e: Exception) {
      result.error("INITIALIZATION_ERROR", e.message, null)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    coroutineScope.launch {
      observer = object : RtTransport.PcscReaderObserver {
        override fun onReaderAdded(reader: RtTransport.PcscReader) {
          events?.success(DeviceEvent.Added(reader.name).toMap())
        }

        override fun onReaderRemoved(reader: RtTransport.PcscReader) {
          events?.success(DeviceEvent.Removed(reader.name).toMap())
        }
      }

      transport?.addPcscReaderObserver(observer!!)
    }
  }

  override fun onCancel(arguments: Any?) {
    if (observer != null) {
      transport?.removePcscReaderObserver(observer!!)
    }
  }
}
