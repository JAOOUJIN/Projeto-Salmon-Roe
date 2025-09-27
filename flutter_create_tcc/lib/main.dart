import 'package:flutter/material.dart';
import 'package:flutter_create_tcc/screens/profile_screen.dart';
import 'package:flutter_create_tcc/screens/splash_screen.dart';
import 'package:flutter_create_tcc/screens/login_screen.dart';
import 'package:flutter_create_tcc/screens/registration_screen.dart';
import 'package:flutter_create_tcc/screens/menu_client_screen.dart';
import 'package:flutter_create_tcc/screens/orders_screen.dart';
import 'package:flutter_create_tcc/screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salmon Roe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/menuClient': (context) => const MenuClientScreen(),
        '/clientProfile': (context) => const ProfileScreen(),
        '/clientOrders': (context) => const OrdersScreen(),
        '/search': (context) => const SearchScreen(),
      },
    );
  }
}
