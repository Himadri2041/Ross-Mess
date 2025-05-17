import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrderScreen extends StatefulWidget {
  @override
  _AdminOrderScreenState createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  double price = 0;
  String selectedImage = 'maggie.png';

  final List<String> availableImages = [
    'maggie.png',

  ];

  void uploadOrderItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirebaseFirestore.instance.collection('orderItems').add({
        'title': title,
        'price': price,
        'imageName': selectedImage,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order item added!')),
      );

      // Reset form
      setState(() {
        title = '';
        price = 0;
        selectedImage = availableImages[0];
      });
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin: Add Order Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                onSaved: (val) => title = val!.trim(),
                validator: (val) =>
                val == null || val.isEmpty ? 'Enter a title' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType:
                TextInputType.numberWithOptions(decimal: true),
                onSaved: (val) => price = double.tryParse(val!) ?? 0,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter price';
                  if (double.tryParse(val) == null)
                    return 'Enter valid number';
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedImage,
                decoration: InputDecoration(labelText: 'Select Image'),
                items: availableImages.map((imageName) {
                  return DropdownMenuItem(
                    value: imageName,
                    child: Text(imageName.split('.').first.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedImage = val!;
                  });
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: uploadOrderItem,
                child: Text('Add Item'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
