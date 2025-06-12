import 'package:flutter/material.dart';
class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const SidebarItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label),
      dense: true,
    );
  }
}