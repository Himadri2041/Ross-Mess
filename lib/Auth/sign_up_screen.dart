import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Appcolors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _StudentSignupScreenState();
}

class _StudentSignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final rollNoController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(authResult.user!.uid)
          .set({
        'name': nameController.text.trim(),
        'rollNo': rollNoController.text.trim(),
        'email': emailController.text.trim(),
        'isAdmin': false,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Signup successful!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter name' : null,
                  ),
                  TextFormField(
                    controller: rollNoController,
                    decoration: const InputDecoration(labelText: 'Roll No'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter roll number' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (val) => val == null || !val.contains('@')
                        ? 'Enter valid email'
                        : null,
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (val) =>
                        val == null || val.length < 6 ? 'Min 6 chars' : null,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Sign Up'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:MessColors.test,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                        ),)
,                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
