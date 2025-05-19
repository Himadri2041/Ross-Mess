import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Appcolors.dart';
import 'cart_screen.dart';
import 'order_screen.dart';
import '../Screens/order_status.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> todayMenu = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }
//fetch menu
  Future<void> fetchMenu() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('menu').doc('today').get();

      if (doc.exists) {
        final data = doc.data();

        setState(() {
          todayMenu = [
            {
              'meal': 'Breakfast',
              'time': '8:00 AM - 9:30 AM',
              'main': data?['breakfast'] ?? 'Not available',
            },
            {
              'meal': 'Lunch',
              'time': '12:00 PM - 2:00 PM',
              'main': data?['lunch'] ?? 'Not available',
            },
            {
              'meal': 'Dinner',
              'time': '8:00 PM - 9:30 PM',
              'main': data?['dinner'] ?? 'Not available',
            },
          ];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching menu: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
//menu display
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mess Menu", style: TextStyle(color: Colors.white70)),
        backgroundColor: MessColors.PrimaryColor,
        centerTitle: false,
      ),
      backgroundColor: MessColors.Backcolor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : todayMenu.isEmpty
          ? const Center(child: Text("No menu available for today."))
          : ListView.builder(
        itemCount: todayMenu.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final meal = todayMenu[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Meal Header

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      meal['meal'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '(${meal['time']})',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                /// Main Items
                Text(
                  meal['main'],
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          );
        },
      ),
      //bottomnavbar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        selectedItemColor: Colors.blue,
        items:  [
          BottomNavigationBarItem(
            icon: IconButton(icon:Icon(Icons.home), onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder:(context)=>HomeScreen()  ));
            },),
            label: "Home",

          ),
          BottomNavigationBarItem(
            icon: IconButton(icon:Icon(Icons.list_alt), onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder:(context)=>OrderScreen()  ));
            },),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: IconButton(icon:Icon(Icons.shopping_cart), onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder:(context)=>CartScreen()  ));
            },),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: IconButton(icon:Icon(Icons.payment), onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder:(context)=>HomeScreen()  ));
            },),
            label: "Bill",
          ),
        ],
      ),
    );
  }
}
