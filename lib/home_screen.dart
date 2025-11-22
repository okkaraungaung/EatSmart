import 'package:flutter/material.dart';
import 'food_search_screen.dart';
import 'history_screen.dart';
import 'recipe_builder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int dailyGoal = 2000;
  int todayCalories = 1450;
  int protein = 120;
  int proteingoal = 200;
  int fat = 60;
  int fatgoal = 100;

  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildHomeContent(),
      const HistoryScreen(date: '2025-11-06'),
      const RecipeBuilderScreen(),
      _buildMoreScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EatSmart"), centerTitle: true),
      body: IndexedStack(index: _selectedIndex, children: _screens),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF232334),
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FoodSearchScreen()),
          );
        },
        child: const Icon(Icons.search, size: 29, color: Color(0xFF2E5BFF)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF232334),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.history, "History", 1),
              const SizedBox(width: 48),
              _buildNavItem(Icons.menu_book, "Recipe", 2),
              _buildNavItem(Icons.more_horiz, "More", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    double calProgress = todayCalories / dailyGoal;
    double proteinProgress = protein / proteingoal;
    double fatProgress = fat / fatgoal;

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

    // 🔥 7-day history (you can replace with real data)
    List<Map<String, dynamic>> history = [
      {"date": "2025-11-06", "calories": 1800},
      {"date": "2025-11-05", "calories": 1950},
      {"date": "2025-11-04", "calories": 1700},
      {"date": "2025-11-03", "calories": 1600},
      {"date": "2025-11-02", "calories": 1500},
      {"date": "2025-11-01", "calories": 1900},
      {"date": "2025-10-31", "calories": 2000},
    ];

    // Used for scaling bar height
    double maxCal = history
        .map<double>((e) => e["calories"].toDouble())
        .reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //-------------------------------------------------------
            // 🔵 SUMMARY SECTION
            //-------------------------------------------------------
            const Text(
              "Today's Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 249, 250, 250),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
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
                            amountText: "$protein g",
                          ),
                          _nutrientBar(
                            icon: Icons.water_drop,
                            label: "Fat",
                            value: fatProgress,
                            color: const Color(0xFF99D47C),
                            amountText: "$fat g",
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FoodSearchScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.restaurant),
                    label: const Text("Log Food"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //WEEKLY CHART
            const Text(
              "Calorie History",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFc8f0ef), // Light blue background
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
                      children: List.generate(history.length, (index) {
                        double value = history[index]["calories"].toDouble();
                        double barHeight = (value / maxCal) * 100;

                        return Column(
                          children: [
                            // Vertical thin bar
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
                                  color: const Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              history[index]["date"].substring(5),
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

  Widget _buildMoreScreen() {
    return const Center(
      child: Text(
        "More Settings Coming Soon",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2E5BFF) : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2E5BFF) : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
