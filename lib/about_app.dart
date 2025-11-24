import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("About App"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // APP DESCRIPTION CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF6FBFB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "EatSmart is a simple and user-friendly nutrition tracking app "
                "designed to help you manage your daily food intake, build healthy "
                "recipes, and understand your nutrition clearly.\n\n"
                "Track calories, log food, create customized meals, and stay on top "
                "of your goals with an easy-to-use interface.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Key Features",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _featureTile(Icons.fastfood, "Log your daily meals easily"),
            _featureTile(
              Icons.pie_chart,
              "Track calories, protein, carbs & fat",
            ),
            _featureTile(
              Icons.receipt_long,
              "Create and save your own recipes",
            ),
            _featureTile(
              Icons.history,
              "View daily and weekly nutrition history",
            ),
            _featureTile(Icons.person, "Profile and personal details page"),

            const SizedBox(height: 30),

            const Text(
              "Developers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _devTile("Okkar Aung Aung", "Backend Developer"),
            _devTile("Kay Khaing Linn", "Frontend Developer"),

            const SizedBox(height: 40),
            Center(
              child: Text(
                "Version 1.0.0",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureTile(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4F4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8FDDE9), size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _devTile(String name, String role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFF9FAFA),
            child: Icon(Icons.person, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                role,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
