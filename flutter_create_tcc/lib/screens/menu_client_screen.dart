import 'package:flutter/material.dart';
import 'package:flutter_create_tcc/screens/profile/profile_screen.dart';
import 'package:flutter_create_tcc/screens/orders_screen.dart';
import 'package:flutter_create_tcc/screens/search_screen.dart';

class MenuClientScreen extends StatefulWidget {
  const MenuClientScreen({super.key});

  @override
  State<MenuClientScreen> createState() => _MenuClientScreenState();
}

class _MenuClientScreenState extends State<MenuClientScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    Center(child: Text("Home - Produtos em destaque")), 
    SearchScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, 
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Buscar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Pedidos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}