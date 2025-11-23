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
  late TextEditingController gramController;

  @override
  void initState() {
    super.initState();
    gramController = TextEditingController(text: grams.toInt().toString());
  }

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
      backgroundColor: const Color(0xFFF7FAFA),
      appBar: AppBar(
        title: Text(food["label"] ?? "Food Details"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //HEADER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food["label"] ?? "Unknown Food",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Enter Amount (grams)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  //Manual Input Box
                  Row(
                    children: [
                      SizedBox(
                        width: 90, // smaller box
                        child: TextField(
                          controller: gramController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "100",
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ), // smaller height
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (v) {
                            final g = double.tryParse(v) ?? grams;
                            setState(() {
                              grams = g.clamp(0, 500);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "g",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  //Slider
                  Slider(
                    min: 0,
                    max: 500,
                    value: grams,
                    divisions: 500,
                    label: "${grams.toInt()} g",
                    onChanged: (v) {
                      setState(() {
                        grams = v;
                        gramController.text = v.toInt().toString();
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // NUTRITION CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF6BA),
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nutrition Summary",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),

                  _nutrientRow(
                    "Calories",
                    "${calc(kcal100).toStringAsFixed(1)} kcal",
                  ),
                  _nutrientRow(
                    "Protein",
                    "${calc(protein100).toStringAsFixed(1)} g",
                  ),
                  _nutrientRow("Fat", "${calc(fat100).toStringAsFixed(1)} g"),
                  _nutrientRow(
                    "Carbs",
                    "${calc(carbs100).toStringAsFixed(1)} g",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            //ADD BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFFc8f0ef),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
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
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  widget.onAddIngredient != null
                      ? "Add Ingredient"
                      : "Add to Daily Calories",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutrientRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
