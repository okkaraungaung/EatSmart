import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFB),
      appBar: AppBar(
        title: const Text(
          "Help & Support",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How can we help you?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              "Find answers or reach out to our support team anytime.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            // FAQ SECTION
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _faqTile(
              "How do I add foods?",
              "Go to the home screen and tap the + button in the middle. Search food, adjust grams, and add it.",
            ),
            _faqTile(
              "How do I create a recipe?",
              "Go to the Recipes page → tap + → add ingredients and save.",
            ),
            _faqTile(
              "Can I edit my daily goals?",
              "Yes, you can update calorie, protein, fat goals in your Profile screen.",
            ),

            const SizedBox(height: 30),

            // CONTACT SUPPORT CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Need more help?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Our support team is here for you!",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  _contactOption(
                    icon: Icons.email_outlined,
                    title: "Email Support",
                    subtitle: "support@eatsmart.app",
                  ),
                  const SizedBox(height: 12),
                  _contactOption(
                    icon: Icons.chat_bubble_outline,
                    title: "Live Chat",
                    subtitle: "Available 9AM – 6PM",
                  ),
                  const SizedBox(height: 12),
                  _contactOption(
                    icon: Icons.phone_in_talk_outlined,
                    title: "Call Support",
                    subtitle: "+66 999 888 777",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Center(
              child: Text(
                "We're happy to help anytime 💛",
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- FAQ TILE ----
  Widget _faqTile(String question, String answer) {
    return ExpansionTile(
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        question,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      children: [
        Text(
          answer,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  // ---- CONTACT OPTION TILE ----
  Widget _contactOption({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F7F9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF137A85)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }
}
