import 'package:flutter/foundation.dart';

class AppConfig {
  /// Backend URLs for different platforms
  static const String androidLocal = "http://10.0.2.2:3000";
  static const String iosLocal = "http://localhost:3000";
  static const String webLocal = "http://localhost:3000";

  /// Your deployed backend (Vercel)
  static const String production = "https://your-vercel-url.vercel.app";

  /// Choose the correct backend dynamically
  static String get baseUrl {
    // Web
    if (kIsWeb) return webLocal;

    // Android emulator
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidLocal;
    }

    // iOS simulator
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosLocal;
    }

    // Fallback (real devices & others)
    return production;
  }
}
