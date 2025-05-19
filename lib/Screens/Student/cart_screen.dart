// import 'package:flutter/material.dart';
// import '../Widgets/cart_card.dart';
// import '../models/order_item.dart';
// import '../widgets/order_card.dart';
//
// class CartScreen extends StatelessWidget {
//   final List<OrderItem> cartItems = [
//     OrderItem(title: 'Pizza Margarita', price: 12.00, image: 'Assets/images/maggie.png'),
//     OrderItem(title: 'Veggie Burger', price: 10.00, image: 'Assets/images/maggie.png'),
//     OrderItem(title: 'French Fries', price: 5.50, image: 'Assets/images/maggie.png'),
//   ];
//
//   CartScreen({super.key});
//
//   double get totalPrice => cartItems.fold(0, (sum, item) => sum + item.price);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Cart'),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: cartItems.length,
//               itemBuilder: (context, index) => CartCard(item: cartItems[index]),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Text(
//                   'Total: \$${totalPrice.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.right,
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Checkout logic here
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: Colors.blue[800],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     'Proceed to Checkout',
//                     style: TextStyle(fontSize: 16,color:Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../Providers/cart_provider.dart';
// import '../widgets/cart_card.dart';
//
// class CartScreen extends StatelessWidget {
//   const CartScreen({Key? key}) : super(key: key);
//
//   void _placeOrder(BuildContext context, CartProvider cart) async {
//     if (cart.items.isEmpty) return;
//
//     final orderData = {
//       'timestamp': FieldValue.serverTimestamp(),
//       'totalPrice': cart.totalPrice,
//       'items': cart.items.values.map((item) => {
//         'title': item.title,
//         'price': item.price,
//         'image': item.image,
//       }).toList(),
//     };
//
//     try {
//       await FirebaseFirestore.instance.collection('userOrders').add(orderData);
//
//       // Clear the cart
//       cart.clearCart();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Order placed successfully!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to place order: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cart = Provider.of<CartProvider>(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Cart'),
//       ),
//       body: cart.items.isEmpty
//           ? const Center(child: Text('Your cart is empty!'))
//           : Column(
//         children: [
//           Expanded(
//             child: Builder(
//               builder: (context) {
//                 final itemsList = cart.items.values.toList();
//                 return ListView.builder(
//                   itemCount: itemsList.length,
//                   itemBuilder: (ctx, i) {
//                     final item = itemsList[i];
//                     return CartCard(item: item);
//                   },
//                 );
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   offset: const Offset(0, -1),
//                   blurRadius: 6,
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Total:',
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                     Text(
//                       '\$${cart.totalPrice.toStringAsFixed(2)}',
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleLarge
//                           ?.copyWith(color: Colors.green[700]),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: () async {
//                     final confirm = await showDialog<bool>(
//                       context: context,
//                       builder: (ctx) => AlertDialog(
//                         title: const Text('Confirm Order'),
//                         content: const Text('Do you really want to place this order?'),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.of(ctx).pop(false),
//                             child: const Text('Cancel'),
//                           ),
//                           TextButton(
//                             onPressed: () => Navigator.of(ctx).pop(true),
//                             child: const Text('Confirm'),
//                           ),
//                         ],
//                       ),
//                     );
//
//                     if (confirm == true) {
//                       final cartProvider = Provider.of<CartProvider>(context, listen: false);
//                       final orderItems = cartProvider.items.values.toList();
//
//                       // Prepare order data
//                       final orderData = {
//                         'items': orderItems
//                             .map((item) => {
//                           'title': item.title,
//                           'price': item.price,
//                           'image': item.image,
//                         })
//                             .toList(),
//                         'totalPrice': cartProvider.totalPrice,
//                         'timestamp': DateTime.now(),
//                       };
//
//                       try {
//                         await FirebaseFirestore.instance.collection('userOrders').add(orderData);
//                         cartProvider.clearCart(); // Empty cart
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Order placed successfully!')),
//                         );
//                       } catch (e) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Error placing order: $e')),
//                         );
//                       }
//                     }
//                   },
//                   child: const Text('Place Order'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green[700],
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                 ),
//
//
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Appcolors.dart';
import '../../Providers/cart_provider.dart';
import '../../Widgets/cart_card.dart';
import '../order_status.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  void _placeOrder(BuildContext context, CartProvider cart) async {
    if (cart.items.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(

        title: const Text('Confirm Order'),
        content: const Text('Are you sure you want to place this order?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
               ),
        ],
      ),
    );

    if (confirm ?? false) {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'unknown';
      final timestamp = Timestamp.now();
      for (var item in cart.items.values) {
        await FirebaseFirestore.instance.collection('orders').add({
          'title': item.title,
          'price': item.price,
          'timestamp': timestamp,
          'status': 'pending',
          'userId': userId,
        });
      }

      cart.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MessColors.test,
        title: const Text('Your Cart',style: TextStyle(color: Colors.white,fontFamily:'Chakra_Petch',fontWeight: FontWeight.w900),),
      ),
      backgroundColor: MessColors.Back2color,
      body: cart.items.isEmpty
          ? const Center(
              child: OrderStatusListener(),
            )
          : Padding(
            padding: const EdgeInsets.fromLTRB(0,10,0,0),
            child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (ctx, i) {
                        final item = cart.items.values.toList()[i];
                        return CartCard(item: item);
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, -1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total',
                                style: Theme.of(context).textTheme.titleLarge),
                            Text(
                              '\₹${cart.totalPrice.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _placeOrder(context, cart),
                          icon: const Icon(Icons.send),
                          label: const Text('Place Order'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ),
    );
  }
}
