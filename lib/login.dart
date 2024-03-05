import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Screens/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.whatAuth});

  final String whatAuth;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController nameController = TextEditingController();

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.secondarySystemBackground,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text(
          widget.whatAuth,
          style: const TextStyle(fontSize: 20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            widget.whatAuth == 'Sign Up' ? const SignUpWidget() : const LoginWidget(),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.1,
              child: CupertinoButton.filled(
                  child: Text(widget.whatAuth == 'Sign Up' ? 'Sign Up' : 'Login'),
                  onPressed: () async {
                    try {
                      final userCredential = widget.whatAuth == 'Sign Up'
                          ? await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            )
                          : await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(userCredential.user!.uid);

                      if (widget.whatAuth == 'Sign Up') {
                        Map<String, dynamic> userData = {
                          'name': nameController.text.toString(),
                          'email': emailController.text.toString(),
                          'uid': userCredential.user!.uid,
                        };
                        userRef.set(userData);
                      }
                      if (userCredential.user != null) {
                        // Login successful, navigate to the home page
                        if (context.mounted) {
                          if (kDebugMode) {
                            //print(adminBoolProvider.isAdmin);
                          }
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const MyHomePage(),
                          ));
                        }
                      }
                    } catch (e) {
                      // Handle login errors
                      if (kDebugMode) {
                        print('Error: $e');
                      }
                    }
                  }),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoFormSection.insetGrouped(header: Container(), children: [
        CupertinoTextField.borderless(
          autofocus: true,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          controller: emailController,
          padding: const EdgeInsets.all(8.0),
          prefix: const Text('  Email :'),
        ),
        CupertinoTextField.borderless(
          textInputAction: TextInputAction.go,
          padding: const EdgeInsets.all(8.0),
          controller: passwordController,
          prefix: const Text('  Password : '),
          obscureText: true,
        ),
      ]),
    );
  }
}

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoFormSection.insetGrouped(header: Container(), children: [
        CupertinoTextField.borderless(
          autofocus: true,
          controller: nameController,
          padding: const EdgeInsets.all(8.0),
          prefix: const Text('  Name :'),
        ),
        CupertinoTextField.borderless(
          controller: emailController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          padding: const EdgeInsets.all(8.0),
          prefix: const Text('  Email :'),
        ),
        CupertinoTextField.borderless(
          padding: const EdgeInsets.all(8.0),
          controller: passwordController,
          prefix: const Text('  Password : '),
          obscureText: true,
        ),
      ]),
    );
  }
}
