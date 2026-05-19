import 'package:flutter/material.dart';

class AppCategory {
  const AppCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;
}

const appCategories = <AppCategory>[
  AppCategory(name: 'Food', icon: Icons.restaurant, color: Color(0xFFE85D75)),
  AppCategory(name: 'Transport', icon: Icons.directions_bus, color: Color(0xFF2A9D8F)),
  AppCategory(name: 'Shopping', icon: Icons.shopping_bag, color: Color(0xFFF4A261)),
  AppCategory(name: 'Entertainment', icon: Icons.movie, color: Color(0xFF7C6FF6)),
  AppCategory(name: 'Bills', icon: Icons.receipt_long, color: Color(0xFF457B9D)),
  AppCategory(name: 'Health', icon: Icons.local_hospital, color: Color(0xFF06D6A0)),
];

AppCategory categoryByName(String name) {
  return appCategories.firstWhere(
    (category) => category.name == name,
    orElse: () => appCategories.first,
  );
}
