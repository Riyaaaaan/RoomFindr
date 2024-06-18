import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:room_finder/const/const.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            enableFeedback: true,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            currentIndex: currentIndex,
            selectedItemColor: Colors.black,
            backgroundColor: Colors.grey.shade300,
            unselectedItemColor: Colors.grey.shade600,
            items: const [
              BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Iconsax.heart), label: 'Wishlist'),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.add_circled), label: 'Add'),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.bookmark), label: 'My Posts'),
              BottomNavigationBarItem(
                  icon: Icon(Iconsax.user), label: 'Profile'),
            ],
          ),
        ),
      ),
      body: screens[currentIndex],
    );
  }
}
