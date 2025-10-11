import 'package:flutter/material.dart';

class MenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const MenuOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          splashColor: Colors.orange.withAlpha((0.2 * 255).toInt()),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                // Ícone principal
                Icon(
                  icon,
                  color: const Color(0xFFFF7043), 
                  size: 24,
                ),
                const SizedBox(width: 20),

                // Título
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Ícone de seta
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        const Divider(
          height: 1,
          thickness: 0.5,
          color: Color(0xFFE0E0E0),
          indent: 60, 
        ),
      ],
    );
  }
}
