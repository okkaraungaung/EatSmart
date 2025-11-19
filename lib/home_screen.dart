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
        backgroundColor: Colors.blueAccent,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FoodSearchScreen()),
          );
        },
        child: const Icon(Icons.add, size: 32),
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
    double progress = todayCalories / dailyGoal;

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
            "Today's Calorie Intake",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "$todayCalories / $dailyGoal",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("kcal", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                backgroundColor: const Color.fromARGB(255, 106, 175, 249),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FoodSearchScreen()),
                );
              },
              icon: const Icon(Icons.restaurant),
              label: const Text("Search Food", style: TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 30),

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
            Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blueAccent : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
