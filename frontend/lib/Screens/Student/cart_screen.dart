import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Providers/cart_provider.dart';
import '../../Widgets/cart_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();

    if (data == null || !data.containsKey('name') || !data.containsKey('phone')) {
      throw Exception('User data incomplete');
    }

    return {
      'name': data['name'],
      'phone': data['phone'],
    };
  }

  Future<void> notifyAdmins(String userName) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.31.180:3000/notify-order-placed'), // Change this IP!
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userName': userName}),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Admins notified');
      } else {
        debugPrint('❌ Failed to notify admins: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
    }
  }

  void _placeOrder(BuildContext context, CartProvider cart) async {
    if (cart.items.isEmpty) return;

    try {
      final userInfo = await _getUserInfo();

      final orderData = {
        'timestamp': FieldValue.serverTimestamp(),
        'totalPrice': cart.totalPrice,
        'name': userInfo['name'],
        'phone': userInfo['phone'],
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'note': _noteController.text.trim(),
        'status': 'pending',
        'items': cart.items.values.map((item) => {
          'title': item.title,
          'price': item.price,
          'image': item.image,
          'quantity': item.quantity,
        }).toList(),
      };

      await FirebaseFirestore.instance.collection('userOrders').add(orderData);
      await notifyAdmins(userInfo['name']??'anonymous');

      cart.clearCart();
      _noteController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  void _confirmAndPlaceOrder(BuildContext context, CartProvider cart) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Order'),
        content: const Text('Are you sure you want to place this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[500]),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _placeOrder(context, cart);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        centerTitle: true,
        backgroundColor: Colors.amber[500],
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Cart is empty!'))
                : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items.values.toList()[index];
                return CartCard(item: item);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Add a note (optional)',
                    hintText: 'e.g., No onions, deliver by 8PM',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Total: ₹${cart.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _confirmAndPlaceOrder(context, cart),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.amber[500],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Proceed to Checkout',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
