import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hclcafe/Screens/payment_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:hclcafe/models/cart_item_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<String?> getUserName(String uid) async {
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child("Users").child(uid);

    try {
      // Use `once` to get a single database event
      DatabaseEvent databaseEvent = await databaseReference.once();

      // Access the 'snapshot' property to get the DataSnapshot
      DataSnapshot dataSnapshot = databaseEvent.snapshot;

      // Updated: dataSnapshot.value is now of type Object?
      Map<dynamic, dynamic>? userValues = dataSnapshot.value as Map<dynamic, dynamic>?;

      // Check if the user exists
      if (userValues == null) {
        return null;
      }

      // Access the 'name' field
      String? userName = userValues['name'];

      return userName;
    } catch (error) {
      print("Error fetching user data: $error");
      return null;
    }
  }

  void fetchUserName(uid) async {
    String? userName = await getUserName(uid);

    if (userName != null) {
      print("User's name: $userName");
    } else {
      print("User not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    var total = cartProvider.calculateTotalPrice();

    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Cart'),
        ),
        child: cartProvider.cartItems.isEmpty
            ? const SafeArea(child: Center(child: Text('No items in cart ')))
            : SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CupertinoListSection.insetGrouped(children: [
                        ...List.generate(cartProvider.cartItems.length, (index) {
                          final cartItem = cartProvider.cartItems[index];

                          return CupertinoListTile(
                            leading: Text('${cartItem.count} x'),
                            title: Text(cartItem.foodName),
                            trailing: Row(
                              children: [
                                Text('Rs. ${cartItem.price * cartItem.count}'),
                                const SizedBox(
                                  width: 8,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      cartProvider.removeFromCart(cartItem);
                                    },
                                    child: const Icon(
                                      CupertinoIcons.minus_circle,
                                      color: CupertinoColors.destructiveRed,
                                    )),
                              ],
                            ),
                          );
                        })
                      ]),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CupertinoButton.filled(
                            child: Text('Pay Rs.$total'),
                            onPressed: () async {
                              String jsonData = jsonEncode(cartProvider.cartItems.map((item) => item.toJson()).toList());
// Construct the reference path to the user's data
                              try {
                                User? user = FirebaseAuth.instance.currentUser;
                                if (user == null) {
                                  if (kDebugMode) {
                                    print('No user is currently authenticated');
                                  }
                                  return;
                                }

                                // Get the current date and time with seconds
                                DateTime now = DateTime.now();

                                // Format the date and time as a string (you can adjust the format as needed)
                                String orderTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

                                String uid = user.uid;
                                // var userData = FirebaseDatabase.instance.ref().child("Users").child(uid);
                                var name = await getUserName(uid);

                                DatabaseReference userRef = FirebaseDatabase.instance.ref().child('Orders');
                                DatabaseReference newRef = userRef.push();
                                String orderKey = newRef.key ?? "";
                                if (name != null) {
                                  Map<String, dynamic> orderData = {
                                    'delivered': false,
                                    'email': user.email,
                                    'name': name,
                                    "key": orderKey,
                                    'order_time': orderTime,
                                    'order_details': jsonData,
                                    'uid': uid,
                                  };
                                  // Push or update the JSON data under the 'order' field

                                  newRef.set(orderData).then((value) => Navigator.pop(context));
                                  if (kDebugMode) {
                                    print(orderData.toString());
                                  }

                                  if (kDebugMode) {
                                    print('Order data sent to Firebase under user $uid');
                                  }
                                }
                              } on Exception {}
                              //  print(jsonData);
                            }),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
