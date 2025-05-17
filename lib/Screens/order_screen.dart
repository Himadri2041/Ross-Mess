// import 'package:flutter/material.dart';
// import '../Appcolors.dart';
// import '../models/order_item.dart';
// import '../widgets/order_card.dart';
// import 'bill_screen.dart';
// import 'cart_screen.dart';
// import 'home_screen.dart';
//
// class OrderScreen extends StatelessWidget {
//   final List<OrderItem> orders = [
//     OrderItem(
//       title: 'Maggie',
//       price: 24.99,
//       image: 'Assets/images/maggie.png',
//     ),
//     OrderItem(
//       title: 'Friends Package',
//       price: 44.99,
//       image: 'Assets/images/maggie.png',
//     ),
//     OrderItem(
//       title: 'Community Package',
//       price: 74.99,
//       image: 'Assets/images/maggie.png',
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Order Food Packages',style:TextStyle(color:Colors.white70)),
//         backgroundColor: MessColors.PrimaryColor
//       ),
//
//       backgroundColor: MessColors.Backcolor,
//       body: ListView.builder(
//         itemCount: orders.length,
//         itemBuilder: (context, index) => OrderCard(item: orders[index]),
//       ),
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../providers/cart_provider.dart';
// import 'cart_screen.dart';
// import 'home_screen.dart';
//
// class OrderScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final cart = Provider.of<CartProvider>(context, listen: false);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Order Food Packages'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('orderItems')
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) return Center(child: Text('Error loading data'));
//           if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
//
//           final docs = snapshot.data!.docs;
//
//           if (docs.isEmpty)
//             return Center(child: Text('No order items available'));
//
//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//
//               return Card(
//                 margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                 elevation: 4,
//                 child: Padding(
//                   padding: EdgeInsets.all(12),
//                   child: Row(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.asset(
//                           'Assets/images/${data['imageName']}',
//                           width: 80,
//                           height: 80,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       SizedBox(width: 20),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               data['title'] ?? 'No Title',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               '\$${(data['price'] ?? 0).toStringAsFixed(2)}',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey[700],
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           // Add your add-to-cart logic here
//                         },
//                         style: ElevatedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           backgroundColor: Colors.blue,
//                         ),
//                         child: Text('Add', style: TextStyle(color: Colors.white)),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.red,
//         selectedItemColor: Colors.blue,
//         items:  [
//           BottomNavigationBarItem(
//             icon: IconButton(icon:Icon(Icons.home), onPressed: () {
//               Navigator.push(context,MaterialPageRoute(builder:(context)=>HomeScreen()  ));
//             },),
//             label: "Home",
//
//           ),
//           BottomNavigationBarItem(
//             icon: IconButton(icon:Icon(Icons.list_alt), onPressed: () {
//               Navigator.push(context,MaterialPageRoute(builder:(context)=>OrderScreen()  ));
//             },),
//             label: "Orders",
//           ),
//           BottomNavigationBarItem(
//             icon: IconButton(icon:Icon(Icons.shopping_cart), onPressed: () {
//               Navigator.push(context,MaterialPageRoute(builder:(context)=>CartScreen()  ));
//             },),
//             label: "Cart",
//           ),
//           BottomNavigationBarItem(
//             icon: IconButton(icon:Icon(Icons.payment), onPressed: () {
//               Navigator.push(context,MaterialPageRoute(builder:(context)=>HomeScreen()  ));
//             },),
//             label: "Bill",
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/order_item.dart';
import '../widgets/order_card.dart';
import 'cart_screen.dart';
import 'home_screen.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Food Packages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orderItems')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading data'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No order items available'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final item = OrderItem(
                title: data['title'] ?? 'No Title',
                price: (data['price'] ?? 0).toDouble(),
                image: 'Assets/images/${data['imageName']}',
              );
              return OrderCard(item: item);
            },
          );
        },
      ),


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
