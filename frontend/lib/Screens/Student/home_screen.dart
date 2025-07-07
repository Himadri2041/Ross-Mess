import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ross_mess_app/Appcolors.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'cart_screen.dart';
import 'order_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> fullMenu = {};
  String selectedMeal = 'Lunch';
  bool isLoading = true;
  String userName = 'User';

  @override
  void initState() {
    super.initState();
    fetchMenu();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      });
    }
  }

  Future<void> fetchMenu() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('menu')
          .doc('today')
          .get();

      if (doc.exists) {
        final data = doc.data();

        List<Map<String, String>> parseItemMaps(dynamic raw) {
          if (raw == null) return [];
          if (raw is List) {
            return raw.map<Map<String, String>>((item) {
              if (item is Map) {
                return {
                  'name': (item['name'] ?? '').toString(),
                  'image': (item['image'] ?? '').toString(),
                };
              }
              return {'name': item.toString(), 'image': ''};
            }).toList();
          }
          return [];
        }

        setState(() {
          fullMenu = {
            'Breakfast': {
              'meal': 'Breakfast',
              'time': '8:00 AM - 9:30 AM',
              'items': parseItemMaps(data?['breakfast']?['items']),
            },
            'Lunch': {
              'meal': 'Lunch',
              'time': '12:00 PM - 2:45 PM',
              'items': parseItemMaps(data?['lunch']?['items']),
            },
            'Snack': {
              'meal': 'Snack',
              'time': '4:00 PM - 5:30 PM',
              'items': parseItemMaps(data?['snack']?['items']),
            },
            'Dinner': {
              'meal': 'Dinner',
              'time': '8:00 PM - 9:30 PM',
              'items': parseItemMaps(data?['dinner']?['items']),
            },
          };
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching menu: $e');
    }
  }

  IconData getMealIcon(String meal) {
    switch (meal) {
      case 'Breakfast':
        return LucideIcons.sunrise;
      case 'Lunch':
        return LucideIcons.sun;
      case 'Snack':
        return LucideIcons.cookie;
      case 'Dinner':
        return LucideIcons.moon;
      default:
        return LucideIcons.helpCircle;
    }
  }

  Widget buildMealGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: ['Breakfast', 'Lunch', 'Snack', 'Dinner'].map((meal) {
        final isSelected = selectedMeal == meal;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedMeal = meal;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? MessColors.test : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(getMealIcon(meal), size: 32, color: Colors.black87),
                SizedBox(height: 10),
                Text(meal, style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildSelectedMenuItems() {
    final List<Map<String, String>> items = fullMenu[selectedMeal]?['items'] ?? [];

    return items.isEmpty
        ? Center(child: Text('No items available'))
        : SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final name = item['name'] ?? '';
          final image = item['image'] ?? '';

          return Container(
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: image.isNotEmpty
                      ? Image.network(
                    image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 60),
                  )
                      : Icon(Icons.image_not_supported, size: 60),
                ),
                SizedBox(height: 8),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }



@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $userName ",style:const TextStyle(fontSize: 24,fontWeight:FontWeight.w700)),
        backgroundColor: MessColors.test,
        elevation: 2,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Menu",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    buildMealGrid(),
                    const SizedBox(height: 16),
                    Text("${selectedMeal} Items",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    buildSelectedMenuItems(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {},
              ),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.list_alt),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const OrderScreen()));
                },
              ),
            ),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
            ),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.receipt_long),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => HomeScreen()));
                },
              ),
            ),
            label: "Bill",
          ),
        ],
      ),
    );
  }
}
