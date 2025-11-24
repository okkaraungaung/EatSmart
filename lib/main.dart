import 'package:eat_smart/home_screen.dart';
import 'package:eat_smart/login_screen.dart';
import 'package:eat_smart/user_session.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalorieTrackerApp());
}

class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});
  Future<Widget> _startScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    await UserSession.load();

    // If logged out → User must login
    if (userId == null) {
      return const LoginScreen();
    }

    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calorie Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: FutureBuilder(
        future: _startScreen(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}
