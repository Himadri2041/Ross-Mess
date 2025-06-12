import 'package:flutter/material.dart';
import 'email_login.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';

class EntrySelectionScreen extends StatelessWidget {
  const EntrySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildSquareBox(
              context,
              title: "Admin Login",
              icon: Icons.admin_panel_settings_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(height: 32),
            buildSquareBox(
              context,
              title: "User Sign Up",
              icon: Icons.person_add_alt_1_outlined,

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSquareBox(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    double size = MediaQuery.of(context).size.width * 0.6;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.black.withOpacity(0.1),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: Colors.amber.shade400, // amber background
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.shade200,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.black),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black, // black text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
