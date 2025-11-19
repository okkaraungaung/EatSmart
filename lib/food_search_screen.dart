import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'food_detail_screen.dart';

class FoodSearchScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onAddIngredient;

  const FoodSearchScreen({super.key, this.onAddIngredient});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final Duration _debounceDuration = const Duration(milliseconds: 600);
  Timer? _debounce;
  List<dynamic> _foods = [];
  bool _loading = false;
  String _lastQuery = '';

  Future<void> searchFood(String query) async {
    if (query.isEmpty || query == _lastQuery) return;

    if (query.length < 3) {
      setState(() => _foods = []);
      return;
    }

    setState(() {
      _loading = true;
      _lastQuery = query;
    });

    final url = "${AppConfig.baseUrl}/api/edamam?query=$query";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parsed = data["parsed"] ?? [];
        final hints = data["hints"] ?? [];
        setState(() {
          _foods = [...parsed, ...hints];
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final query = _controller.text.trim();
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(_debounceDuration, () => searchFood(query));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Food')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type food name (min. 3 letters)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_controller.text.isEmpty)
              const Expanded(
                child: Center(child: Text("Start typing to search...")),
              )
            else if (_controller.text.length < 3)
              const Expanded(
                child: Center(child: Text("Type at least 3 letters.")),
              )
            else if (_foods.isEmpty)
              const Expanded(child: Center(child: Text("No results found.")))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _foods.length,
                  itemBuilder: (context, index) {
                    final item = _foods[index];
                    final food = item["food"] ?? item;

                    final label = food["label"] ?? "Unknown Food";
                    final nutrients = food["nutrients"] ?? {};

                    final kcal = nutrients["ENERC_KCAL"]?.toString() ?? "N/A";

                    return Card(
                      child: ListTile(
                        title: Text(label),
                        subtitle: Text("Calories: $kcal per 100g"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FoodDetailScreen(
                                food: food,
                                onAddIngredient: widget.onAddIngredient,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
