import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final String date;

  const HistoryScreen({super.key, required this.date});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime selectedDate;
  late List<DateTime> weekDays;

  @override
  void initState() {
    super.initState();

    selectedDate = DateFormat("yyyy-MM-dd").parse(widget.date);
    weekDays = _generateWeek(selectedDate);
  }

  List<DateTime> _generateWeek(DateTime baseDate) {
    final int weekday = baseDate.weekday; // 1 = Monday
    final DateTime monday = baseDate.subtract(Duration(days: weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  Future<void> _openDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        weekDays = _generateWeek(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final foods = [
      {"name": "Banana", "calories": 105},
      {"name": "Chicken breast", "calories": 165},
      {"name": "Rice", "calories": 200},
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("History"),
        backgroundColor: Colors.white, //95d4e4
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -----------------------------------------------------------
            // 📦 WHITE BOX FOR CALENDAR SECTION
            // -----------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Color(0xFF95d4e4),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Calendar icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _openDatePicker,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.calendar_today, size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Week calendar display
                  SizedBox(
                    height: 90,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weekDays.map((day) {
                        bool isSelected =
                            day.day == selectedDate.day &&
                            day.month == selectedDate.month &&
                            day.year == selectedDate.year;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = day;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 45,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat("E").format(day)[0],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.blue.shade700
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    CircleAvatar(
                                      radius: 4,
                                      backgroundColor: isSelected
                                          ? Colors.blue.shade700
                                          : Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${day.day}",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.blue.shade700
                                      : Colors.grey.shade700,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Foods list title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Foods eaten on ${DateFormat("MMM dd").format(selectedDate)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Foods List
            Expanded(
              child: ListView.builder(
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final food = foods[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
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
