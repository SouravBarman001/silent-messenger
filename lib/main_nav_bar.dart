import 'package:flutter/material.dart';
import 'package:we_chat/screens/contact_info/contact_info_screen.dart';
import 'package:we_chat/screens/home_page/home_screen.dart';
import 'package:we_chat/screens/sign_language/live_translation.dart';
import 'package:we_chat/screens/sign_language/viewfinder.dart';
class MainNavBar extends StatefulWidget {
  const MainNavBar({super.key});

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.message),
            icon: Icon(Icons.message),
            label: 'Message',
          ),
          NavigationDestination(
            icon: Icon(Icons.contact_page),
            label: 'Contact Info',
          ),
          NavigationDestination(
            icon: Icon(Icons.language),
            label: 'Sign Language',
          ),
        ],
      ),
      body: <Widget>[
        // Your custom screens
        const HomeScreen(),
        const ContactInfoScreen(),
        const SignLanguageCamera(),
      ][currentPageIndex],
    );
  }
}