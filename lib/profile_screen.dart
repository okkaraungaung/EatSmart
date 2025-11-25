import 'dart:convert';
import 'package:eat_smart/config.dart';
import 'package:eat_smart/user_session.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // BMI bar width used everywhere (bar + pointer math)
  static const double _bmiBarWidth = 350;

  final TextEditingController name = TextEditingController(text: "Okkar Aung");
  final TextEditingController email = TextEditingController(
    text: "okkar@example.com",
  );
  final TextEditingController birthDate = TextEditingController(
    text: "1998-05-14",
  );
  final TextEditingController weight = TextEditingController(text: "65");
  final TextEditingController height = TextEditingController(text: "170");

  final TextEditingController manualGoal = TextEditingController(text: "2000");
  bool useManualGoal = false;

  String gender = "Male";
  String activity = "Moderate";
  bool _loading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    userId = UserSession.userId;

    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    final url = "${AppConfig.baseUrl}/api/user/get?id=$userId";
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)["user"];

      setState(() {
        name.text = data["name"] ?? "";
        email.text = data["email"] ?? "";

        // Safe birthday handling
        final rawBirthday = data["birthday"];
        if (rawBirthday != null && rawBirthday.toString().trim().isNotEmpty) {
          try {
            final parts = rawBirthday.split('-');
            final parsed = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
            birthDate.text = DateFormat('yyyy-MM-dd').format(parsed);
          } catch (_) {
            birthDate.text = rawBirthday.toString().substring(0, 10);
          }
        }

        weight.text = data["weight"]?.toString() ?? "";
        height.text = data["height"]?.toString() ?? "";
        gender = data["gender"] ?? "Male";
        activity = data["activity"] ?? "Moderate";

        _loading = false;
      });
    }
  }

  // ---------- BMI ----------
  double get bmi {
    double w = double.tryParse(weight.text) ?? 0;
    double h = (double.tryParse(height.text) ?? 0) / 100;
    if (w == 0 || h == 0) return 0;
    return w / pow(h, 2);
  }

  String get bmiStatus {
    final b = bmi;
    if (b < 18.5) return "Underweight";
    if (b < 25) return "Normal";
    if (b < 30) return "Overweight";
    return "Obese";
  }

  // ---------- Correct Pointer Position ----------
  // Returns the X position (center) of the BMI value along the bar
  double _bmiPointerPosition(double bmi) {
    final double barWidth = _bmiBarWidth;

    // Segment widths based on flex: 18 + 25 + 30 + 27 = 100
    final double under = barWidth * 0.46; // 0 - 18.5
    final double normal = barWidth * 0.16; // 18.5 - 25
    final double over = barWidth * 0.12; // 25 - 30
    final double obese = barWidth * 0.25; // 30 - 40

    double x;

    if (bmi <= 0) {
      x = 0;
    } else if (bmi < 18.5) {
      // Map 0 - 18.5 -> 0 - under
      x = (bmi / 18.5) * under;
    } else if (bmi < 25) {
      // Map 18.5 - 25 -> under - under+normal
      x = under + ((bmi - 18.5) / (25 - 18.5)) * normal;
    } else if (bmi < 30) {
      // Map 25 - 30 -> under+normal - under+normal+over
      x = under + normal + ((bmi - 25) / (30 - 25)) * over;
    } else if (bmi < 40) {
      // Map 30 - 40 -> under+normal+over - end
      x = under + normal + over + ((bmi - 30) / (40 - 30)) * obese;
    } else {
      // Cap beyond 40 at the end of the bar
      x = barWidth;
    }

    // Clamp to bar width
    if (x < 0) x = 0;
    if (x > barWidth) x = barWidth;

    return x;
  }

  // ---------- Calorie Goal ----------
  int get calorieGoal {
    double w = double.tryParse(weight.text) ?? 0;
    double h = double.tryParse(height.text) ?? 0;

    int age = 25;
    final bd = birthDate.text.trim();
    if (bd.length >= 4) {
      final year = int.tryParse(bd.substring(0, 4));
      if (year != null) age = DateTime.now().year - year;
    }

    double bmr;
    if (gender == "Male") {
      bmr = 10 * w + 6.25 * h - 5 * age + 5;
    } else {
      bmr = 10 * w + 6.25 * h - 5 * age - 161;
    }

    double multiplier =
        {
          "Sedentary": 1.2,
          "Light": 1.375,
          "Moderate": 1.55,
          "Active": 1.725,
        }[activity] ??
        1.2;

    return (bmr * multiplier).round();
  }

  Color get _accentColor => const Color(0xFF4EC5C1);

  bool get isHealthInfoComplete {
    return weight.text.trim().isNotEmpty &&
        height.text.trim().isNotEmpty &&
        birthDate.text.trim().length >= 4;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final double bmiValue = bmi;
    final String status = bmiStatus;
    final int autoCalories = calorieGoal;

    const double barWidth = _bmiBarWidth;
    const double pointerSize = 22;

    // pointerX is the LEFT of the icon, so we shift by half size to center
    final double pointerX =
        (_bmiPointerPosition(bmiValue) - pointerSize / 2).clamp(
              0.0,
              barWidth - pointerSize,
            )
            as double;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.8,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // -------- PERSONAL INFO --------
            _sectionTitle("Personal Information"),
            _infoCard([
              _smallInput("Full Name", name),
              _smallInput("Email", email),
              _smallInput("Birth Date (YYYY-MM-DD)", birthDate),

              Row(
                children: [
                  Expanded(child: _smallInput("Weight (kg)", weight)),
                  const SizedBox(width: 10),
                  Expanded(child: _smallInput("Height (cm)", height)),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: _dropdownSmall(
                      label: "Gender",
                      value: gender,
                      items: const ["Male", "Female"],
                      onChanged: (v) => setState(() => gender = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dropdownSmall(
                      label: "Activity",
                      value: activity,
                      items: const ["Sedentary", "Light", "Moderate", "Active"],
                      onChanged: (v) => setState(() => activity = v!),
                    ),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 20),

            // -------- HEALTH SUMMARY --------
            _sectionTitle("Health Summary"),
            _infoCard([
              if (!isHealthInfoComplete)
                Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Fill in your Weight, Height, and Birth Date\nto see your BMI and calorie summary.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------- BMI TITLE --------
                    Text(
                      "BMI Status: $status",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _bmiColor(bmiValue),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // -------- BMI BAR (with pointer inside) --------
                    SizedBox(
                      width: barWidth,
                      height: 60, // enough space for bar + pointer + text
                      child: Stack(
                        children: [
                          // COLOR BAR
                          Positioned(
                            top: 20,
                            child: Container(
                              width: barWidth,
                              height: 18,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 46,
                                    child: Container(color: Colors.blue),
                                  ),
                                  Expanded(
                                    flex: 16,
                                    child: Container(color: Colors.green),
                                  ),
                                  Expanded(
                                    flex: 12,
                                    child: Container(color: Colors.orange),
                                  ),
                                  Expanded(
                                    flex: 25,
                                    child: Container(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // POINTER (triangle inside bar) + BMI value
                          Positioned(
                            left: pointerX,
                            top: 10,
                            child: Column(
                              children: [
                                // Triangle pointer (inside the bar)
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: pointerSize,
                                  color: Colors.black,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  bmiValue.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // LEGEND
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _bmiLegendDot("Underweight", Colors.blue),
                        _bmiLegendDot("Normal", Colors.green),
                        _bmiLegendDot("Overweight", Colors.orange),
                        _bmiLegendDot("Obese", Colors.red),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // CALORIES
                    Text(
                      "Recommended Calories",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$autoCalories kcal/day",
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
                        value: (autoCalories / 3500).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(_accentColor),
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
            ]),

            const SizedBox(height: 20),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (userId == null) return;

                  final url = "${AppConfig.baseUrl}/api/user/update";

                  final body = {
                    "id": userId,
                    "name": name.text,
                    "email": email.text,
                    "birthday": birthDate.text.trim(),
                    "weight": weight.text,
                    "height": height.text,
                    "gender": gender,
                    "activity": activity,
                    "daily_calorie_target": calorieGoal,
                  };

                  final res = await http.post(
                    Uri.parse(url),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(body),
                  );

                  if (res.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile Updated")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Update failed")),
                    );
                  }
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
                  "Save",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- UI HELPERS --------------------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .map(
              (w) =>
                  Padding(padding: const EdgeInsets.only(bottom: 10), child: w),
            )
            .toList(),
      ),
    );
  }

  Widget _smallInput(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          labelStyle: const TextStyle(fontSize: 12),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _dropdownSmall({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          labelStyle: const TextStyle(fontSize: 12),
        ),
        initialValue: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Widget _bmiLegendDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
