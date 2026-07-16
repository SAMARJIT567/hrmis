// 📁 lib/core/config/app_config.dart

import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    const String ip = '192.168.0.237';
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return 'http://$ip:8000/api';
    } else {
      return 'http://$ip:8000/api';
    }
  }

  static String get leaveApiBaseUrl {
    const String ip = '192.168.0.237';
    if (kIsWeb) {
      return 'http://localhost:8001/api';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return 'http://$ip:8001/api';
    } else {
      return 'http://$ip:8001/api';
    }
  }

  // Other configs
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
}