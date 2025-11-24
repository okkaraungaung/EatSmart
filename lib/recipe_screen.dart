import 'package:eat_smart/user_session.dart';
import 'package:flutter/material.dart';
import 'recipe_detail_screen.dart';
import 'recipe_builder_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final String? userId = UserSession.userId;
  List<Map<String, dynamic>> savedRecipes = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshRecipes();
  }

  Future<void> _refreshRecipes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final url = "${AppConfig.baseUrl}/api/recipes/list?user_id=$userId";

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data["recipes"] ?? []) as List<dynamic>;

        savedRecipes = list.map<Map<String, dynamic>>((r) {
          final ingredients = (r["ingredients"] ?? []) as List<dynamic>;

          // compute total calories from ingredient items
          double totalCalories = 0;

          for (var item in ingredients) {
            final qty = item["quantity"] ?? 0; // grams
            final cal100 = item["calories"] ?? 0; // kcal per 100g
            totalCalories += (cal100 * qty / 100);
          }

          return {
            "id": r["id"],
            "name": r["name"],
            "description": r["description"] ?? "",
            "totalCalories": totalCalories,
            "created_at": r["created_at"],
            "ingredients": ingredients,
            "raw": r,
          };
        }).toList();
      } else {
        _error = "Failed to load recipes (${res.statusCode})";
      }
    } catch (e) {
      _error = "Error: $e";
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openBuilder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecipeBuilderScreen()),
    );
    await _refreshRecipes();

    // If builder returned a recipe object (and the server created it) refresh the list
    if (result != null && result is Map<String, dynamic>) {
      await _refreshRecipes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Recipe '${result['name']}' saved")),
      );
    }
  }

  Future<void> _openRecipeDetail(int index) async {
    final recipe = savedRecipes[index];

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
    );
    await _refreshRecipes();

    if (updated == null) return;

    if (updated == "delete") {
      setState(() => savedRecipes.removeAt(index));
      await _refreshRecipes();
      return;
    }

    if (updated is Map<String, dynamic>) {
      setState(() => savedRecipes[index] = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFB),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6EC6CA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: _openBuilder,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRecipes,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //TOP IMAGE
                    ClipRRect(
                      child: Image.network(
                        "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg",
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // TITLE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "My Recipes",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (savedRecipes.isEmpty && _error == null)
                      _emptyState()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: savedRecipes.length,
                        itemBuilder: (context, index) {
                          final r = savedRecipes[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
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
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              title: Text(
                                r["name"] ?? "Unnamed",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F7F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${(_d(r["totalCalories"])).toStringAsFixed(1)} kcal",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF337F8E),
                                  ),
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _openRecipeDetail(index),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  //BEAUTIFUL EMPTY UI
  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.menu_book, size: 90, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text(
              "No recipes created yet.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tap + to add your first recipe",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

double _d(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse(v?.toString() ?? "0") ?? 0.0;
