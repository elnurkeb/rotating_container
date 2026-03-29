import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:rotating_container/notification_service.dart';

class LiquidNotification extends StatefulWidget {
  const LiquidNotification({super.key});
  @override
  LiquidNotificationState createState() => LiquidNotificationState();
}

class LiquidNotificationState extends State<LiquidNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _heightAnimation = Tween<double>(
      begin: -130,
      end: 100,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    NotificationService.instance.currentNotification.addListener(() async {
      final notification =
          NotificationService.instance.currentNotification.value;
      if (notification != null) {
        await _controller.forward();
        await Future.delayed(const Duration(seconds: 3));
        await _controller.reverse();
        NotificationService.instance.removeNotification();
      } else {
        await _controller.reverse();
      }
    });

    Future.delayed(Duration.zero, () {
      NotificationService.instance.showNotification(CustomNotification(
        title: 'Test Notification',
        body: 'This is a notification body.',
        icon: Icons.notifications,
      ));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ValueListenableBuilder<CustomNotification?>(
      valueListenable: NotificationService.instance.currentNotification,
      builder: (context, notification, _) {
        if (notification == null) {
          return const SizedBox.shrink();
        }

        return LiquidGlassLayer(
          settings: const LiquidGlassSettings(
            blur: 8,
            thickness: 30,
            lightAngle: 0.5,
            lightIntensity: 1,
            ambientStrength: 0.3,
            blend: 50,
            chromaticAberration: 0.8,
            glassColor: Color.fromARGB(11, 20, 20, 135),
          ),
          child: AnimatedBuilder(
            animation: _heightAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: 40,
                    right: 40,
                    top: -100,
                    child: LiquidGlass.inLayer(
                      shape: LiquidRoundedSuperellipse(
                        borderRadius: Radius.circular(24),
                      ),
                      child: SizedBox(
                        height: 100,
                        width: screenWidth / 3 * 2,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 40,
                    right: 40,
                    top: _heightAnimation.value,
                    child: LiquidGlass.inLayer(
                      shape: LiquidRoundedSuperellipse(
                        borderRadius: Radius.circular(24),
                      ),
                      child: Container(
                        height: 100,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        child: Row(
                          children: [
                            Icon(notification.icon, color: Colors.yellow),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                '${notification.title}\n${notification.body}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
