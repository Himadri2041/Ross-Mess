import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../fonts.dart';

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
    final url = Uri.parse("https://ross-mess.onrender.com/notify-order-ready");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "name": name}),
    );

    if (response.statusCode == 200) {
      debugPrint("✅ Notification sent to $name");
    } else {
      debugPrint("❌ Failed to send notification: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pending Orders',
          style: AppFonts.title.copyWith(letterSpacing: 0.5),
        ),
        centerTitle: false,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userOrders')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          orders.sort((a, b) {
            final t1 = a['timestamp'] as Timestamp?;
            final t2 = b['timestamp'] as Timestamp?;
            return (t2?.millisecondsSinceEpoch ?? 0)
                .compareTo(t1?.millisecondsSinceEpoch ?? 0);
          });

          if (orders.isEmpty) {
            return const Center(child: Text('No pending orders.'));
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
                            child: Image.network(
                              item['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              },
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

                          final userDoc = await FirebaseFirestore.instance
                              .collection("users")
                              .doc(userId)
                              .get();
                          final userData = userDoc.data();
                          if (userData == null || !userData.containsKey('rollNo')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User roll number missing')),
                            );
                            return;
                          }

                          final actualName = userData['name'] ?? 'User';
                          final roll = userData['rollNo'].toString();

                          // ✅ Send notification
                          await sendOrderDoneNotification(userId, actualName);

                          // ✅ Update order status
                          await FirebaseFirestore.instance
                              .collection("userOrders")
                              .doc(doc.id)
                              .update({'status': 'ready'});

                          // ✅ Prepare extrasData only
                          final extrasData = items.map((item) => {
                            'item': item['title'],
                            'price': item['price'],
                            'quantity': item['quantity'],
                          }).toList();

                          // ✅ Prepare date docId
                          final today = DateTime.now();
                          final docId =
                              "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

                          // ✅ Update attendance by adding only extras
                          await FirebaseFirestore.instance
                              .collection('attendance')
                              .doc(docId)
                              .set({
                            roll: {'extras': extrasData},
                          }, SetOptions(merge: true));

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Order marked ready, $actualName notified & bill added'),
                            ),
                          );
                        } catch (e) {
                          debugPrint("❌ Error: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to mark order as ready')),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Mark as Ready'),
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
