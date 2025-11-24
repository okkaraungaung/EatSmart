import 'package:flutter/material.dart';
import 'food_search_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class RecipeBuilderScreen extends StatefulWidget {
  const RecipeBuilderScreen({super.key});

  @override
  State<RecipeBuilderScreen> createState() => _RecipeBuilderScreenState();
}

class _RecipeBuilderScreenState extends State<RecipeBuilderScreen> {
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Map<String, dynamic>> ingredients = [];
  bool _saving = false;

  void addIngredient(Map<String, dynamic> item) {
    setState(() {
      ingredients.add(item);
    });
  }

  // SAFE DOUBLE
  double _d(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  double get totalCalories =>
      ingredients.fold(0.0, (sum, i) => sum + _d(i["calories"]));
  double get totalProtein =>
      ingredients.fold(0.0, (sum, i) => sum + _d(i["protein"]));
  double get totalFat => ingredients.fold(0.0, (sum, i) => sum + _d(i["fat"]));
  double get totalCarbs =>
      ingredients.fold(0.0, (sum, i) => sum + _d(i["carbs"]));

  List<Map<String, dynamic>> _buildApiItems() {
    return ingredients.map((i) {
      return {
        "food_id": i["db_id"], // we will set db_id after saving
        "quantity": _d(i["grams"]),
      };
    }).toList();
  }

  Future<String?> saveFoodToDB(Map<String, dynamic> item) async {
    final url = "${AppConfig.baseUrl}/api/foods/save";

    final nutrients = item["nutrients"];

    // DB food → no nutrients map
    final calories = nutrients != null
        ? nutrients["ENERC_KCAL"]
        : item["calories"];
    final protein = nutrients != null ? nutrients["PROCNT"] : item["protein"];
    final fat = nutrients != null ? nutrients["FAT"] : item["fat"];
    final carbs = nutrients != null ? nutrients["CHOCDF"] : item["carbs"];

    final body = {
      "name": item["label"] ?? item["name"],
      "brand": "",
      "serving_size": 100,
      "calories": calories,
      "protein": protein,
      "fat": fat,
      "carbs": carbs,
      "edamam_id": item["id"],
      "created_by_user": 0,
    };

    final res = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body)["id"];
    }
    return null;
  }

  Future<void> _saveRecipe() async {
    if (_recipeNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter recipe name")));
      return;
    }

    // Convert all ingredients to database foods
    for (var i in ingredients) {
      if (i["db_id"] == null) {
        // Try save to DB
        final savedId = await saveFoodToDB(i);

        if (savedId == null) {
          setState(() => _saving = false);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Failed to save ingredient. Missing nutrients or edamam_id.",
              ),
            ),
          );

          return; // STOP — avoid null food_id
        }

        i["db_id"] = savedId; // SUCCESS
      }
    }

    final apiItems = _buildApiItems();

    if (apiItems.isEmpty) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("No savable items"),
          content: const Text(
            "Some ingredients are not saved in the DB. Only ingredients with a DB id will be stored. Continue saving?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Continue"),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    setState(() => _saving = true);

    final body = {
      "user_id": "user123",
      "name": _recipeNameController.text,
      "description": _descriptionController.text,
      "items": apiItems,
    };

    final url = "${AppConfig.baseUrl}/api/recipes/create";

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        if (mounted) {
          setState(() => _saving = false);
          Navigator.pop(context);
        }
      } else {
        final errBody = res.body;
        throw Exception("Failed to save (${res.statusCode}) $errBody");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Save failed: $e")));
      }
    }
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFB),

      appBar: AppBar(
        title: const Text(
          "Create Recipe",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6EC6CA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FoodSearchScreen(onAddIngredient: addIngredient),
            ),
          );
        },
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NAME & DESC
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                    "Recipe Name",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _recipeNameController,
                    decoration: InputDecoration(
                      hintText: "e.g. Chicken Rice Bowl",
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: "Short description (optional)",
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // INGREDIENTS CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                    "Ingredients",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ingredients.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "No ingredients added yet.",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ingredients.length,
                          itemBuilder: (context, index) {
                            final i = ingredients[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F7F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        i["label"],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "${_d(i["grams"]).toStringAsFixed(0)} g • ${_d(i["calories"]).toStringAsFixed(1)} kcal",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(
                                        () => ingredients.removeAt(index),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FoodSearchScreen(onAddIngredient: addIngredient),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Ingredient"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Totals and Save
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nutrition Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F7F9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Text(
                              totalCalories.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF137A85),
                              ),
                            ),
                            const Text(
                              "kcal",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          children: [
                            _nutriChip(
                              "Protein",
                              "${totalProtein.toStringAsFixed(1)}g",
                            ),
                            const SizedBox(height: 6),
                            _nutriChip(
                              "Carbs",
                              "${totalCarbs.toStringAsFixed(1)}g",
                            ),
                            const SizedBox(height: 6),
                            _nutriChip(
                              "Fat",
                              "${totalFat.toStringAsFixed(1)}g",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EC6CA),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Save Recipe",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CHIP WIDGET
Widget _nutriChip(String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF1FAFA),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    ),
  );
}
