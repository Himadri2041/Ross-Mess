import 'package:flutter/material.dart';
import 'package:ross_mess_app/Appcolors.dart';
import '../Providers/cart_provider.dart';
import '../models/order_item.dart';
import 'package:provider/provider.dart';
class OrderCard extends StatelessWidget {
  final OrderItem item;

  const OrderCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.image, // should be something like 'assets/images/biryani.png'
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 20),
            // Wrap text and price in Flexible to avoid overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\₹${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,

                    ),
                  ),

                ],

              ),
            ),
            ElevatedButton(
              onPressed: () {
                cart.addItem(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.title} added to cart')),
                );
              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor:MessColors.test

              ),
              child: const Text('Add',style: TextStyle(color:Colors.white,fontWeight: FontWeight.w600,fontSize:16)),
            ),

          ],
        ),
      ),
    );
  }
}
