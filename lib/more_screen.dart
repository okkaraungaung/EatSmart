import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("More"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView(
        children: [
          const SizedBox(height: 10),

          // PROFILE SECTION
          _buildSectionTitle("Account"),
          _buildTile(icon: Icons.person, title: "Profile", onTap: () {}),

          const SizedBox(height: 30),

          // FEATURES SECTION
          _buildSectionTitle("Features"),
          _buildTile(icon: Icons.bookmark, title: "My Recipes", onTap: () {}),
          _buildTile(icon: Icons.history, title: "Food History", onTap: () {}),

          const SizedBox(height: 30),

          // SETTINGS SECTION
          _buildSectionTitle("Settings"),
          _buildTile(icon: Icons.settings, title: "App Settings", onTap: () {}),

          _buildTile(
            icon: Icons.notifications,
            title: "Notifications",
            onTap: () {},
          ),

          const SizedBox(height: 30),

          // OTHERS SECTION
          _buildSectionTitle("Others"),
          _buildTile(icon: Icons.info, title: "About App", onTap: () {}),

          _buildTile(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {},
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Title "Features", "Settings", etc.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  // A single ListTile entry
  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 26, color: Colors.blue.shade600),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 70),
      ],
    );
  }
}
