package com.a2soft.rutoken_flutter.models


sealed class DeviceEvent(private val type: String, private val deviceName: String) {
    class Added(deviceName: String) : DeviceEvent("added", deviceName)
    class Removed(deviceName: String) : DeviceEvent("removed", deviceName)

    fun toMap(): Map<String, String> {
        return mapOf(
            "type" to type,
            "deviceName" to deviceName
        )
    }
}