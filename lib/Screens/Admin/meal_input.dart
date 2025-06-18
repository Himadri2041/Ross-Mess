import 'package:flutter/material.dart';

class MealInputScreen extends StatefulWidget {
  final String mealType;
  final List<Map<String, dynamic>> initialItems;

  MealInputScreen({required this.mealType, this.initialItems = const []});

  @override
  _MealInputScreenState createState() => _MealInputScreenState();
}

class _MealInputScreenState extends State<MealInputScreen> {
  final predefinedImages = {
    'Maggi': 'Assets/images/maggie.png',
    'Dal': 'Assets/images/dal.jpg',
  };

  List<Map<String, dynamic>> mealItems = [];

  @override
  void initState() {
    super.initState();
    mealItems = List.from(widget.initialItems);

    // Attach controllers to each item
    for (var item in mealItems) {
      item['controller'] = TextEditingController(text: item['name'] ?? '');
    }
  }

  void addMealItem() {
    setState(() {
      mealItems.add({
        'name': '',
        'image': predefinedImages.values.first,
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

    if (cleanedItems.any((item) => item['name'].isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All items must have a name")),
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
        title: Text("Enter ${widget.mealType} Menu"),
        actions: [
          IconButton(onPressed: saveMenu, icon: Icon(Icons.check)),
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
                          Image.asset(item['image'], width: 70, height: 50),
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
                            onSelected: (selectedImage) {
                              setState(() {
                                item['image'] = selectedImage;
                              });
                            },
                            itemBuilder: (context) {
                              return predefinedImages.entries.map((entry) {
                                return PopupMenuItem<String>(
                                  value: entry.value,
                                  child: Row(
                                    children: [
                                      Image.asset(entry.value,
                                          width: 30, height: 30),
                                      const SizedBox(width: 8),
                                      Text(entry.key),
                                    ],
                                  ),
                                );
                              }).toList();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.black),
                            onPressed: () => deleteMealItem(index),
                            tooltip: "Delete Item",
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: addMealItem,
              icon: const Icon(Icons.add_rounded),
              label: const Text("Add Meal"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade500,
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
