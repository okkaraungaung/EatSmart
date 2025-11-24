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
        final rawBirthday = data["birthday"];
        if (rawBirthday != null && rawBirthday.toString().trim().isNotEmpty) {
          try {
            try {
              final parts = rawBirthday.split('-');
              final parsed = DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              ); // local, no UTC shift

              birthDate.text = DateFormat('yyyy-MM-dd').format(parsed);
            } catch (e) {
              birthDate.text = rawBirthday.toString().substring(0, 10);
            }
          } catch (e) {
            // fallback if parsing fails
            birthDate.text = rawBirthday.toString().substring(0, 10);
          }
        }
        weight.text = (data["weight"]?.toString() ?? "");
        height.text = (data["height"]?.toString() ?? "");
        gender = data["gender"] ?? "Male";
        activity = data["activity"] ?? "Moderate";
        _loading = false;
      });
    }
  }

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

    // --- SAFE AGE CALCULATION ---
    int age = 25; // fallback
    final bd = birthDate.text.trim();

    if (bd.length >= 4) {
      final year = int.tryParse(bd.substring(0, 4));
      if (year != null) {
        age = DateTime.now().year - year;
      }
    }

    // --- BMR ---
    double bmr;
    if (gender == "Male") {
      bmr = 10 * w + 6.25 * h - 5 * age + 5;
    } else {
      bmr = 10 * w + 6.25 * h - 5 * age - 161;
    }

    // --- ACTIVITY MULTIPLIER ---
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

  Color get _accentColor => const Color(0xFF6EC6CA);

  bool get isHealthInfoComplete {
    return weight.text.trim().isNotEmpty &&
        height.text.trim().isNotEmpty &&
        birthDate.text.trim().length >= 4;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
              _datePickerBox("Birth Date", birthDate),

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
                child:
                    (weight.text.trim().isEmpty ||
                        height.text.trim().isEmpty ||
                        birthDate.text.trim().length < 4)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
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
                        ),
                      )
                    : Column(
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
                                      color: _bmiColor(
                                        bmiValue,
                                      ).withOpacity(0.1),
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
                  onPressed: () async {
                    if (userId == null) return;

                    final url = "${AppConfig.baseUrl}/api/user/update";
                    final cleanBirthDate = birthDate.text.trim();

                    final body = {
                      "id": userId,
                      "name": name.text,
                      "email": email.text,
                      "birthday": cleanBirthDate,
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

  Widget _datePickerBox(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () async {
        // ---- FIX: safe local date parsing (no timezone magic) ----
        DateTime initialDate;
        final text = controller.text.trim();

        if (text.isNotEmpty) {
          try {
            final parts = text.split('-'); // "yyyy-MM-dd"
            initialDate = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            ); // local date, no shift
          } catch (_) {
            initialDate = DateTime(2000, 1, 1);
          }
        } else {
          initialDate = DateTime(2000, 1, 1);
        }

        DateTime? selected = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (selected != null) {
          // Rebuild as pure date to avoid any timezone noise
          final picked = DateTime(selected.year, selected.month, selected.day);
          controller.text = DateFormat('yyyy-MM-dd').format(picked);
          setState(() {});
        }
      },
      child: AbsorbPointer(
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
              labelStyle: const TextStyle(fontSize: 13, color: Colors.black54),
              suffixIcon: const Icon(Icons.calendar_month, color: Colors.grey),
            ),
          ),
        ),
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
