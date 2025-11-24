import 'package:flutter/material.dart';
import 'food_search_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Map<String, dynamic> recipe;
  late TextEditingController _name;
  bool _loading = true;
  List<Map<String, dynamic>> _ingredients = [];

  @override
  void initState() {
    super.initState();
    recipe = Map<String, dynamic>.from(widget.recipe);
    _name = TextEditingController(text: recipe["name"]);
    _loadRecipeDetails();
  }

  // Helpers
  double _d(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;

  double get totalCalories =>
      _ingredients.fold(0.0, (sum, i) => sum + _d(i["calories"]));
  double get totalProtein =>
      _ingredients.fold(0.0, (sum, i) => sum + _d(i["protein"]));
  double get totalFat => _ingredients.fold(0.0, (sum, i) => sum + _d(i["fat"]));
  double get totalCarbs =>
      _ingredients.fold(0.0, (sum, i) => sum + _d(i["carbs"]));

  Future<void> _loadRecipeDetails() async {
    final url = "${AppConfig.baseUrl}/api/recipes/detail?id=${recipe["id"]}";
    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        _ingredients =
            (data["items"] as List?)?.map((i) {
              final grams = _d(i["grams"]);
              final calPer100 = _d(i["calories"]);
              final proteinPer100 = _d(i["protein"]);
              final fatPer100 = _d(i["fat"]);
              final carbsPer100 = _d(i["carbs"]);

              final factor = grams / 100.0;

              return {
                "label": i["label"],
                "grams": grams,
                "calories": calPer100 * factor,
                "protein": proteinPer100 * factor,
                "fat": fatPer100 * factor,
                "carbs": carbsPer100 * factor,
                "db_id": i["food_id"],
              };
            }).toList() ??
            [];
      }
    } catch (e) {
      debugPrint("DETAIL ERROR: $e");
    }

    setState(() => _loading = false);
  }

  // SAVE FOOD TO DB (for edamam ingredients)
  Future<String?> _saveFoodToDB(Map<String, dynamic> item) async {
    final url = "${AppConfig.baseUrl}/api/foods/save";

    final nutrients = item["nutrients"];

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
      "edamam_id": item["edamam_id"],
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

  // ADD INGREDIENT
  Future<void> _addIngredient() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodSearchScreen(
          autoPop: false,
          onAddIngredient: (item) async {
            if (item["db_id"] == null) {
              final savedId = await _saveFoodToDB(item);
              if (savedId != null) item["db_id"] = savedId;
            } else if (item["id"] != null) {
              item["db_id"] = item["id"];
            }
            setState(() => _ingredients.add(item));
          },
        ),
      ),
    );
  }

  // DELETE INGREDIENT
  void _deleteIngredient(int index) =>
      setState(() => _ingredients.removeAt(index));

  // DELETE RECIPE FROM DB
  Future<void> _deleteRecipe() async {
    final url = "${AppConfig.baseUrl}/api/recipes/delete?id=${recipe["id"]}";

    await http.delete(Uri.parse(url));

    Navigator.pop(context, "delete");
  }

  // SAVE RECIPE CHANGES TO DB
  Future<void> _saveRecipeToDB() async {
    // Convert _ingredients → API format
    final List<Map<String, dynamic>> items = [];

    for (var i in _ingredients) {
      // Already saved DB food
      if (i["db_id"] != null) {
        items.add({"food_id": i["db_id"], "quantity": _d(i["grams"])});
        continue;
      }

      // If the food has an existing DB id (from detail API)
      if (i["id"] != null) {
        i["db_id"] = i["id"];
        items.add({"food_id": i["db_id"], "quantity": _d(i["grams"])});
        continue;
      }

      // If Edamam food → must save first
      final savedId = await _saveFoodToDB(i);

      if (savedId != null) {
        i["db_id"] = savedId;
        items.add({"food_id": savedId, "quantity": _d(i["grams"])});
        continue;
      }
    }

    final body = {
      "recipe_id": recipe["id"],
      "name": _name.text,
      "description": recipe["description"] ?? "",
      "items": items,
    };

    final url = "${AppConfig.baseUrl}/api/recipes/update";

    await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    // Update UI & return updated recipe
    recipe["name"] = _name.text;
    recipe["ingredients"] = _ingredients;
    recipe["totalCalories"] = totalCalories;

    Navigator.pop(context, recipe);
  }

  // EDIT INGREDIENT
  Future<void> _editIngredient(int index) async {
    final i = _ingredients[index];

    final double oldGrams = _d(i["grams"]);
    final double oldCalories = _d(i["calories"]);
    final double oldProtein = _d(i["protein"]);
    final double oldFat = _d(i["fat"]);
    final double oldCarbs = _d(i["carbs"]);

    double grams = oldGrams;

    final newGrams = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModal) {
              double preview = oldCalories * (grams / oldGrams);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(i["label"], style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),

                  Slider(
                    min: 0,
                    max: 500,
                    value: grams,
                    divisions: 500,
                    label: "${grams.toInt()} g",
                    onChanged: (v) => setModal(() => grams = v),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${grams.toInt()} g"),
                      Text("${preview.toStringAsFixed(1)} kcal"),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, grams),
                      child: const Text("Apply"),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (newGrams == null) return;

    final factor = newGrams / oldGrams;

    setState(() {
      _ingredients[index] = {
        ...i,
        "grams": newGrams,
        "calories": oldCalories * factor,
        "protein": oldProtein * factor,
        "fat": oldFat * factor,
        "carbs": oldCarbs * factor,
      };
    });
  }

  Widget _ring({
    required String label,
    required double value,
    required double max,
    required Color color,
  }) {
    double progress = (value / max).clamp(0, 1);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: const Color(0xFFF9FAFA),
                color: color,
              ),
            ),
            Text(
              value.toStringAsFixed(0),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFB),
      appBar: AppBar(
        title: const Text("Recipe Details"),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteRecipe,
          ),
        ],
      ),
      body: _buildUI(theme),
    );
  }

  Widget _buildUI(TextTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NAME CARD
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _name,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  labelText: "Recipe Name",
                  labelStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // NUTRITION RINGS CARD
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nutrition Summary",
                  style: theme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ring(
                      label: "Calories",
                      value: totalCalories,
                      max: 2000,
                      color: const Color(0xFFF5B766),
                    ),
                    _ring(
                      label: "Protein",
                      value: totalProtein,
                      max: 150,
                      color: const Color(0xFF7599E6),
                    ),
                    _ring(
                      label: "Carbs",
                      value: totalCarbs,
                      max: 300,
                      color: Colors.red,
                    ),
                    _ring(
                      label: "Fat",
                      value: totalFat,
                      max: 100,
                      color: const Color(0xFF99D47C),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // INGREDIENTS CARD (MATCH RECIPE BUILDER UI)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFc8f0ef),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ingredients",
                  style: theme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (_ingredients.isEmpty)
                  const Text("No ingredients added.")
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ingredients.length,
                    itemBuilder: (context, i) {
                      final item = _ingredients[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          title: Text(item["label"]),
                          subtitle: Text(
                            "${_d(item["grams"])} g • ${_d(item["calories"])} kcal",
                          ),
                          onTap: () => _editIngredient(i),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteIngredient(i),
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Ingredient"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SAVE BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveRecipeToDB,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6EC6CA),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Save Changes",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
