import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminOrders extends StatelessWidget {
  const AdminOrders({Key? key}) : super(key: key);

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('MMMM d, yyyy').format(timestamp.toDate());
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('h:mm a').format(timestamp.toDate());
  }

  Future<void> sendOrderDoneNotification(String userId, String name) async {

    final url = Uri.parse("http://192.168.31.163:3000/notify-order-ready");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "name": name}),
    );

    if (response.statusCode == 200) {
      debugPrint(" Notification sent to $name");
    } else {
      debugPrint(" Failed to send notification: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'View Order',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.black)),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userOrders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: orders.length,
            itemBuilder: (ctx, i) {
              final doc = orders[i];
              final data = doc.data() as Map<String, dynamic>;
              final items = data['items'] as List<dynamic>;
              final timestamp = data['timestamp'] as Timestamp?;
              final userId = data['userId'] ?? '';
              final name = data['name'] ?? 'Unknown';
              final phone = data['phone'] ?? 'N/A';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      '${_formatDate(timestamp)} • ${_formatTime(timestamp)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      'Name: $name  |  Phone: $phone',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...items.map((item) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              item['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Qty: ${item['quantity'] ?? 1}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${(item['price'] ?? 0) * (item['quantity'] ?? 1)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          if (userId == '') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User ID missing')),
                            );
                            return;
                          }

                          // 🔍 Get name from Firestore
                          final userDoc = await FirebaseFirestore.instance
                              .collection("users")
                              .doc(userId)
                              .get();
                          final actualName = userDoc.data()?['name'] ?? 'User';

                          // 🟡 Notify user
                          await sendOrderDoneNotification(userId, actualName);

                          // 🗑 Delete the order
                          await FirebaseFirestore.instance
                              .collection("userOrders")
                              .doc(doc.id)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Order marked done & $actualName notified'),
                            ),
                          );
                        } catch (e) {
                          debugPrint(" Error: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to complete order')),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Mark as Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[500],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
