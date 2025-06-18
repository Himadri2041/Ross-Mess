// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'meal_input.dart';
//
// class MenuUploadScreen extends StatefulWidget {
//   @override
//   _MenuUploadScreenState createState() => _MenuUploadScreenState();
// }
//
// class _MenuUploadScreenState extends State<MenuUploadScreen> {
//   List<Map<String, dynamic>> breakfastItems = [];
//   List<Map<String, dynamic>> lunchItems = [];
//   List<Map<String, dynamic>> dinnerItems = [];
//   List<Map<String, dynamic>> snackItems = [];
//
//   void uploadMenu() {
//     FirebaseFirestore.instance.collection('menu').doc('today').set({
//       'breakfast': {
//         'items': breakfastItems,
//       },
//       'lunch': {
//         'items': lunchItems,
//       },
//       'dinner': {
//         'items': dinnerItems,
//       },
//       'snack': {
//         'items': snackItems,
//       },
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//      const SnackBar(content: Text("Menu uploaded!")),
//     );
//   }
//
//   Future<void> navigateToMeal(String meal) async {
//     List<Map<String, dynamic>> currentItems;
//
//     switch (meal) {
//       case 'Breakfast':
//         currentItems = breakfastItems;
//         break;
//       case 'Lunch':
//         currentItems = lunchItems;
//         break;
//       case 'Snack':
//         currentItems = snackItems;
//         break;
//       case 'Dinner':
//         currentItems = dinnerItems;
//         break;
//       default:
//         currentItems = [];
//     }
//
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => MealInputScreen(
//           mealType: meal,
//           initialItems: currentItems,
//         ),
//       ),
//     );
//
//     if (result != null && result is List<Map<String, dynamic>>) {
//       setState(() {
//         switch (meal) {
//           case 'Breakfast':
//             breakfastItems = result;
//             break;
//           case 'Lunch':
//             lunchItems = result;
//             break;
//           case 'Snack':
//             snackItems = result;
//             break;
//           case 'Dinner':
//             dinnerItems = result;
//             break;
//         }
//       });
//     }
//   }
//
//   Widget buildMealTile(String title, IconData icon) {
//     return InkWell(
//       onTap: () => navigateToMeal(title),
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 8),
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 24),
//             const SizedBox(width: 16),
//             Text(title, style: const TextStyle(fontSize: 20)),
//             const Spacer(),
//             const Icon(Icons.chevron_right),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Upload Menu"), actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("Cancel", style: TextStyle(color: Colors.white)),
//         ),
//       ]),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             buildMealTile('Breakfast', Icons.local_cafe_outlined),
//             buildMealTile('Lunch', Icons.wb_sunny_outlined),
//             buildMealTile('Snack', Icons.fastfood),
//             buildMealTile('Dinner', Icons.nightlight_round_outlined),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: uploadMenu,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.amber[500],
//                 minimumSize: const Size(double.infinity, 48),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text("Upload Menu",
//                   style: TextStyle(color: Colors.black, fontSize: 18)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> uploadMenu() async {
    try {
      // Upload to Firestore
      await FirebaseFirestore.instance.collection('menu').doc('today').set({
        'breakfast': {'items': breakfastItems},
        'lunch': {'items': lunchItems},
        'dinner': {'items': dinnerItems},
        'snack': {'items': snackItems},
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Call your backend to trigger push notification
      final url = Uri.parse("http://192.168.31.163:3000/notify-menu-upload"); // 👈 update this
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"day": "today"}), // optional, can be dynamic like get current weekday
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

    switch (meal) {
      case 'Breakfast':
        currentItems = breakfastItems;
        break;
      case 'Lunch':
        currentItems = lunchItems;
        break;
      case 'Snack':
        currentItems = snackItems;
        break;
      case 'Dinner':
        currentItems = dinnerItems;
        break;
      default:
        currentItems = [];
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealInputScreen(
          mealType: meal,
          initialItems: currentItems,
        ),
      ),
    );

    if (result != null && result is List<Map<String, dynamic>>) {
      setState(() {
        switch (meal) {
          case 'Breakfast':
            breakfastItems = result;
            break;
          case 'Lunch':
            lunchItems = result;
            break;
          case 'Snack':
            snackItems = result;
            break;
          case 'Dinner':
            dinnerItems = result;
            break;
        }
      });
    }
  }

  Widget buildMealTile(String title, IconData icon) {
    return InkWell(
      onTap: () => navigateToMeal(title),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 20)),
            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Menu"), actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildMealTile('Breakfast', Icons.local_cafe_outlined),
            buildMealTile('Lunch', Icons.wb_sunny_outlined),
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
                  style: TextStyle(color: Colors.black, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
