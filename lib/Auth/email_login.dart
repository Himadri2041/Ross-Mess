import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Appcolors.dart';
import '../Screens/Admin/home_page.dart';

import '../Screens/Student/home_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);

    try {
      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authResult.user!.uid)
          .get();

      final isAdmin = userDoc['isAdmin'] ?? false;
      final rollNo = userDoc['rollNo'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isAdmin
              ? AdminHome()
              : HomeScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //   body: Padding(
    //     padding: const EdgeInsets.all(16),
    //     child: Column(
    //       children: [
    //         TextField(
    //           controller: emailController,
    //           decoration: const InputDecoration(labelText: 'Email'),
    //         ),
    //         TextField(
    //           controller: passwordController,
    //           decoration: const InputDecoration(labelText: 'Password'),
    //           obscureText: true,
    //         ),
    //         const SizedBox(height: 20),
    //         _isLoading
    //             ? const Center(child: CircularProgressIndicator())
    //             : ElevatedButton(
    //           onPressed: _login,
    //           child: const Text('Login'),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
      body:Stack(

        children: [
          // 👇 Background image
          SizedBox.expand(
            child: Image.asset(
              'Assets/images/maggie.png', // replace with your image path
              fit: BoxFit.cover,
            ),
          ),

          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 24),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(


                    style: ElevatedButton.styleFrom(
                      backgroundColor:MessColors.test,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _login,
                    child: const Text("Log In"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
