import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../fonts.dart';

class SelectMealScreen extends StatelessWidget {
  final List<String> meals = ['breakfast', 'lunch', 'snack', 'dinner'];

  final mealIcons = {
    'breakfast': Icons.local_cafe,
    'lunch': Icons.wb_sunny,
    'snack': Icons.fastfood,
    'dinner': Icons.nightlight_round,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("Select Meal",style: AppFonts.title.copyWith(
        letterSpacing: 0.5,   // optional
      ),),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: meals.map((meal) {
            return Card(
              child: ListTile(
                minTileHeight: 80,
                leading: Icon(mealIcons[meal], size: 32),
                title: Text(meal[0].toUpperCase() + meal.substring(1),style: TextStyle(fontSize:16,fontWeight: FontWeight.w700),),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MarkAttendanceScreen(meal: meal),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


class MarkAttendanceScreen extends StatefulWidget {
  final String meal;
  const MarkAttendanceScreen({required this.meal, Key? key}) : super(key: key);

  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final TextEditingController rollController = TextEditingController();
  bool isVeg = true;
  bool isTaken = false;

  List<Map<String, dynamic>> orderItems = [];
  Map<String, bool> selectedItems = {};

  @override
  void initState() {
    super.initState();
    fetchOrderItems();
  }

  void fetchOrderItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orderItems')
        .orderBy('timestamp', descending: true)
        .get();

    final items = snapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      orderItems = items;
      for (var item in orderItems) {
        selectedItems[item['title']] = false;
      }
    });
  }

  // void submitAttendance() async {
  //   final roll = rollController.text.trim();
  //   if (roll.isEmpty) return;
  //
  //   final today = DateTime.now();
  //   final docId =
  //       "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
  //
  //   final extrasData = orderItems
  //       .where((item) => selectedItems[item['title']] == true)
  //       .map((item) => {
  //     'item': item['title'],
  //     'price': item['price'],
  //   })
  //       .toList();
  //
  //   final mealData = {
  //     'taken': isTaken,
  //     'veg': isVeg,
  //     'extras': extrasData,
  //   };
  //
  //   await FirebaseFirestore.instance
  //       .collection('attendance')
  //       .doc(docId)
  //       .set({
  //     roll: {widget.meal: mealData},
  //   }, SetOptions(merge: true));
  //
  //   rollController.clear();
  //   setState(() {
  //     selectedItems.updateAll((key, value) => false);
  //   });
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("Marked ${widget.meal} for $roll")),
  //   );
  // }
  void submitAttendance() async {
    final roll = rollController.text.trim();
    if (roll.isEmpty) return;

    final today = DateTime.now();
    final docId =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    // Fetch today's menu to get meal price
    final menuSnapshot = await FirebaseFirestore.instance.collection('menu').doc('today').get();
    final menuData = menuSnapshot.data();
    double mealPrice = 0.0;

    if (menuData != null && menuData.containsKey(widget.meal)) {
      final mealInfo = menuData[widget.meal];
      mealPrice = (mealInfo['price'] ?? 0).toDouble();
    }

    // Extras
    final extrasData = orderItems
        .where((item) => selectedItems[item['title']] == true)
        .map((item) => {
      'item': item['title'],
      'price': item['price'],
    })
        .toList();

    // Calculate total price
    double totalBill = 0.0;
    if (isTaken) {
      totalBill += mealPrice;
    }
    for (var extra in extrasData) {
      totalBill += (extra['price'] ?? 0).toDouble();
    }

    // Save meal attendance
    final mealData = {
      'taken': isTaken,
      'veg': isVeg,
      'extras': extrasData,
      'price': isTaken ? mealPrice : 0.0,
      'totalBill': totalBill,
    };

    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(docId)
        .set({
      roll: {widget.meal: mealData},
    }, SetOptions(merge: true));

    try {
      final url = Uri.parse("http://192.168.3.71:3000/notify-attendance-marked");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rollNo': roll,
          'meal': widget.meal,
        }),
      );

      if (response.statusCode == 200) {
        print(" Attendance notification sent successfully!");
      } else {
        print(" Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print(" Error sending notification: $e");
    }

    rollController.clear();
    setState(() {
      selectedItems.updateAll((key, value) => false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Marked ${widget.meal} for $roll — ₹${totalBill.toStringAsFixed(2)} added")),
    );
  }

  @override
  void dispose() {
    rollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealTitle = widget.meal[0].toUpperCase() + widget.meal.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: Text("$mealTitle Attendance"),
        backgroundColor: Colors.amber[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: rollController,
                      decoration: InputDecoration(
                        labelText: "Roll Number",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text("Meal Taken",style:TextStyle(fontWeight:FontWeight.w600)),
                      value: isTaken,
                      onChanged: (value) => setState(() => isTaken = value),
                      activeColor: Colors.orange,
                      secondary: const Icon(Icons.check_circle_outline),
                    ),
                    SwitchListTile(
                      title: const Text("Vegetarian",style:TextStyle(fontWeight:FontWeight.w600)),
                      value: isVeg,
                      onChanged: (value) => setState(() => isVeg = value),
                      activeColor: Colors.orange,
                      secondary: const Icon(Icons.eco_outlined),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (orderItems.isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Extras",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      ...orderItems.map((item) {
                        return CheckboxListTile(
                          title: Text("${item['title']} (₹${item['price']})",style:TextStyle(fontWeight:FontWeight.w600)),
                          value: selectedItems[item['title']] ?? false,
                          onChanged: (value) {
                            setState(() {
                              selectedItems[item['title']] = value!;
                            });
                          },
                          activeColor: Colors.orange,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: submitAttendance,
              label: const Text("Mark Attendance", style:TextStyle(fontWeight:FontWeight.w600,color:Colors.black,fontSize:18),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[500],
                minimumSize: const Size(double.infinity, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
