import 'package:flutter/material.dart';
import 'package:flutter_create_tcc/screens/profile/profile_screen.dart';
import 'package:flutter_create_tcc/screens/orders_screen.dart';
import 'package:flutter_create_tcc/screens/search_screen.dart';
import 'package:flutter_create_tcc/screens/profile/address/address_screen.dart';

class MenuClientScreen extends StatefulWidget {
  const MenuClientScreen({super.key});

  @override
  State<MenuClientScreen> createState() => _MenuClientScreenState();
}

class _MenuClientScreenState extends State<MenuClientScreen> {
  int _selectedIndex = 0;
  String currentAddress = "Selecione um endereço";

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

  Future<void> _openAddressScreen() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: const AddressScreen(),
        ),
      ),
    );

    if (result != null) {
      final street = result["street"] ?? "";
      final number = result["number"] ?? "";
      setState(() {
        currentAddress = "$street, $number";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHomeScreen = _selectedIndex == 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: isHomeScreen
            ? GestureDetector(
                onTap: _openAddressScreen,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        currentAddress,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                  ],
                ),
              )
            : const SizedBox(),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
