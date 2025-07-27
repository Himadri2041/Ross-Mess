import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReadyOrders extends StatelessWidget {
  const ReadyOrders({Key? key}) : super(key: key);

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('MMMM d, yyyy').format(timestamp.toDate());
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('h:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ready Orders',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),

        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userOrders')
            .where('status', isEqualTo: 'ready')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading ready orders.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;
          final now = DateTime.now();
          for (final order in orders) {
            final timestamp = order['timestamp'] as Timestamp?;
            if (timestamp != null) {
              final orderDate = timestamp.toDate();
              if (now.difference(orderDate).inDays >= 2) {
                FirebaseFirestore.instance.collection('userOrders').doc(order.id).delete();
              }
            }
          }
          orders.sort((a, b) {
            final t1 = a['timestamp'] as Timestamp?;
            final t2 = b['timestamp'] as Timestamp?;
            return (t2?.millisecondsSinceEpoch ?? 0)
                .compareTo(t1?.millisecondsSinceEpoch ?? 0);
          });

          if (orders.isEmpty) {
            return const Center(child: Text('No ready orders.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: orders.length,
            itemBuilder: (ctx, i) {
              final doc = orders[i];
              final data = doc.data() as Map<String, dynamic>;
              final items = data['items'] as List<dynamic>;
              final timestamp = data['timestamp'] as Timestamp?;
              final name = data['name'] ?? 'Unknown';
              final phone = data['phone'] ?? 'N/A';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      '${_formatDate(timestamp)} • ${_formatTime(timestamp)}',
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
                  const Divider(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
