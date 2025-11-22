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

    List<Map<String, dynamic>> history = [
      {"date": "2025-11-06", "calories": 1800},
      {"date": "2025-11-05", "calories": 1950},
      {"date": "2025-11-04", "calories": 1700},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

            // CONTENT INSIDE WHITE BOX
            child: Column(
              children: [
                // ROW: CYCLE + BARS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 3-LAYER CYCLE (UNCHANGED)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Calories
                        SizedBox(
                          width: 170,
                          height: 170,
                          child: CircularProgressIndicator(
                            value: calProgress,
                            strokeWidth: 12,
                            backgroundColor: const Color.fromARGB(
                              255,
                              248,
                              239,
                              235,
                            ),
                            color: const Color(0xFFF5B766),
                          ),
                        ),

                        // Protein
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: proteinProgress,
                            strokeWidth: 12,
                            backgroundColor: const Color.fromARGB(
                              255,
                              236,
                              239,
                              252,
                            ),
                            color: const Color(0xFF7599E6),
                          ),
                        ),

                        // Fat
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: CircularProgressIndicator(
                            value: fatProgress,
                            strokeWidth: 12,
                            backgroundColor: const Color.fromARGB(
                              255,
                              231,
                              251,
                              232,
                            ),
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
                    // Bars WITH icons (line-by-line)
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

          const Text(
            "Calorie History",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final day = history[index];
                return Card(
                  child: ListTile(
                    title: Text(day['date']),
                    trailing: Text(
                      "${day['calories']} kcal",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
