import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'package:flutter_create_tcc/screens/splash_screen.dart';
import 'package:flutter_create_tcc/screens/login_screen.dart';
import 'package:flutter_create_tcc/screens/registration_screen.dart';
import 'package:flutter_create_tcc/screens/menu_client_screen.dart';
import 'package:flutter_create_tcc/screens/orders_screen.dart';
import 'package:flutter_create_tcc/screens/search_screen.dart';
import 'package:flutter_create_tcc/screens/profile/notifications_screen.dart';
import 'package:flutter_create_tcc/screens/profile/account_data_screen.dart';
import 'package:flutter_create_tcc/screens/profile/payments_screen.dart';
import 'package:flutter_create_tcc/screens/profile/configuration_screen.dart';
import 'package:flutter_create_tcc/screens/profile/profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salmon Roe App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/menuClient': (context) => const MenuClientScreen(),
        '/clientProfile': (context) => const ProfileScreen(),
        '/clientOrders': (context) => const OrdersScreen(),
        '/search': (context) => const SearchScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/accountData': (context) => const AccountDataScreen(),
        '/payments': (context) => const PaymentsScreen(),
        '/configuration': (context) => const ConfigurationScreen(),
      },
    );
  }
}
