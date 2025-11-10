import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'food_detail_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  runApp(const FoodSearchApp());
}

class FoodSearchApp extends StatelessWidget {
  const FoodSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const FoodSearchScreen(),
    );
  }
}

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final _debounceDuration = const Duration(milliseconds: 500);

  Timer? _debounce;
  List<dynamic> _foods = [];
  bool _loading = false;

  Future<void> searchFood(String query) async {
    if (query.isEmpty) {
      setState(() => _foods = []);
      return;
    }

    final apiKey = dotenv.env['USDA_API_KEY'];
    final url =
        'https://api.nal.usda.gov/fdc/v1/foods/search?query=$query&api_key=$apiKey';

    setState(() => _loading = true);

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('Request URL: $url');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _foods = data['foods'] ?? [];
        });
        debugPrint('Found ${_foods.length} foods');
      } else {
        debugPrint('Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }

    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();

    if (!dotenv.isInitialized) {
      dotenv.load(fileName: "assets/.env").then((_) {
        debugPrint("dotenv reloaded successfully");
      });
    }

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
      appBar: AppBar(title: const Text('Search Food (USDA API)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type to search (e.g. chicken, apple...)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_foods.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Start typing to search for foods...',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _foods.length,
                  itemBuilder: (context, index) {
                    final food = _foods[index];
                    final nutrients = food['foodNutrients'] ?? [];
                    final calories =
                        nutrients
                            .firstWhere(
                              (n) => n['nutrientName'] == 'Energy',
                              orElse: () => {'value': 0},
                            )['value']
                            ?.toString() ??
                        'N/A';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(food['description'] ?? 'Unknown Food'),
                        subtitle: Text('Calories: $calories kcal'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FoodDetailScreen(food: food),
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
