import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceIdentifier {
  static Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String identifier = 'unknown';

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // Usar Android ID como identificador
        identifier = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        // Usar identificador único de iOS
        identifier = iosInfo.identifierForVendor ?? 'unknown';
      }
    } catch (e) {
      print('Error al obtener el identificador del dispositivo: $e');
      identifier = 'error_${DateTime.now().millisecondsSinceEpoch}';
    }

    return identifier;
  }
}
