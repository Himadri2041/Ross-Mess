import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ross_mess_app/Auth/login_screen.dart';

import '../Auth/email_login.dart';
import '../Auth/profile_screen.dart';
import 'Admin/home_page.dart';
import 'Student/home_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EntrySelectionScreen()),
      );
    } else {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data == null || data['profileCompleted'] != true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileFormScreen()),
        );
      } else {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        final isAdmin = userDoc.data()?['isAdmin'] ?? false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isAdmin ?  AdminHome() :  HomeScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'Assets/images/splash.svg', // Replace with your SVG asset path
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
