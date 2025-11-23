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

      setState(() {});
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
      backgroundColor: const Color(0xFFF6FBFB),

      appBar: AppBar(
        title: const Text(
          "Search Food",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //SEARCH BOX
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Search for food...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),

                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _foods = []);
                          },
                        )
                      : null,

                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //RESULTS UI
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_controller.text.isEmpty)
              Expanded(
                child: _emptyMessage(
                  icon: Icons.fastfood,
                  text: "Start typing to search food.",
                ),
              )
            else if (_controller.text.length < 3)
              Expanded(
                child: _emptyMessage(
                  icon: Icons.error_outline,
                  text: "Type at least 3 letters.",
                ),
              )
            else if (_foods.isEmpty)
              Expanded(
                child: _emptyMessage(
                  icon: Icons.search_off,
                  text: "No results found.",
                ),
              )
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

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.07),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),

                        title: Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),

                        subtitle: Text(
                          "Calories: $kcal / 100g",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 129, 129, 129),
                          ),
                        ),

                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.black54,
                        ),

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

  // BEAUTIFUL EMPTY STATES

  Widget _emptyMessage({required IconData icon, required String text}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 14),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
