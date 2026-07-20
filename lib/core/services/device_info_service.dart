import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceDetails {
  final String deviceId;
  final String deviceName;

  DeviceDetails({
    required this.deviceId,
    required this.deviceName,
  });

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'device_name': deviceName,
      };
}

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Retrieves the unique Device ID and Human-Readable Device Name for Android & iOS
  static Future<DeviceDetails> getDeviceDetails() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfoPlugin.webBrowserInfo;
        return DeviceDetails(
          deviceId: 'web_${webInfo.vendor}_${webInfo.userAgent.hashCode}',
          deviceName: 'Browser (${webInfo.browserName.name})',
        );
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        // androidInfo.id provides unique Android hardware/build ID
        final String deviceId = androidInfo.id.isNotEmpty 
            ? androidInfo.id 
            : '${androidInfo.manufacturer}_${androidInfo.model}';
        final String deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';

        return DeviceDetails(
          deviceId: deviceId,
          deviceName: deviceName,
        );
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        // identifierForVendor provides unique vendor UUID for iOS
        final String deviceId = iosInfo.identifierForVendor ?? 'ios_unknown_id';
        final String deviceName = '${iosInfo.name} (${iosInfo.model})';

        return DeviceDetails(
          deviceId: deviceId,
          deviceName: deviceName,
        );
      } else {
        return DeviceDetails(
          deviceId: 'unknown_platform_id',
          deviceName: 'Unknown Platform',
        );
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return DeviceDetails(
        deviceId: 'fallback_device_id',
        deviceName: 'Mobile Device',
      );
    }
  }
}
