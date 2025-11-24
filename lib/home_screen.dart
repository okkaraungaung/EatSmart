import 'package:eat_smart/user_session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config.dart';
import 'food_search_screen.dart';
import 'history_screen.dart';
import 'more_screen.dart';
import 'profile_screen.dart';
import 'recipe_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String? userId = UserSession.userId;

  double todayCalories = 0;
  double todayProtein = 0;
  double todayFat = 0;
  double todayCarbs = 0;

  int dailyGoal = 2000;
  int proteinGoal = 200;
  int fatGoal = 100;

  int _selectedIndex = 0;
  bool isLoading = true;

  List<Map<String, dynamic>> weeklyHistory = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await fetchTodayStats();
    await fetchWeeklyHistory();

    setState(() {
      isLoading = false; // <- now UI can show real data
    });
  }

  // ---------------- FETCH TODAY SUMMARY ----------------

  Future<void> fetchTodayStats() async {
    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final url =
        "${AppConfig.baseUrl}/api/meal/today?user_id=$userId&date=$today";

    try {
      final res = await http.get(Uri.parse(url));
      final data = jsonDecode(res.body);

      setState(() {
        todayCalories = double.parse(
          ((data["calories"] ?? 0).toDouble()).toStringAsFixed(1),
        );

        todayProtein = double.parse(
          ((data["protein"] ?? 0).toDouble()).toStringAsFixed(1),
        );

        todayFat = double.parse(
          ((data["fat"] ?? 0).toDouble()).toStringAsFixed(1),
        );

        todayCarbs = double.parse(
          ((data["carbs"] ?? 0).toDouble()).toStringAsFixed(1),
        );
      });
    } catch (e) {
      debugPrint("Error loading today stats: $e");
    }
  }

  // ---------------- FETCH HISTORY ----------------

  Future<void> fetchWeeklyHistory() async {
    final url = "${AppConfig.baseUrl}/api/meal/history?user_id=$userId";

    try {
      final res = await http.get(Uri.parse(url));
      final data = jsonDecode(res.body);

      setState(() {
        weeklyHistory = List<Map<String, dynamic>>.from(data["history"] ?? []);
      });
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  // ---------- Fill missing days to 0 calorie --------
  List<Map<String, dynamic>> getLast7DaysHistory() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> result = [];

    // Create a map for quick lookup by date (yyyy-MM-dd)
    final Map<String, double> lookup = {};
    for (var item in weeklyHistory) {
      String key = item["date"].toString().split("T")[0];
      lookup[key] = item["calories"].toDouble();
    }

    for (int i = 7; i > 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = DateFormat("yyyy-MM-dd").format(day);

      result.add({
        "date": key,
        "calories": lookup[key] ?? 0, // if missing → 0 calories
      });
    }

    return result;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      //        HEADER
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "EatSmart",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        actions: [
          const SizedBox(width: 4),
          // Profile icon
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: Colors.black87,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          const HistoryScreen(date: '2025-11-06'),
          const RecipeScreen(),
          const MoreScreen(),
        ],
      ),

      //FOOTER
      bottomNavigationBar: Container(
        height: 70,
        color: Colors.transparent,
        padding: const EdgeInsets.only(bottom: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _footerIcon(Icons.home_outlined, 0),
            _footerIcon(Icons.history, 1),

            //CENTER ADD BUTTON
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FoodSearchScreen()),
                );
                loadData();
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: const Icon(Icons.add, size: 26, color: Colors.white),
              ),
            ),

            _footerIcon(Icons.menu_book, 2),
            _footerIcon(Icons.more_horiz, 3),
          ],
        ),
      ),
    );
  }

  // FOOTER ICON
  Widget _footerIcon(IconData icon, int index) {
    final bool selected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Icon(
        icon,
        size: 31,
        color: selected ? Colors.black : Colors.grey.shade400,
      ),
    );
  }

  //        HOME PAGE
  Widget _buildHomeContent() {
    double calProgress = todayCalories / dailyGoal;
    double proteinProgress = todayProtein / proteinGoal;
    double fatProgress = todayFat / fatGoal;

    Widget _nutrientBar({
      required IconData icon,
      required String label,
      required double value,
      required Color color,
      required String amountText,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: 160,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(color: color),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amountText,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    final fixed7 = getLast7DaysHistory();

    double maxCal = fixed7
        .map((e) => e["calories"].toDouble())
        .fold(0, (a, b) => a > b ? a : b);
    if (maxCal == 0) maxCal = 1; // avoid divide-by-zero

    String formatDate(String iso) {
      try {
        final dt = DateTime.parse(iso);
        return "${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      } catch (e) {
        return "";
      }
    }

    //        CONTENT UI
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              "Today's Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // SUMMARY CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFA),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 170,
                            height: 170,
                            child: CircularProgressIndicator(
                              value: calProgress,
                              strokeWidth: 12,
                              backgroundColor: const Color(0xFFF8EFEB),
                              color: const Color(0xFFF5B766),
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: proteinProgress,
                              strokeWidth: 12,
                              backgroundColor: const Color(0xFFECEFFC),
                              color: const Color(0xFF7599E6),
                            ),
                          ),
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: CircularProgressIndicator(
                              value: fatProgress,
                              strokeWidth: 12,
                              backgroundColor: const Color(0xFFE7FBE8),
                              color: const Color(0xFF99D47C),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                "$todayCalories / $dailyGoal",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text("kcal"),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 25),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _nutrientBar(
                            icon: Icons.local_fire_department,
                            label: "Calories",
                            value: calProgress,
                            color: const Color(0xFFF5B766),
                            amountText: "$todayCalories kcal",
                          ),
                          _nutrientBar(
                            icon: Icons.fitness_center,
                            label: "Protein",
                            value: proteinProgress,
                            color: const Color(0xFF7599E6),
                            amountText: "$todayProtein g",
                          ),
                          _nutrientBar(
                            icon: Icons.water_drop,
                            label: "Fat",
                            value: fatProgress,
                            color: const Color(0xFF99D47C),
                            amountText: "$todayFat g",
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      backgroundColor: const Color(0xFFDDF6FC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FoodSearchScreen(),
                        ),
                      );
                      loadData();
                    },
                    icon: const Icon(Icons.restaurant),
                    label: const Text("Log Food"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // WEEKLY CHART
            const Text(
              "Calorie History",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFc8f0ef),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Last 7 Days",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(fixed7.length, (index) {
                        double value = fixed7[index]["calories"].toDouble();
                        double barHeight = (value / maxCal) * 150;

                        return Column(
                          children: [
                            Container(
                              width: 14,
                              height: 150,
                              alignment: Alignment.bottomCenter,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                  255,
                                  171,
                                  212,
                                  220,
                                ).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                width: 14,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatDate(fixed7[index]["date"]),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
