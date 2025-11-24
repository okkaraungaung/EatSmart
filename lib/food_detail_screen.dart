import 'dart:convert';
import 'package:eat_smart/user_session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> food;
  final Function(Map<String, dynamic>)? onAddIngredient;

  const FoodDetailScreen({super.key, required this.food, this.onAddIngredient});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  double grams = 100;
  late TextEditingController gramController;

  @override
  void initState() {
    super.initState();
    gramController = TextEditingController(text: grams.toInt().toString());
  }

  String? userId = UserSession.userId;

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final nutrients = food["nutrients"] ?? {};

    double getValue(String key) {
      if (nutrients[key] == null) return 0;
      return nutrients[key].toDouble();
    }

    final kcal100 = getValue("ENERC_KCAL");
    final protein100 = getValue("PROCNT");
    final fat100 = getValue("FAT");
    final carbs100 = getValue("CHOCDF");

    double calc(double per100) => (per100 * grams) / 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFA),
      appBar: AppBar(
        title: Text(food["label"] ?? "Food Details"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //HEADER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food["label"] ?? "Unknown Food",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Enter Amount (grams)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  //Manual Input Box
                  Row(
                    children: [
                      SizedBox(
                        width: 90, // smaller box
                        child: TextField(
                          controller: gramController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "100",
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ), // smaller height
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (v) {
                            final g = double.tryParse(v) ?? grams;
                            setState(() {
                              grams = g.clamp(1, 500);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "g",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  //Slider
                  Slider(
                    min: 1,
                    max: 500,
                    value: grams,
                    divisions: 500,
                    label: "${grams.toInt()} g",
                    onChanged: (v) {
                      setState(() {
                        grams = v;
                        gramController.text = v.toInt().toString();
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // NUTRITION CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF6BA),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nutrition Summary",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  _nutrientRow(
                    "Calories",
                    "${calc(kcal100).toStringAsFixed(1)} kcal",
                  ),
                  _nutrientRow(
                    "Protein",
                    "${calc(protein100).toStringAsFixed(1)} g",
                  ),
                  _nutrientRow("Fat", "${calc(fat100).toStringAsFixed(1)} g"),
                  _nutrientRow(
                    "Carbs",
                    "${calc(carbs100).toStringAsFixed(1)} g",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            //ADD BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFFc8f0ef),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  if (widget.onAddIngredient != null) {
                    _addIngredientToRecipe();
                  } else {
                    _addToDailyCalories();
                  }
                },
                child: Text(
                  widget.onAddIngredient != null
                      ? "Add Ingredient"
                      : "Add to Daily Calories",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🌟 Add Ingredient → back to Recipe Builder
  void _addIngredientToRecipe() {
    final food = widget.food;

    final ingredient = {
      "id": food["id"] ?? food["edamam_id"], // DB or Edamam
      "label": food["label"],
      "grams": grams,
      "calories": calcNutrient("ENERC_KCAL"),
      "protein": calcNutrient("PROCNT"),
      "fat": calcNutrient("FAT"),
      "carbs": calcNutrient("CHOCDF"),
    };

    widget.onAddIngredient!(ingredient);

    Navigator.pop(context); // back to search
    Navigator.pop(context); // back to recipe builder
  }

  // 🌟 Add to Daily Calorie → POST /api/meal/log
  Future<void> _addToDailyCalories() async {
    final food = widget.food;

    String? foodId = food["id"]; // If DB result, will exist

    // If foodId is null → this is Edamam food → need to save first
    if (foodId == null) {
      final saveUrl = "${AppConfig.baseUrl}/api/foods/save";

      final saveBody = {
        "edamam_id": food["edamam_id"] ?? food["foodId"],
        "name": food["label"],
        "brand": food["brand"],
        "calories": food["nutrients"]?["ENERC_KCAL"] ?? 0,
        "protein": food["nutrients"]?["PROCNT"] ?? 0,
        "fat": food["nutrients"]?["FAT"] ?? 0,
        "carbs": food["nutrients"]?["CHOCDF"] ?? 0,
      };

      try {
        final saveRes = await http.post(
          Uri.parse(saveUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(saveBody),
        );

        final saveData = jsonDecode(saveRes.body);

        if (saveRes.statusCode == 200 && saveData["id"] != null) {
          foodId = saveData["id"]; // now stored in DB 🎉
        } else {
          throw Exception("Failed to save food to DB");
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving food: $e")));
        return;
      }
    }

    // 🔹 Now log food because it has a DB id
    final today = DateTime.now();
    final date =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final logUrl = "${AppConfig.baseUrl}/api/meal/log";

    final logBody = {
      "user_id": userId,
      "food_id": foodId,
      "grams": grams,
      "date": date,
    };

    try {
      final logRes = await http.post(
        Uri.parse(logUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(logBody),
      );

      if (logRes.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Added ${grams.toInt()}g of ${food["label"]}!"),
          ),
        );
        Navigator.pop(context); // pop FoodDetail
      } else {
        throw Exception("Failed: ${logRes.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error logging meal: $e")));
    }
  }

  // Small helper to compute nutrients
  double calcNutrient(String key) {
    final per100 = widget.food["nutrients"]?[key] ?? 0;
    return (per100 * grams) / 100;
  }

  Widget _nutrientRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
