import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'signin.dart';
import 'home.dart';
import 'user_provider.dart';
import 'utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp _ = await Firebase.initializeApp();
  runApp(Betty());
}

class Betty extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Betty> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>(create: (context) {
            User? user = FirebaseAuth.instance.currentUser;
            UserProvider provider = UserProvider();
            if (user != null) {
              provider.getOrCreateUser(user);
            }
            return provider;
          }),
        ],
        child:MaterialApp(
            title: 'Betty',
            theme: ThemeData(
              primarySwatch: materialBlack,
            ),
            home: HomeScreen(),
            initialRoute: user == null ? '/login' : '/home',
            routes: <String, WidgetBuilder>{
              '/forgotpass': (context) => ForgotPasswordScreen(),
              '/signinpass': (context) => EmailSignin(),
              '/login': (context) => LoginModal(),
              '/home': (context) => HomeScreen()
            }
        )
    );
  }
}
