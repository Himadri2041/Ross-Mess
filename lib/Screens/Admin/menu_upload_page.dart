import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      appBar: AppBar(title: Text("Upload Today's Menu")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Breakfast'),
              onChanged: (val) => breakfast = val,
              validator: (val) => val!.isEmpty ? "Required" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Lunch'),
              onChanged: (val) => lunch = val,
              validator: (val) => val!.isEmpty ? "Required" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Dinner'),
              onChanged: (val) => dinner = val,
              validator: (val) => val!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: 20),
            ElevatedButton(child: Text("Upload Menu"), onPressed: uploadMenu),
          ]),
        ),
      ),
    );
  }
}
