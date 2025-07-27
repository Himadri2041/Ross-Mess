
import 'package:flutter/material.dart';
import '../models/order_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int getQuantity(String title) {
    return _items[title]?.quantity ?? 0;
  }

  void addItem(OrderItem item) {
    if (_items.containsKey(item.title)) {
      _items[item.title]!.quantity++;
    } else {
      _items[item.title] = CartItem(
        title: item.title,
        price: item.price,
        image: item.image,
        quantity: 1,
      );
    }
    notifyListeners();
  }

  void increaseQuantity(String title) {
    if (_items.containsKey(title)) {
      _items[title]!.quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String title) {
    if (_items.containsKey(title) && _items[title]!.quantity > 1) {
      _items[title]!.quantity--;
      notifyListeners();
    } else {
      removeItem(title);
    }
  }

  void removeItem(String title) {
    _items.remove(title);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }
}

class CartItem extends OrderItem {
  int quantity;

  CartItem({
    required String title,
    required double price,
    required String image,
    this.quantity = 1,
  }) : super(title: title, price: price, image: image);
}
