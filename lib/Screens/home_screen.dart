import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hclcafe/Screens/Support/settings_sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../models/cart_item_model.dart';
import '../models/item_model.dart';
import 'Support/help_sheet.dart';
import 'cart_screen.dart';
import 'item_details_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool kweb() {
    return kIsWeb;
  }

  String title = 'HCL Cafe';

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

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return CupertinoPageScaffold(
            child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              leading: GestureDetector(
                  onTap: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => const CartScreen()));
                  },
                  child: const Icon(CupertinoIcons.cart)),
              trailing: GestureDetector(
                  onTap: () {
                    showCupertinoModalBottomSheet(
                      expand: true,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const SettingSheet(),
                    );
                  },
                  child: const Icon(CupertinoIcons.settings)),
              middle: Text(title),
              largeTitle: Text(title),
              stretch: true,
              alwaysShowMiddle: false,
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              fillOverscroll: true,
              child: StreamBuilder(
                  stream: FirebaseDatabase.instance.ref().child("shops").onValue,
                  builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
                    List<ItemModel> items = [];

                    if (snapshot.hasData) {
                      Map<dynamic, dynamic> map =
                          (snapshot.data?.snapshot.value as Map<dynamic, dynamic>).cast<String, dynamic>();

                      items.clear();

                      map.forEach((dynamic, v) => items.add(ItemModel(v["shop_name"], v["shop_availability"], v["item_name"],
                          v["item_price"], v["shop_image"], v["freshness"], v["freshnessProbability"])));

                      return GridView.builder(
                        physics: const ScrollPhysics(parent: BouncingScrollPhysics()),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: w < 500
                                ? 2
                                : w < 800 && w > 500
                                    ? 3
                                    : 4),
                        itemCount: items.length,
                        padding: const EdgeInsets.all(2.0),
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => ShopData(
                                            shopName: items[index].shopName,
                                            itemName: items[index].itemName,
                                            availability: items[index].availability,
                                            itemImage: items[index].itemImage,
                                            itemPrice: items[index].itemPrice,
                                            freshness: items[index].freshness,
                                            freshnessProbability: items[index].freshnessProbability,
                                          )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: items[index].availability == 'true'
                                        ? CupertinoColors.activeGreen
                                        : CupertinoColors.lightBackgroundGray),
                                child: Column(
                                  children: [
                                    // Text(
                                    //   items[index].shopName,
                                    //   style: const TextStyle(
                                    //       fontSize: 20, fontWeight: FontWeight.w500, color: CupertinoColors.white),
                                    // ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: CachedNetworkImage(
                                            height: 300,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            imageUrl: items[index].itemImage,
                                            progressIndicatorBuilder: (context, url, downloadProgress) =>
                                                const CupertinoActivityIndicator(),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      items[index].itemName,
                                      style: const TextStyle(
                                          fontSize: 20, fontWeight: FontWeight.w500, color: CupertinoColors.white),
                                    ),
                                    Text(
                                      'Rs. ${items[index].itemPrice}',
                                      style: const TextStyle(
                                          fontSize: 20, fontWeight: FontWeight.w400, color: CupertinoColors.white),
                                    ),
                                    Text(
                                      '${items[index].freshness != 8 ? formatDouble(items[index].freshnessProbability) : 'NA'}% Fresh',
                                      style: const TextStyle(
                                          fontSize: 20, fontWeight: FontWeight.w500, color: CupertinoColors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: CupertinoActivityIndicator());
                    }
                  }),
            ),
          ],
        ));
      },
    );
  }
}
