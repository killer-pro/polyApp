// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:new_app/login/login.dart';
import 'package:new_app/pages/home/home_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('fr', null);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr')], // Support de la locale française
      home: AuthHandler(),
    );
  }
}

class AuthHandler extends StatelessWidget {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              return LoginScreen();
            } else {
              return HomePage();
            }
          }
          return Scaffold(
            body: Center(child: AppLoader()),
          );
        });
  }
}
