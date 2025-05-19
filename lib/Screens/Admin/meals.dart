import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarkAttendanceScreen extends StatefulWidget {
  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final TextEditingController rollController = TextEditingController();
  String selectedMeal = 'breakfast';
  bool isVeg = true;
  bool isTaken = false;

  final List<String> meals = ['breakfast', 'lunch', 'dinner'];

  // Dynamic list of extras: each entry is a map of item & price controllers
  List<Map<String, TextEditingController>> extras = [
    {'item': TextEditingController(), 'price': TextEditingController()}
  ];

  void submitAttendance() async {
    final roll = rollController.text.trim();
    if (roll.isEmpty) return;

    final today = DateTime.now();
    final docId =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    // Get extras
    final List<Map<String, dynamic>> extrasData = extras
        .where((extra) =>
    extra['item']!.text.trim().isNotEmpty &&
        extra['price']!.text.trim().isNotEmpty)
        .map((extra) => {
      'item': extra['item']!.text.trim(),
      'price': double.tryParse(extra['price']!.text.trim()) ?? 0,
    })
        .toList();

    final mealData = {
      'taken': isTaken,
      'veg': isVeg,
      'extras': extrasData,
    };

    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(docId)
        .set({
      roll: {selectedMeal: mealData},
    }, SetOptions(merge: true));

    // Clear inputs after submission
    rollController.clear();
    for (var extra in extras) {
      extra['item']!.clear();
      extra['price']!.clear();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Marked $selectedMeal for $roll")),
    );
  }

  @override
  void dispose() {
    rollController.dispose();
    for (var extra in extras) {
      extra['item']!.dispose();
      extra['price']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mark Attendance")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: rollController,
              decoration: const InputDecoration(labelText: "Enter Roll Number"),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedMeal,
              items: meals
                  .map((meal) =>
                  DropdownMenuItem(value: meal, child: Text(meal.toUpperCase())))
                  .toList(),
              onChanged: (value) => setState(() => selectedMeal = value!),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Taken:"),
                Switch(
                  value: isTaken,
                  onChanged: (value) => setState(() => isTaken = value),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Veg:"),
                Switch(
                  value: isVeg,
                  onChanged: (value) => setState(() => isVeg = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Extras",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ...extras.asMap().entries.map((entry) {
              int index = entry.key;
              var extra = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: extra['item'],
                      decoration:
                      const InputDecoration(labelText: "Extra Item"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: extra['price'],
                      keyboardType: TextInputType.number,
                      decoration:
                      const InputDecoration(labelText: "Price (₹)"),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        extras.removeAt(index);
                      });
                    },
                  )
                ],
              );
            }),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  extras.add({
                    'item': TextEditingController(),
                    'price': TextEditingController()
                  });
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Extra"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: submitAttendance,
              child: const Text("Mark Attendance"),
            ),
          ],
        ),
      ),
    );
  }
}
