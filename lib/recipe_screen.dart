import 'package:flutter/material.dart';
import 'recipe_builder_screen.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  List<Map<String, dynamic>> savedRecipes = [];

  Future<void> _openBuilder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecipeBuilderScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        savedRecipes.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Recipes")),
      floatingActionButton: FloatingActionButton(
        onPressed: _openBuilder,
        child: const Icon(Icons.add),
      ),
      body: savedRecipes.isEmpty
          ? const Center(
              child: Text(
                "No recipes created yet.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: savedRecipes.length,
              itemBuilder: (context, index) {
                final r = savedRecipes[index];
                final total = (r["totalCalories"] ?? 0.0) as double;

                return Card(
                  child: ListTile(
                    title: Text(r["name"] ?? "Untitled Recipe"),
                    subtitle: Text("${total.toStringAsFixed(1)} kcal"),
                  ),
                );
              },
            ),
    );
  }
}
