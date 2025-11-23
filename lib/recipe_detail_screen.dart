import 'package:flutter/material.dart';
import 'food_search_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Map<String, dynamic> recipe;
  late TextEditingController _name;

  List<Map<String, dynamic>> get ingredients =>
      (recipe["ingredients"] as List).cast<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();
    recipe = Map<String, dynamic>.from(widget.recipe);
    _name = TextEditingController(text: recipe["name"]);
  }

  // Helpers
  double _d(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;

  double get totalCalories =>
      ingredients.fold(0.0, (sum, i) => sum + _d(i["calories"]));
  double get totalProtein =>
      ingredients.fold(0.0, (sum, i) => sum + _d(i["protein"]));
  double get totalFat => ingredients.fold(0.0, (sum, i) => sum + _d(i["fat"]));
  double get totalCarbs =>
      ingredients.fold(0.0, (sum, i) => sum + _d(i["carbs"]));

  // ADD INGREDIENT (FIXED)
  Future<void> _addIngredient() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodSearchScreen(
          onAddIngredient: (item) {
            Navigator.pop(context, item); // return ingredient
          },
        ),
      ),
    );

    if (selected != null) {
      setState(() => ingredients.add(selected));
    }
  }

  // EDIT ingredient (slider version)
  Future<void> _editIngredient(int index) async {
    final i = ingredients[index];

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
      ingredients[index] = {
        ...i,
        "grams": newGrams,
        "calories": oldCalories * factor,
        "protein": oldProtein * factor,
        "fat": oldFat * factor,
        "carbs": oldCarbs * factor,
      };
    });
  }

  void _deleteIngredient(int index) =>
      setState(() => ingredients.removeAt(index));
  void _deleteRecipe() => Navigator.pop(context, "delete");

  void _save() {
    recipe["name"] = _name.text;
    recipe["ingredients"] = ingredients;
    recipe["totalCalories"] = totalCalories;
    recipe["totalProtein"] = totalProtein;
    recipe["totalFat"] = totalFat;
    recipe["totalCarbs"] = totalCarbs;

    Navigator.pop(context, recipe);
  }

  // Nutrition Ring Widget
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NAME CARD
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                      borderRadius: BorderRadius.circular(30),
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

                  if (ingredients.isEmpty)
                    const Text("No ingredients added.")
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ingredients.length,
                      itemBuilder: (context, i) {
                        final item = ingredients[i];
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
                onPressed: _save,
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
      ),
    );
  }
}
