import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'package:flutter_create_tcc/models/address_model.dart';
import 'package:flutter_create_tcc/screens/splash_screen.dart';
import 'package:flutter_create_tcc/screens/login/login_screen.dart';
import 'package:flutter_create_tcc/screens/login/registration_screen.dart';
import 'package:flutter_create_tcc/screens/home/menu_client_screen.dart';
import 'package:flutter_create_tcc/screens/home/home_screen.dart';
import 'package:flutter_create_tcc/screens/home/orders_screen.dart';
import 'package:flutter_create_tcc/screens/home/search_screen.dart';
import 'package:flutter_create_tcc/screens/profile/notifications_screen.dart';
import 'package:flutter_create_tcc/screens/profile/accountData/account_data_screen.dart';
import 'package:flutter_create_tcc/screens/profile/payments_screen.dart';
import 'package:flutter_create_tcc/screens/profile/configuration_screen.dart';
import 'package:flutter_create_tcc/screens/profile/profile_screen.dart';
import 'package:flutter_create_tcc/screens/profile/accountData/access_info_screen.dart';
import 'package:flutter_create_tcc/screens/profile/accountData/personal_info_screen.dart';
import 'package:flutter_create_tcc/screens/login/forget_password_screen.dart';
import 'package:flutter_create_tcc/screens/profile/address/address_screen.dart';
import 'package:flutter_create_tcc/screens/profile/address/add_address_screen.dart';
import 'package:flutter_create_tcc/screens/profile/address/edit_address_screen.dart';
import 'package:flutter_create_tcc/screens/cart/cart_screen.dart';


// Ponto de entrada da aplicação
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
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
        '/homeProducts': (context) => const HomeScreen(),
        '/clientProfile': (context) => const ProfileScreen(),
        '/clientOrders': (context) => const OrdersScreen(),
        '/search': (context) => const SearchScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/accountData': (context) => const AccountDataScreen(),
        '/payments': (context) => const PaymentsScreen(),
        '/configuration': (context) => const ConfigurationScreen(),
        '/personalInfo': (context) => const PersonalInfoScreen(),
        '/accessInfo': (context) => const AccessInfoScreen(),
        '/forgetPassword': (context) => const ForgetPasswordScreen(),
        '/addresses': (context) => const AddressScreen(),
        '/addAddress': (context) => const AddAddressScreen(),
        '/editAddress': (context) => EditAddressScreen(address: ModalRoute.of(context)!.settings.arguments as AddressModel),
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}
