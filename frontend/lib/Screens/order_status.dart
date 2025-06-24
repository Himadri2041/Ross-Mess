import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderStatusListener extends StatefulWidget {
  const OrderStatusListener({Key? key}) : super(key: key);

  @override
  State<OrderStatusListener> createState() => _OrderStatusListenerState();
}

class _OrderStatusListenerState extends State<OrderStatusListener> {
  late Stream<QuerySnapshot> _ordersStream;

  @override
  void initState() {
    super.initState();

    // Listen to orders that are 'ready'
    _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'ready')
    // You can filter by userId/email here
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _ordersStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final readyOrders = snapshot.data!.docs;

        if (readyOrders.isEmpty) return const SizedBox.shrink();

        // Show a notification banner with count of ready orders
        return Container(
          color: Colors.green[300],
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You have ${readyOrders.length} order(s) ready!',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Optionally navigate to orders page
                },
                child: const Text(
                  'View',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
