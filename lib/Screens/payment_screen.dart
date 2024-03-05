
import 'package:flutter/cupertino.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, required this.total});
final int total;
  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Payment Gateway'),),
        child: SafeArea(
          child: Column(
      children: [
          Text('Total $total'),

      ],
    ),
        ));
  }
}
