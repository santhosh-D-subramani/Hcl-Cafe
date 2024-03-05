import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hclcafe/models/cart_item_model.dart';

class ShopData extends StatefulWidget {
  const ShopData({
    super.key,
    required this.shopName,
    required this.itemName,
    required this.availability,
    required this.itemImage,
    required this.itemPrice,
    required this.freshness,
    required this.freshnessProbability,
  });

  final String shopName, itemName, availability, itemImage;
  final int freshness;
  final double freshnessProbability;
  final int itemPrice;

  @override
  State<ShopData> createState() => _ShopDataState();
}

class _ShopDataState extends State<ShopData> {
  int count = 0;
  int price = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    void incrementCounter() {
      price = widget.itemPrice;
      setState(() {
        count++;
        price = count * price;
      });
    }

    String formatDouble(double value) {
      String stringValue = value.toString();

      // Find the index of the first non-zero digit
      int nonZeroIndex = stringValue.indexOf(RegExp('[1-9]'));

      // If non-zero digit is found, format the remaining digits
      if (nonZeroIndex != -1) {
        String formattedValue = stringValue.substring(nonZeroIndex);
        // Truncate to two decimal places
        if (formattedValue.length > 2) {
          formattedValue = formattedValue.substring(0, 2);
        }
        return formattedValue;
      }

      // If all digits are zero, return "0"
      return "0";
    }

    void decrementCounter() {
      price = widget.itemPrice;
      setState(() {
        count--;
        price = count * price;
      });
    }

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(widget.shopName),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 8),
                CachedNetworkImage(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  //fit: BoxFit.fill,
                  imageUrl: widget.itemImage,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                const SizedBox(height: 8),
                Text('Freshness - ${widget.freshness != 8 ? formatDouble(widget.freshnessProbability) : 'NA'}% Fresh'),
                const SizedBox(height: 8),
                Text(
                  widget.itemName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    //    color: CupertinoColors.white
                  ),
                ),
                Text(
                  'Rs. $price',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    //    color: CupertinoColors.white
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: () {
                          if (count > 0) decrementCounter();
                        },
                        child: const Icon(
                          CupertinoIcons.minus,
                          size: 50,
                        )),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      '$count',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                        onTap: () {
                          if (count >= 0) incrementCounter();
                        },
                        child: const Icon(
                          CupertinoIcons.add,
                          size: 50,
                        )),
                  ],
                ),
                CupertinoButton.filled(
                    child: const Text('Add To Cart'),
                    onPressed: () async {
                      if (count != 0) {
                        cartProvider.addToCart(CartItem(widget.itemName, widget.itemPrice, count));
                        if (kDebugMode) {
                          print(price.toString());
                        }
                        Navigator.pop(context);
                      } else if (count == 0) {
                        if (kDebugMode) {
                          print('pick');
                        }
                      }
                    })
              ],
            ),
          ),
        );
      },
    );
  }
}
