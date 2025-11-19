import 'package:flutter/material.dart';

class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> food;
  final Function(Map<String, dynamic>)? onAddIngredient;

  const FoodDetailScreen({super.key, required this.food, this.onAddIngredient});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  double grams = 100;

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final nutrients = food["nutrients"] ?? {};

    double getValue(String key) {
      if (nutrients[key] == null) return 0;
      return nutrients[key].toDouble();
    }

    final kcal100 = getValue("ENERC_KCAL");
    final protein100 = getValue("PROCNT");
    final fat100 = getValue("FAT");
    final carbs100 = getValue("CHOCDF");

    double calc(double per100) => (per100 * grams) / 100;

    return Scaffold(
      appBar: AppBar(title: Text(food["label"] ?? "Food Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              food["label"] ?? "Unknown Food",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text(
              "Select Amount (grams)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            Slider(
              min: 0,
              max: 500,
              divisions: 500,
              value: grams,
              label: "${grams.toInt()} g",
              onChanged: (v) => setState(() => grams = v),
            ),

            Text(
              "${grams.toInt()} g selected",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            const Text(
              "Nutrition (for selected amount)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),
            _row("Calories", "${calc(kcal100).toStringAsFixed(1)} kcal"),
            _row("Protein", "${calc(protein100).toStringAsFixed(1)} g"),
            _row("Fat", "${calc(fat100).toStringAsFixed(1)} g"),
            _row("Carbs", "${calc(carbs100).toStringAsFixed(1)} g"),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Data to send back
                  final item = {
                    "label": food["label"],
                    "grams": grams,
                    "calories": calc(kcal100),
                    "protein": calc(protein100),
                    "fat": calc(fat100),
                    "carbs": calc(carbs100),
                  };

                  if (widget.onAddIngredient != null) {
                    widget.onAddIngredient!(item);

                    Navigator.pop(context); // back to search
                    Navigator.pop(context); // back to recipe builder
                  } else {
                    // Means user just searched normally
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Added ${grams.toInt()}g of ${food["label"]} to daily calories!",
                        ),
                      ),
                    );

                    Navigator.pop(context); // Only go back one page
                  }
                },

                child: Text(
                  widget.onAddIngredient != null
                      ? "Add Ingredient"
                      : "Add to Daily Calorie",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
