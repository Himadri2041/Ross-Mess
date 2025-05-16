import 'package:flutter/material.dart';
import '../Appcolors.dart';
import '../models/order_item.dart';
import '../widgets/order_card.dart';
import 'bill_screen.dart';
import 'home_screen.dart';

class OrderScreen extends StatelessWidget {
  final List<OrderItem> orders = [
    OrderItem(
      title: 'Maggie',
      price: 24.99,
      image: 'Assets/images/maggie.png',
    ),
    OrderItem(
      title: 'Friends Package',
      price: 44.99,
      image: 'Assets/images/maggie.png',
    ),
    OrderItem(
      title: 'Community Package',
      price: 74.99,
      image: 'Assets/images/maggie.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Food Packages',style:TextStyle(color:Colors.white70)),
        backgroundColor: MessColors.PrimaryColor
      ),

      backgroundColor: MessColors.Backcolor,
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) => OrderCard(item: orders[index]),
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
