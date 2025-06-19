import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminOrderScreen extends StatefulWidget {
  @override
  _AdminOrderScreenState createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  double price = 0;
  String? selectedImage;

  List<String> availableImages = [];

  @override
  void initState() {
    super.initState();
    fetchCloudinaryImages();
  }

  Future<void> fetchCloudinaryImages() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('images')
          .orderBy('timestamp', descending: true)
          .get();

      final List<String> urls = snapshot.docs.map((doc) {
        return doc['url'] as String;
      }).where((url) => url.isNotEmpty).toList();

      setState(() {
        availableImages = urls;
        selectedImage = urls.isNotEmpty ? urls.first : null;
      });
    } catch (e) {
      print("❌ Error fetching Cloudinary images: $e");
    }
  }

  Future<void> notifyNewItem(String itemTitle) async {
    try {
      final url = Uri.parse("http://192.168.31.163:3000/notify-new-item");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'itemTitle': itemTitle}),
      );

      if (response.statusCode == 200) {
        print('✅ Notification sent for item: $itemTitle');
      } else {
        print('❌ Failed to send notification: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error sending notification: $e');
    }
  }

  void uploadOrderItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirebaseFirestore.instance.collection('orderItems').add({
        'title': title,
        'price': price,
        'imageUrl': selectedImage,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await notifyNewItem(title);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🎉 Item uploaded successfully!')),
      );

      setState(() {
        title = '';
        price = 0;
        selectedImage =
        availableImages.isNotEmpty ? availableImages.first : null;
      });

      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.amber[400],
        elevation: 2,
        title: Text('Add Extra Item', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Add Extra Item",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        prefixIcon: Icon(Icons.fastfood),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSaved: (val) => title = val!.trim(),
                      validator: (val) =>
                      val == null || val.isEmpty
                          ? 'Enter a title'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Price Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Price',
                        prefixIcon: Icon(Icons.currency_rupee),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true),
                      onSaved: (val) => price = double.tryParse(val!) ?? 0,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter price';
                        if (double.tryParse(val) == null)
                          return 'Enter valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Image Dropdown
                    DropdownButtonFormField<String>(
                      value: availableImages.contains(selectedImage)
                          ? selectedImage
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Select Image',
                        prefixIcon: Icon(Icons.image),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      items: availableImages.map((url) {
                        return DropdownMenuItem(
                          value: url,
                          child: Row(
                            children: [
                              Image.network(url, width: 40, height: 40),
                              const SizedBox(width: 10),
                              Text("Image"),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedImage = val),
                      validator: (val) =>
                      val == null
                          ? 'Please select an image'
                          : null,
                    ),
                    const SizedBox(height: 30),

                    // Upload Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: uploadOrderItem,
                        icon: Icon(Icons.upload),
                        label: Text("Upload Item"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
