// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../Providers/cart_provider.dart';
// import '../models/order_item.dart';
//
// class CartCard extends StatefulWidget {
//   final OrderItem item;
//
//   const CartCard({Key? key, required this.item}) : super(key: key);
//
//   @override
//   State<CartCard> createState() => _OrderCardState();
// }
//
// class _OrderCardState extends State<CartCard> {
//   int quantity = 1;
//
//   @override
//   Widget build(BuildContext context) {
//     final cart = Provider.of<CartProvider>(context);
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 4,
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.asset(
//                 widget.item.image,
//                 width: 60,
//                 height: 60,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.item.title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '\$${widget.item.price.toStringAsFixed(2)} usd',
//                     style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//                   ),
//                 ],
//               ),
//             ),
//             Row(
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     setState(() {
//                       if (quantity > 1) quantity--;
//                     });
//                   },
//                   icon: const Icon(Icons.remove),
//                   color: Colors.blue[700],
//                   splashRadius: 20,
//                 ),
//                 Text(
//                   '$quantity',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     setState(() {
//                       quantity++;
//                     });
//                   },
//                   icon: const Icon(Icons.add),
//                   color: Colors.blue[700],
//                   splashRadius: 20,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/cart_provider.dart';

class CartCard extends StatelessWidget {
  final CartItem item;

  const CartCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // ✅ Use Image.network instead of Image.asset
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 60),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    width: 80,
                    height: 80,
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
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => cart.decreaseQuantity(item.title),
                  icon: const Icon(Icons.remove),
                  color: Colors.green[700],
                  splashRadius: 20,
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  onPressed: () => cart.increaseQuantity(item.title),
                  icon: const Icon(Icons.add),
                  color: Colors.green[700],
                  splashRadius: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
