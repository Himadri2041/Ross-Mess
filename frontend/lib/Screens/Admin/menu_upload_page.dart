
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fonts.dart';
import 'meal_input.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuUploadScreen extends StatefulWidget {
  @override
  _MenuUploadScreenState createState() => _MenuUploadScreenState();
}

class _MenuUploadScreenState extends State<MenuUploadScreen> {
  List<Map<String, dynamic>> breakfastItems = [];
  List<Map<String, dynamic>> lunchItems = [];
  List<Map<String, dynamic>> dinnerItems = [];
  List<Map<String, dynamic>> snackItems = [];
  double? breakfastPrice;
  double? lunchPrice;
  double? dinnerPrice;
  double? snackPrice;
  Future<void> uploadMenu() async {
    try {
      if (breakfastItems.isEmpty || lunchItems.isEmpty || dinnerItems.isEmpty || snackItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(" Please fill all meal items before uploading!")),
        );
        return;
      }
      // Upload to Firestore
      await FirebaseFirestore.instance.collection('menu').doc('today').set({
        'breakfast': {'items': breakfastItems, 'price': breakfastPrice??0.0},
        'lunch': {'items': lunchItems, 'price': lunchPrice??0.0},
        'dinner': {'items': dinnerItems, 'price': dinnerPrice??0.0},
        'snack': {'items': snackItems, 'price': snackPrice??0.0},
        'timestamp': FieldValue.serverTimestamp(),
      });


      // Call your backend to trigger push notification
      final url = Uri.parse("https://ross-mess.onrender.com/notify-menu-upload");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"day": "today"}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Menu uploaded & sent to ${data['sent']} users!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Menu uploaded but notification failed")),
        );
      }
    } catch (e) {
      print(" Upload or notification error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Error uploading menu: $e")),
      );
    }
  }


  Future<void> navigateToMeal(String meal) async {
    List<Map<String, dynamic>> currentItems;
    double? currentPrice;

    switch (meal) {
      case 'Breakfast':
        currentItems = breakfastItems;
        currentPrice = breakfastPrice;
        break;
      case 'Lunch':
        currentItems = lunchItems;
        currentPrice = lunchPrice;
        break;
      case 'Snack':
        currentItems = snackItems;
        currentPrice = snackPrice;
        break;
      case 'Dinner':
        currentItems = dinnerItems;
        currentPrice = dinnerPrice;
        break;
      default:
        currentItems = [];
        currentPrice = 0.0;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealInputScreen(
          mealType: meal,
          initialItems: currentItems,
          initialPrice: currentPrice,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        switch (meal) {
          case 'Breakfast':
            breakfastItems = result['items'];
            breakfastPrice = result['price'];
            break;
          case 'Lunch':
            lunchItems = result['items'];
            lunchPrice = result['price'];
            break;
          case 'Snack':
            snackItems = result['items'];
            snackPrice = result['price'];
            break;
          case 'Dinner':
            dinnerItems = result['items'];
            dinnerPrice = result['price'];
            break;
        }
      });
    }
  }


  Widget buildMealTile(String title, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => navigateToMeal(title),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          minVerticalPadding: 20, // (20 * 2) + icon height ≈ 80px total height
          leading: Icon(icon, size: 32),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

        ),
      ),
    );


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("Upload Menu",style:AppFonts.title.copyWith(
        letterSpacing: 0.5,   // optional
      )), actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildMealTile('Breakfast', Icons.local_cafe),
            buildMealTile('Lunch', Icons.wb_sunny),
            buildMealTile('Snack', Icons.fastfood),
            buildMealTile('Dinner', Icons.nightlight_round_outlined),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: uploadMenu,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[500],
                minimumSize: const Size(double.infinity, 48),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Upload Menu",
                  style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
