import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'about_app.dart';
import 'support_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFA),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            // PROFILE PREVIEW + NAVIGATION
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      //backgroundImage: AssetImage("assets/profile_default.png"),
                    ),

                    const SizedBox(width: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Okkar Aung",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "okkar@example.com",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),

                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.black45),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // FEATURE SECTION
            _sectionTitle("Features"),

            _tile(Icons.history, "History", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryScreen(date: "today"),
                ),
              );
            }),

            const SizedBox(height: 26),

            // SETTINGS SECTION
            _sectionTitle("Settings"),
            _switchTile("Dark Mode", Icons.dark_mode, false),
            _switchTile("Notifications", Icons.notifications, true),

            const SizedBox(height: 26),

            // OTHERS SECTION
            _sectionTitle("Others"),

            _tile(Icons.info, "About App", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutAppScreen()),
              );
            }),

            _tile(Icons.help_outline, "Help & Support", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              );
            }),

            const SizedBox(height: 30),

            // LOGOUT
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove("user_id"); // remove login token

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8FDDE9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 34,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ------------------------ UI PARTS ------------------------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, size: 28, color: const Color(0xFF8FDDE9)),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _switchTile(String title, IconData icon, bool defaultValue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        value: defaultValue,
        onChanged: (v) {},
        activeThumbColor: const Color(0xFF8FDDE9),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        secondary: Icon(icon, color: const Color(0xFF8FDDE9), size: 28),
      ),
    );
  }
}
