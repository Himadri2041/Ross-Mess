import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../fonts.dart';

class UniversalImageUploader extends StatefulWidget {
  @override
  _UniversalImageUploaderState createState() => _UniversalImageUploaderState();
}

class _UniversalImageUploaderState extends State<UniversalImageUploader> {
  File? _imageFile;
  bool _isUploading = false;
  final picker = ImagePicker();
  final TextEditingController _tagController = TextEditingController();

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<String?> uploadToCloudinary(File file) async {
    const cloudName = 'dlenqod7y';         // 🔁 Change this
    const uploadPreset = 'ross_mess';   // 🔁 Change this

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final resBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(resBody.body);
      return data['secure_url'];
    } else {
      print('Upload failed: ${resBody.body}');
      return null;
    }
  }

  Future<void> uploadAndSaveImage() async {
    if (_imageFile == null || _tagController.text.isEmpty) return;

    setState(() => _isUploading = true);

    final url = await uploadToCloudinary(_imageFile!);
    if (url != null) {
      // Optional: Save to Firestore
      await FirebaseFirestore.instance.collection('images').add({
        'url': url,
        'tag': _tagController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully!')),
      );

      setState(() {
        _imageFile = null;
        _tagController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed')),
      );
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Image",style:AppFonts.title.copyWith(
        letterSpacing: 0.5,   // optional
      ))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _imageFile != null
                ? Image.file(_imageFile!, height: 200)
                : Text("No image selected"),
            SizedBox(height: 16),
            TextField(
              controller: _tagController,
              decoration: InputDecoration(labelText: "Enter tag/category"),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.photo_library),
              label: Text("Pick Image"),
              style:ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[500],
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              )
            ),
            SizedBox(height: 20),
            _isUploading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: uploadAndSaveImage,
              icon: Icon(Icons.cloud_upload),
              label: Text("Upload"),
                style:ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[500],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
