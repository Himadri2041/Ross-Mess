import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Appcolors.dart';

class MenuUploadScreen extends StatefulWidget {
  @override
  _MenuUploadScreenState createState() => _MenuUploadScreenState();
}

class _MenuUploadScreenState extends State<MenuUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  String breakfast = '', lunch = '', dinner = '';

  void uploadMenu() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('menu').doc('today').set({
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Menu uploaded!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: MessColors.test,
          centerTitle: false,
          title: const Text(
            "Upload Today's Menu",
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Chakra_Petch',
                fontWeight: FontWeight.w900),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Breakfast',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => breakfast = val,
            ),
            const SizedBox(height: 18),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Lunch',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => lunch = val,
            ),
            const SizedBox(height: 18),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Dinner',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => dinner = val,
            ),
            SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MessColors.test,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: uploadMenu,
                child: const Text("Upload Menu")),
          ]),
        ),
      ),
    );
  }
}
