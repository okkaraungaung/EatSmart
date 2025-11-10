import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final String date;

  const HistoryScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final foods = [
      {"name": "Banana", "calories": 105},
      {"name": "Chicken breast", "calories": 165},
      {"name": "Rice", "calories": 200},
    ];

    return Scaffold(
      appBar: AppBar(title: Text("History: $date")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Foods eaten on $date",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final food = foods[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(food['name'].toString()),
                      trailing: Text("${food['calories']} kcal"),
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
