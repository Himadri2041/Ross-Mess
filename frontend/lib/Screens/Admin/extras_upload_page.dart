import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../fonts.dart';

class AdminOrderScreen extends StatefulWidget {
  @override
  _AdminOrderScreenState createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  double price = 0;

  List<Map<String, String>> availableImages = [];
  Map<String, String>? selectedImage;

  bool _isLoadingImages = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    fetchCloudinaryImages();
  }

  Future<void> fetchCloudinaryImages() async {
    setState(() => _isLoadingImages = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('images')
          .orderBy('timestamp', descending: true)
          .get();

      final List<Map<String, String>> images = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'label': (data['tag'] ?? 'Image').toString(),
          'url': data['url'].toString(),
        };
      }).toList();

      setState(() {
        availableImages = images;
        selectedImage = images.isNotEmpty ? images.first : null;
      });
    } catch (e) {
      print("❌ Error fetching images: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load images")));
    } finally {
      setState(() => _isLoadingImages = false);
    }
  }

  Future<void> notifyNewItem(String itemTitle) async {
    try {
      final url = Uri.parse("https://ross-mess.onrender.com/notify-new-item");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'itemTitle': itemTitle}),
      );

      if (response.statusCode == 200) {
        print('✅ Notification sent');
      } else {
        print('❌ Notification failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error sending notification: $e');
    }
  }

  void uploadOrderItem() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() => _isUploading = true);

    try {
      await FirebaseFirestore.instance.collection('orderItems').add({
        'title': title,
        'price': price,
        'imageUrl': selectedImage?['url'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      await notifyNewItem(title);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Item uploaded successfully!')),
      );

      setState(() {
        title = '';
        price = 0;
        selectedImage = availableImages.isNotEmpty ? availableImages.first : null;
      });

      _formKey.currentState!.reset();
    } catch (e) {
      print('❌ Upload failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.amber[400],
        elevation: 2,
        title: Text('Add Extra Item', style: AppFonts.title.copyWith(letterSpacing: 0.5)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: _isLoadingImages
            ? CircularProgressIndicator(color: Colors.amber)
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 24),

                    // Title Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        prefixIcon: Icon(Icons.fastfood),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onSaved: (val) => title = val!.trim(),
                      validator: (val) => val == null || val.isEmpty ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 16),

                    // Price Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Price',
                        prefixIcon: Icon(Icons.currency_rupee),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onSaved: (val) => price = double.tryParse(val!) ?? 0,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter price';
                        if (double.tryParse(val) == null) return 'Enter valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Image Dropdown
                    DropdownButtonFormField<Map<String, String>>(
                      value: selectedImage,
                      decoration: InputDecoration(
                        labelText: 'Select Image',
                        prefixIcon: Icon(Icons.image),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      isExpanded: true,
                      items: availableImages.map((img) {
                        return DropdownMenuItem(
                          value: img,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  img['url']!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  img['label']!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedImage = val),
                      validator: (val) => val == null ? 'Please select an image' : null,
                    ),
                    const SizedBox(height: 30),

                    // Upload Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : uploadOrderItem,
                        icon: _isUploading
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : Icon(Icons.upload),
                        label: Text(
                          _isUploading ? "Uploading..." : "Upload Item",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
