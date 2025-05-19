import 'package:flutter/material.dart';
import 'package:ross_mess_app/Student/home_screen.dart';
import 'package:ross_mess_app/Appcolors.dart';

import '../Widgets/bottom_nav_bar.dart';
import 'sign_up_screen.dart';
import '../Screens/Admin/home_page.dart';
import 'email_login.dart';
class LoginSignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:MessColors.Backcolor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text('Ross Mess', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: MessColors.PrimaryColor)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder:(context)=>LoginScreen()));
              },
              child: Text('Log In',style: TextStyle(color:Colors.white)),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50),backgroundColor:MessColors.PrimaryColor ),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder:(context)=>SignupScreen()));

              },
              child: Text('Sign Up'),
              style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
            SizedBox(height: 30),
            Text("Or", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 10),

          ],
        ),
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  final IconData icon;
  final String text;

  const SignInButton({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.black),
      label: Text(text),
      style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
    );
  }
}
