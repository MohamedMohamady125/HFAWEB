import 'package:flutter/material.dart';
import 'athlete_home_screen.dart';
import 'athlete_gear_screen.dart';
import 'athlete_profile_screen.dart';
import '../shared/threads_screen.dart';

class AthleteMainScreen extends StatefulWidget {
  const AthleteMainScreen({super.key});

  @override
  State<AthleteMainScreen> createState() => _AthleteMainScreenState();
}

class _AthleteMainScreenState extends State<AthleteMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AthleteHomeScreen(),
    const AthleteGearScreen(),
    const ThreadsScreen(),
    const AthleteProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sports), label: 'Gear'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Threads'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
