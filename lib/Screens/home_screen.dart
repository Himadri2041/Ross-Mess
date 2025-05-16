import 'package:flutter/material.dart';

import '../Appcolors.dart';
import '../Widgets/bottom_nav_bar.dart';
import 'order_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> todayMenu = [
    {
      "meal": "Breakfast",
      "time": "8:00 AM - 9:30 AM",
      "main": "Aloo Paratha & Pickle",

    },
    {
      "meal": "Lunch",
      "time": "12:00 PM - 2:00 PM",
      "main": "Arhar Dal · Aloo Bhurji ·  Gulab Jamun",

    },
    {
      "meal": "Evening Snacks",
      "time": "4:00 PM - 4:30 PM",
      "main": "Bread Roll/Samosa",
    },
    {
      "meal": "Dinner",
      "time": "4:00 PM - 4:30 PM",
      "main": "Bread Roll/Samosa",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mess Menu",style:TextStyle(color:Colors.white70)),
        backgroundColor: MessColors.PrimaryColor,
        centerTitle: false,
      ),
      backgroundColor: MessColors.Backcolor,
      body:
      ListView.builder(
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
                const SizedBox(height: 8),

                /// Regular Items


              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: MessColors.PrimaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
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
              Navigator.push(context,MaterialPageRoute(builder:(context)=>HomeScreen()  ));
            },),
            label: "Cart",
          ),
        ],
      ),

    );
  }
}

