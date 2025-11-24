import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalSettingsScreen extends StatefulWidget {
  const GoalSettingsScreen({super.key});

  @override
  State<GoalSettingsScreen> createState() => _GoalSettingsScreenState();
}

class _GoalSettingsScreenState extends State<GoalSettingsScreen> {
  final TextEditingController calController = TextEditingController();
  final TextEditingController proController = TextEditingController();
  final TextEditingController fatController = TextEditingController();
  final TextEditingController carbController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  Future<void> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();

    calController.text = prefs.getInt("dailyGoal")?.toString() ?? "2000";
    proController.text = prefs.getInt("proteinGoal")?.toString() ?? "150";
    fatController.text = prefs.getInt("fatGoal")?.toString() ?? "60";
    carbController.text = prefs.getInt("carbGoal")?.toString() ?? "60";
  }

  Future<void> saveGoals() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("dailyGoal", int.tryParse(calController.text) ?? 2000);
    await prefs.setInt("proteinGoal", int.tryParse(proController.text) ?? 150);
    await prefs.setInt("fatGoal", int.tryParse(fatController.text) ?? 60);
    await prefs.setInt("carbGoal", int.tryParse(carbController.text) ?? 60);

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Goals updated")));
  }

  Widget _inputBox(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(
        title: const Text(
          "Set Nutrition Goals",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.6,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _inputBox("Daily Calories Goal (kcal)", calController),
            _inputBox("Daily Protein Goal (g)", proController),
            _inputBox("Daily Fat Goal (g)", fatController),
            _inputBox("Daily Carb Goal (g)", carbController),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFc8f0ef),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: saveGoals,
                child: const Text(
                  "Save Goals",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
