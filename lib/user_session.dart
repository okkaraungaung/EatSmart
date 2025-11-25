import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? userId;
  static String? name;
  static String? email;
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return; // prevent reloading
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("user_id");
    name = prefs.getString("name");
    email = prefs.getString("email");
    _loaded = true;
  }
}
