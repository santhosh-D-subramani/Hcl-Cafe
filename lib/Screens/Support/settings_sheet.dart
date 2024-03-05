import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hclcafe/Screens/Support/help_sheet.dart';
import 'package:hclcafe/main.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class SettingSheet extends StatelessWidget {
  const SettingSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
        child: CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(leading: Text(''), middle: Text('Settings')),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Icon(
                    Icons.person,
                    size: 100,
                  ),
                  Text(
                    'User',
                    style: TextStyle(color: CupertinoColors.activeBlue),
                  ),
                ],
              ),
            ),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('Help'),
                  leading: const Icon(Icons.info),
                  onTap: () {
                    showCupertinoModalBottomSheet(
                      expand: true,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const ModalFit(),
                    );
                  },
                ),
                CupertinoListTile(
                  title: const Text('Log Out'),
                  leading: const Icon(Icons.do_disturb_on_outlined),
                  onTap: () async {
                    await _firebaseAuth.signOut().then((value) {
                      Navigator.pushAndRemoveUntil(
                          context, MaterialPageRoute(builder: (context) => const AuthSelector()), (route) => false);
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    ));
  }
}
