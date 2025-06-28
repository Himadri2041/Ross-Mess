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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Providers/cart_provider.dart';
import '../../Widgets/cart_card.dart';
import '../../models/order_item.dart';
import '../../Appcolors.dart';
import 'cart_screen.dart';
import 'home_screen.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  void addToCart(BuildContext context, Map<String, dynamic> data) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      final item = OrderItem(
        title: data['title'],
        price: (data['price'] ?? 0).toDouble(),
        image: data['imageUrl'],
      );

      await FirebaseFirestore.instance.collection('cart').add({
        'title': item.title,
        'price': item.price,
        'imageUrl': data['imageUrl'],
        'quantity': 1,
        'timestamp': Timestamp.now(),

      });

      cartProvider.addItem(item);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.title} added to cart'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding item to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[500],
        title: const Text(
          'Order Food',
          style: TextStyle(
              fontSize: 25,fontWeight:FontWeight.w700
          ),
        ),
        elevation: 4,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
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

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        data['imageUrl'] ?? '',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 90),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return SizedBox(
                            width: 90,
                            height: 90,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '₹${(data['price'] ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),


                        ],
                      ),
                    ),


                        IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.amber, size: 30),
                      onPressed: () => addToCart(context, {
                        'title': data['title'],
                        'price': data['price'],
                        'imageUrl': data['imageUrl'],
                      }),
                    )

                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(2),
              child: IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                },
              ),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.list_alt),
                onPressed: () {},
              ),
            ),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(2),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
            ),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(2),
              child: IconButton(
                icon: const Icon(Icons.receipt_long),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
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
