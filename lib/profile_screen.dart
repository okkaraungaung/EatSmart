import 'package:flutter/material.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController name = TextEditingController(text: "Okkar Aung");
  final TextEditingController email = TextEditingController(
    text: "okkar@example.com",
  );
  final TextEditingController birthDate = TextEditingController(
    text: "1998-05-14",
  );
  final TextEditingController weight = TextEditingController(text: "65");
  final TextEditingController height = TextEditingController(text: "170");

  String gender = "Male";
  String activity = "Moderate";

  // --- AUTO BMI (LOGIC UNCHANGED) ---
  double get bmi {
    double w = double.tryParse(weight.text) ?? 0;
    double h = (double.tryParse(height.text) ?? 0) / 100;
    if (w == 0 || h == 0) return 0;
    return w / pow(h, 2);
  }

  String get bmiStatus {
    double b = bmi;
    if (b < 18.5) return "Underweight";
    if (b < 25) return "Normal";
    if (b < 30) return "Overweight";
    return "Obese";
  }

  // --- DAILY CALORIE GOAL (LOGIC UNCHANGED) ---
  int get calorieGoal {
    double w = double.tryParse(weight.text) ?? 0;
    double h = double.tryParse(height.text) ?? 0;
    double age =
        2025 - (double.tryParse(birthDate.text.substring(0, 4)) ?? 2000);

    // Mifflin-St Jeor Formula
    double bmr;

    if (gender == "Male") {
      bmr = 10 * w + 6.25 * h - 5 * age + 5;
    } else {
      bmr = 10 * w + 6.25 * h - 5 * age - 161;
    }

    double multiplier = {
      "Sedentary": 1.2,
      "Light": 1.375,
      "Moderate": 1.55,
      "Active": 1.725,
    }[activity]!;

    return (bmr * multiplier).round();
  }

  Color get _accentColor => const Color(0xFF6EC6CA);

  @override
  Widget build(BuildContext context) {
    final double bmiValue = bmi;
    final String status = bmiStatus;
    final int calories = calorieGoal;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER CARD
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            _accentColor.withOpacity(0.9),
                            _accentColor.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.text,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email.text,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cake_rounded,
                                  size: 16,
                                  color: _accentColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  birthDate.text,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _accentColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // SECTION TITLE - PERSONAL INFO
              const Text(
                "Personal Information",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              _inputBox("Full Name", name),
              _inputBox("Email", email),
              _inputBox("Birth Date", birthDate),
              Row(
                children: [
                  Expanded(child: _inputBox("Weight (kg)", weight)),
                  const SizedBox(width: 10),
                  Expanded(child: _inputBox("Height (cm)", height)),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: _dropdownBox(
                      label: "Gender",
                      value: gender,
                      items: const ["Male", "Female"],
                      onChanged: (v) => setState(() => gender = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dropdownBox(
                      label: "Activity Level",
                      value: activity,
                      items: const ["Sedentary", "Light", "Moderate", "Active"],
                      onChanged: (v) => setState(() => activity = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // SECTION TITLE - HEALTH SUMMARY
              const Text(
                "Health Summary",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // HEALTH CARD (BMI CIRCLE + STATUS + CALORIES BAR)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // BMI CIRCLE
                        Column(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: (bmiValue / 40)
                                        .clamp(0.0, 1.0)
                                        .toDouble(),
                                    strokeWidth: 9,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation(
                                      _bmiColor(bmiValue),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        bmiValue.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        "BMI",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _bmiColor(bmiValue).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: _bmiColor(bmiValue),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _bmiColor(bmiValue),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 20),

                        // CALORIES + QUICK INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Recommended Calories",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "$calories kcal/day",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _accentColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: (calories / 3500)
                                      .clamp(0.0, 1.0)
                                      .toDouble(),
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation(
                                    _accentColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Based on your weight, height, age, gender\nand activity level.",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // SMALL LEGEND FOR BMI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _bmiLegendDot("Underweight", Colors.blue),
                        _bmiLegendDot("Normal", Colors.green),
                        _bmiLegendDot("Overweight", Colors.orange),
                        _bmiLegendDot("Obese", Colors.red),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile Updated")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Save Profile",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // --- BEAUTIFUL INPUT BOX (UI ONLY) ---
  Widget _inputBox(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // --- DROPDOWN BOX (UI ONLY) ---
  Widget _dropdownBox({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        initialValue: value,
        items: items
            .map(
              (e) => DropdownMenuItem<String>(
                value: e,
                child: Text(e, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  // --- BMI COLOR ---
  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  // --- SMALL LEGEND DOT ---
  Widget _bmiLegendDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
      ],
    );
  }
}
