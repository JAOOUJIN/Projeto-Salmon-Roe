import 'package:flutter/material.dart';
import '../../../screens/profile/notifications_screen.dart';

class NotificationIcon extends StatefulWidget {
  final int notificationCount;

  const NotificationIcon({
    super.key,
    this.notificationCount = 0, 
  });

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  void _onTap() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        _onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.notifications_none,
                color: Colors.black,
                size: 28,
              ),
            ),
            if (widget.notificationCount > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    widget.notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
