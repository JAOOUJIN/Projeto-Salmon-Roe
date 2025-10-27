import 'package:flutter/material.dart';
import 'package:flutter_create_tcc/screens/profile/profile_screen.dart';
import 'package:flutter_create_tcc/screens/orders_screen.dart';
import 'package:flutter_create_tcc/screens/search_screen.dart';
import 'package:flutter_create_tcc/screens/home_screen.dart';

class MenuClientScreen extends StatefulWidget {
  const MenuClientScreen({super.key});

  @override
  State<MenuClientScreen> createState() => _MenuClientScreenState();
}

class _MenuClientScreenState extends State<MenuClientScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(), 
      const SearchScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Pedidos"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
