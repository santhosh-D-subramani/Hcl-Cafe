
import 'package:flutter/cupertino.dart';

class CartItem {
  final String foodName;
   int price;
  int count;

  CartItem(this.foodName, this.price, this.count);

  Map<String, dynamic> toJson() => {
    'foodName': foodName,
    'price':price,
    'count': count,
  };
}

class CartProvider extends ChangeNotifier {
  List<CartItem> cartItems = [];


  void addToCart(CartItem item) {
    cartItems.add(item);
    notifyListeners();
  }
  int calculateTotalPrice() {
    int total = 0;
    for (var item in cartItems) {
      total += item.price * item.count;
    }
    return total;
  }
  void removeFromCart(CartItem item) {
    cartItems.remove(item);
    notifyListeners();
  }
}


