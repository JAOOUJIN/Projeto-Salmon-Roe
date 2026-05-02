import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'providers/address_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/notification_provider.dart';
import 'package:flutter_create_tcc/models/address_model.dart';
import 'package:flutter_create_tcc/screens/splash_screen.dart';
import 'package:flutter_create_tcc/screens/login/login_screen.dart';
import 'package:flutter_create_tcc/screens/login/registration_screen.dart';
import 'package:flutter_create_tcc/screens/login/forget_password_screen.dart';
import 'package:flutter_create_tcc/screens/login/verify_code_screen.dart';
import 'package:flutter_create_tcc/screens/home/menu_client_screen.dart';
import 'package:flutter_create_tcc/screens/home/home_screen.dart';
import 'package:flutter_create_tcc/screens/home/orders_screen.dart';
import 'package:flutter_create_tcc/screens/cart/pix_payment_screen.dart';
import 'package:flutter_create_tcc/screens/home/search_screen.dart';
import 'package:flutter_create_tcc/screens/profile/notifications_screen.dart';
import 'package:flutter_create_tcc/screens/profile/accountData/account_data_screen.dart';
import 'package:flutter_create_tcc/screens/profile/configuration/configuration_screen.dart';
import 'package:flutter_create_tcc/screens/profile/configuration/about_screen.dart';
import 'package:flutter_create_tcc/screens/profile/configuration/manage_notifications_screen.dart';
import 'package:flutter_create_tcc/screens/profile/profile_screen.dart';
import 'package:flutter_create_tcc/screens/profile/support_screen.dart';
import 'package:flutter_create_tcc/screens/profile/accountData/access_info_screen.dart';
import 'package:flutter_create_tcc/screens/profile/accountData/personal_info_screen.dart';
import 'package:flutter_create_tcc/screens/profile/address/address_screen.dart';
import 'package:flutter_create_tcc/screens/profile/address/add_address_screen.dart';
import 'package:flutter_create_tcc/screens/profile/address/edit_address_screen.dart';
import 'package:flutter_create_tcc/screens/cart/cart_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inicializa o Firebase para esse processo isolado
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Notificação em Background: ${message.data}");
}

// Ponto de entrada da aplicação
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(
          create: (_) => ProductProvider()..fetchProducts(),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
        primarySwatch: Colors.red,
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
        '/configuration': (context) => const ConfigurationScreen(),
        '/aboutVersion': (context) => const AboutVersionScreen(),
        '/manageNotifications': (context) => const ManageNotificationsScreen(),
        '/personalInfo': (context) => const PersonalInfoScreen(),
        '/accessInfo': (context) => const AccessInfoScreen(),
        '/forgetPassword': (context) => const ForgetPasswordScreen(),
        '/addresses': (context) => const AddressScreen(),
        '/addAddress': (context) => const AddAddressScreen(),
        '/editAddress': (context) => EditAddressScreen(
          address: ModalRoute.of(context)!.settings.arguments as AddressModel,
        ),
        '/support': (context) => const SupportScreen(),
        '/cart': (context) => const CartScreen(),
        '/pixPayment': (context) => const PixPaymentScreen(),
        '/verifyCode': (context) {
          final emailArgument =
              ModalRoute.of(context)!.settings.arguments as String;

          return VerifyCodeScreen(email: emailArgument);
        },
      },
    );
  }
}
