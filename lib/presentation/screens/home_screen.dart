import 'package:flutter/material.dart';
import 'package:petmaster_app/presentation/screens/pet_list_screen.dart';
import 'package:petmaster_app/presentation/screens/settings_screen.dart';
import 'package:petmaster_app/presentation/screens/facts_screen.dart'; // Импортируем FactsScreen
import 'package:petmaster_app/core/theme/app_colors.dart';
import 'package:petmaster_app/presentation/widgets/custom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Обновляем список экранов
  final List<Widget> _screens = [
    PetListScreen(),
    FactsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
