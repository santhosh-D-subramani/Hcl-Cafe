import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter/services.dart';
import 'package:hclcafe/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'Screens/Support/help_sheet.dart';
import 'Screens/home_screen.dart';
import 'models/cart_item_model.dart';
import 'firebase_options.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => CartProvider()),
          ],
          child: const MyApp(),
        ),
      ));
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      if (kDebugMode) {
        print('User is currently signed out!');
      }
    } else {
      if (kDebugMode) {
        print('User is signed in!');
      }
    }
  });
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'HCL Cafe',
      //home: const MyHomePage(title: 'HCL Cafe'),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialWithModalsPageRoute(
                builder: (_) => user != null ? const MyHomePage() : const AuthSelector(), settings: settings);
        }
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: CupertinoScaffold(
              body: Builder(
                builder: (context) => CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    transitionBetweenRoutes: false,
                    middle: const Text('Normal Navigation'),
                    trailing: GestureDetector(
                      child: const Icon(Icons.arrow_upward),
                      onTap: () => CupertinoScaffold.showCupertinoModalBottomSheet(
                        expand: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Stack(
                          children: <Widget>[
                            const ModalFit(),
                            Positioned(
                              height: 40,
                              left: 40,
                              right: 40,
                              bottom: 20,
                              child: MaterialButton(
                                onPressed: () => Navigator.of(context).popUntil((route) => route.settings.name == '/'),
                                child: const Text('Pop back home'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: Center(
                    child: Container(),
                  ),
                ),
              ),
            ),
          ),
          settings: settings,
        );
      },
    );
  }
}

class AuthSelector extends StatelessWidget {
  const AuthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    print(MediaQuery.of(context).size.width);
    return CupertinoPageScaffold(
        child: Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width < 500 ? w : w / 2,
          child: ListView(
            //mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(
                height: 8,
              ),
              Image.asset(
                'images/logo.png',
                height: MediaQuery.of(context).size.height / 2,
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.1,
                child: CupertinoButton.filled(
                    child: const Text('Login'),
                    onPressed: () {
                      showCupertinoModalBottomSheet(
                        expand: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AuthScreen(
                          whatAuth: 'Login',
                        ),
                      );
                    }),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.1,
                child: CupertinoButton.filled(
                    child: const Text('Sign Up'),
                    onPressed: () {
                      showCupertinoModalBottomSheet(
                        expand: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AuthScreen(
                          whatAuth: 'Sign Up',
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
