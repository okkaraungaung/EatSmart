import 'package:flutter/material.dart';

class FoodDetailScreen extends StatelessWidget {
  final Map<String, dynamic> food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    final nutrients = food['foodNutrients'] ?? [];

    String getNutrient(String name) {
      final nutrient = nutrients.firstWhere(
        (n) => n['nutrientName'] == name,
        orElse: () => {'value': 'N/A', 'unitName': ''},
      );
      return '${nutrient['value']} ${nutrient['unitName'] ?? ''}';
    }

    return Scaffold(
      appBar: AppBar(title: Text(food['description'] ?? 'Food Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              food['description'] ?? 'Unknown Food',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Macronutrients (per 100g):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _nutrientRow('Calories', getNutrient('Energy')),
            _nutrientRow('Protein', getNutrient('Protein')),
            _nutrientRow('Fat', getNutrient('Total lipid (fat)')),
            _nutrientRow(
              'Carbohydrates',
              getNutrient('Carbohydrate, by difference'),
            ),
            _nutrientRow('Fiber', getNutrient('Fiber, total dietary')),
            _nutrientRow('Sugars', getNutrient('Sugars, total including NLEA')),
            const SizedBox(height: 24),
            const Text(
              'Nutrient Breakdown:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: nutrients.length,
                itemBuilder: (context, index) {
                  final n = nutrients[index];
                  return ListTile(
                    title: Text(n['nutrientName'] ?? 'Unknown'),
                    trailing: Text(
                      '${n['value'] ?? '-'} ${n['unitName'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
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

  Widget _nutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
