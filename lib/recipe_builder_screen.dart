import 'package:flutter/material.dart';
import 'food_search_screen.dart';

class RecipeBuilderScreen extends StatefulWidget {
  const RecipeBuilderScreen({super.key});

  @override
  State<RecipeBuilderScreen> createState() => _RecipeBuilderScreenState();
}

class _RecipeBuilderScreenState extends State<RecipeBuilderScreen> {
  final TextEditingController _recipeNameController = TextEditingController();

  List<Map<String, dynamic>> ingredients = [];

  void addIngredient(Map<String, dynamic> item) {
    setState(() {
      ingredients.add(item);
    });
  }

  double get totalCalories =>
      ingredients.fold(0, (sum, i) => sum + (i["calories"] ?? 0));

  double get totalProtein =>
      ingredients.fold(0, (sum, i) => sum + (i["protein"] ?? 0));

  double get totalFat => ingredients.fold(0, (sum, i) => sum + (i["fat"] ?? 0));

  double get totalCarbs =>
      ingredients.fold(0, (sum, i) => sum + (i["carbs"] ?? 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Recipe")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FoodSearchScreen(onAddIngredient: addIngredient),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recipe Name:", style: TextStyle(fontSize: 16)),
            TextField(
              controller: _recipeNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "e.g. Chicken Rice Bowl",
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Ingredients:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ingredients.isEmpty
                  ? const Center(child: Text("No ingredients added yet."))
                  : ListView.builder(
                      itemCount: ingredients.length,
                      itemBuilder: (context, index) {
                        final i = ingredients[index];
                        return Card(
                          child: ListTile(
                            title: Text(i["label"]),
                            subtitle: Text(
                              "${i["grams"]} g • ${i["calories"].toStringAsFixed(1)} kcal",
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() => ingredients.removeAt(index));
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),

            Text(
              "Total: ${totalCalories.toStringAsFixed(1)} kcal "
              "(P: ${totalProtein.toStringAsFixed(1)}g  "
              "F: ${totalFat.toStringAsFixed(1)}g  "
              "C: ${totalCarbs.toStringAsFixed(1)}g)",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (_recipeNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter recipe name")),
                  );
                  return;
                }

                final recipe = {
                  "name": _recipeNameController.text,
                  "ingredients": ingredients,
                  "totalCalories": totalCalories,
                  "totalProtein": totalProtein,
                  "totalFat": totalFat,
                  "totalCarbs": totalCarbs,
                };

                Navigator.pop(context, recipe);
              },
              child: const Text("Save Recipe"),
            ),
          ],
        ),
      ),
    );
  }
}
