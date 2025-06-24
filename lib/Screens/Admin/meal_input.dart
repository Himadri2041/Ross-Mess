import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../fonts.dart';

class MealInputScreen extends StatefulWidget {
  final String mealType;
  final List<Map<String, dynamic>> initialItems;

  const MealInputScreen({required this.mealType, this.initialItems = const []});

  @override
  _MealInputScreenState createState() => _MealInputScreenState();
}

class _MealInputScreenState extends State<MealInputScreen> {
  List<Map<String, dynamic>> mealItems = [];
  List<Map<String, String>> cloudImages = [];

  @override
  void initState() {
    super.initState();
    mealItems = List.from(widget.initialItems);
    for (var item in mealItems) {
      item['controller'] = TextEditingController(text: item['name'] ?? '');
    }
    fetchCloudImages();
  }

  Future<void> fetchCloudImages() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('images')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      cloudImages = snapshot.docs.map<Map<String, String>>((doc) {
        final data = doc.data();
        return {
          'label': (data['tag'] ?? 'Image').toString(),
          'url': data['url'].toString(),
        };
      }).toList();
    });
  }

  void addMealItem() {
    setState(() {
      mealItems.add({
        'name': '',
        'image': null,
        'controller': TextEditingController(),
      });
    });
  }

  void deleteMealItem(int index) {
    setState(() {
      mealItems[index]['controller']?.dispose();
      mealItems.removeAt(index);
    });
  }

  void saveMenu() {
    final cleanedItems = mealItems.map((item) {
      final name = item['controller']?.text.trim() ?? '';
      return {
        'name': name,
        'image': item['image'],
      };
    }).toList();

    if (cleanedItems.any((item) => item['name'].isEmpty || item['image'] == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Each item must have a name and an image")),
      );
      return;
    }

    Navigator.pop(context, cleanedItems);
  }

  @override
  void dispose() {
    for (var item in mealItems) {
      item['controller']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[400],
        title: Text("${widget.mealType} Menu",style:AppFonts.title.copyWith(
          letterSpacing: 0.5,   // optional
        )),
        actions: [
          IconButton(onPressed: saveMenu, icon: Icon(Icons.upload_rounded)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: mealItems.length,
                itemBuilder: (context, index) {
                  final item = mealItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          item['image'] != null
                              ? Image.network(item['image'], width: 70, height: 50, fit: BoxFit.cover)
                              : Container(width: 70, height: 50, color: Colors.grey[300]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: item['controller'],
                              decoration: const InputDecoration(
                                hintText: "Enter Item Name",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.image),
                            itemBuilder: (context) {
                              return cloudImages.map((img) {
                                return PopupMenuItem<String>(
                                  value: img['url']!,
                                  child: Row(
                                    children: [
                                      Image.network(img['url']!, width: 30, height: 30),
                                      const SizedBox(width: 8),
                                      Text(img['label'] ?? 'Image'),
                                    ],
                                  ),
                                );
                              }).toList();
                            },
                            onSelected: (value) {
                              setState(() {
                                item['image'] = value;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteMealItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: addMealItem,
              icon: Icon(Icons.add),
              label: Text("Add Meal",style: TextStyle(fontSize:18,fontWeight: FontWeight.w600),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
