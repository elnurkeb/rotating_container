import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:pi_storybook/services/Notification.service.dart';

class LiquidNotification extends StatefulWidget {
  const LiquidNotification({super.key});
  @override
  LiquidNotificationState createState() => LiquidNotificationState();
}

class LiquidNotificationState extends State<LiquidNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Offset> _containerHeightAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _containerHeightAnim = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    NotificationService.instance.currentNotification.addListener(() async {
      await _controller.forward();
    });
    NotificationService.instance.showNotification(
      CustomNotification(
        "notification title 1",
        "notification body 1",
        Icons.notifications,
      ),
    );
    NotificationService.instance.showNotification(
      CustomNotification(
        "notification title 2",
        "notification body 2",
        Icons.notifications,
      ),
    );
  }

  // Future<void> _playAnimation() async {
  //   await _controller.forward();
  //   await Future.delayed(const Duration(seconds: 1));
  //   await _controller.reverse();
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ValueListenableBuilder<List<CustomNotification>>(
      valueListenable: NotificationService.instance.currentNotification,
      builder: (context, value, _) {
        if (value.isEmpty) {
          return const SizedBox.shrink();
        }
        return Stack(
          children: [
            LiquidGlassLayer(
              settings: const LiquidGlassSettings(
                blur: 8,
                thickness: 30,
                lightAngle: 0.5,
                lightIntensity: 1,
                ambientStrength: 0.3,
                blend: 50,
                chromaticAberration: 0.8,
                //glassColor: Color.fromARGB(60, 255, 255, 255),
                glassColor: Color.fromARGB(11, 20, 20, 135),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -68,
                    left: screenWidth / 6,
                    child: LiquidGlass.inLayer(
                      shape: LiquidRoundedSuperellipse(
                        borderRadius: Radius.circular(20),
                      ),
                      child: SizedBox(width: screenWidth * 2 / 3, height: 100),
                    ),
                  ),

                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: value.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 35),
                    itemBuilder: (context, index) {
                      final notification = value[index];
                      return AnimatedBuilder(
                        animation: _containerHeightAnim,
                        builder: (context, child) {
                          return Padding(
                            padding: EdgeInsets.only(
                              //top: _containerHeightAnim.value.dy,
                              left: 40,
                              right: 40,
                            ),
                            child: Dismissible(
                              key: ValueKey(notification),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) {
                                NotificationService.instance.removeNotification(
                                  notification,
                                );
                              },

                              // child: Positioned(
                              //   top: _containerHeightAnim.value,
                              //   left: 40,
                              //   right: 40,
                              child: LiquidGlass.inLayer(
                                shape: LiquidRoundedSuperellipse(
                                  borderRadius: Radius.circular(24),
                                ),
                                child: Container(
                                  height: 100,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        notification.icon,
                                        color: Colors.yellow,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        '${notification.title}\n${notification.body}',

                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
