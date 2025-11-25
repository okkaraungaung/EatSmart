import 'package:eat_smart/user_session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  late DateTime selectedDate;
  late List<DateTime> weekDays;

  bool loading = false;
  List foods = [];
  double totalCalories = 0;
  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    weekDays = _generateWeek(selectedDate);
    _fetchFoodsForDate();
  }

  void refresh() {
    _fetchFoodsForDate();
  }

  List<DateTime> _generateWeek(DateTime baseDate) {
    int weekday = baseDate.weekday;
    int daysFromSunday = weekday % 7;
    DateTime sunday = baseDate.subtract(Duration(days: daysFromSunday));
    return List.generate(7, (i) => sunday.add(Duration(days: i)));
  }

  Future<void> _openDatePicker() async {
    final picked = await showDatePicker(
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
      _fetchFoodsForDate();
    }
  }

  //  FETCH FOODS FOR SELECTED DATE
  Future<void> _fetchFoodsForDate() async {
    setState(() => loading = true);

    final formatted = DateFormat("yyyy-MM-dd").format(selectedDate);

    final url =
        "${AppConfig.baseUrl}/api/meal/by-date?date=$formatted&user_id=${UserSession.userId}";

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          foods = data["foods"] ?? [];
          totalCalories = (data["totalCalories"] ?? 0).toDouble();
        });
      }
    } catch (e) {
      debugPrint("HISTORY API ERROR: $e");
    }

    setState(() => loading = false);
  }

  // ⭐ DELETE MEAL
  Future<void> _deleteMeal(String mealId) async {
    final url = "${AppConfig.baseUrl}/api/meal/delete?id=$mealId";

    try {
      final res = await http.delete(Uri.parse(url));

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Deleted successfully")));
        _fetchFoodsForDate();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Delete failed: ${res.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void didChangeDependencies() {
    print("HistoryScreen didChangeDependencies");
    super.didChangeDependencies();
    if (_firstLoad) {
      _firstLoad = false;
    } else {
      _fetchFoodsForDate(); // refresh when returning to screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "Calories History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TOP CALENDAR CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF9D0),
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
                  // Top Row (Today + Calendar Button)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat("MMMM dd, yyyy").format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: _openDatePicker,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.calendar_today, size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // WEEK VIEW
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
                            setState(() => selectedDate = day);
                            _fetchFoodsForDate();
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 45,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.shade100
                                      : Colors.white,
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

            // ⭐ FOODS LIST WITH DELETE BUTTON
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: foods.length,
                      itemBuilder: (context, index) {
                        final food = foods[index];

                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFc8f0ef),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),

                          child: Row(
                            children: [
                              // name
                              Expanded(
                                child: Text(
                                  food["name"].toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),

                              // calories
                              Text(
                                "${food['calories']} kcal",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),

                              const SizedBox(width: 12),

                              // ⭐ DELETE BUTTON
                              GestureDetector(
                                onTap: () => _deleteMeal(food["id"].toString()),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 26,
                                ),
                              ),
                            ],
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
