import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: RotatingContainer());
  }
}

class RotatingContainer extends StatefulWidget {
  const RotatingContainer({super.key});

  @override
  _RotatingContainerState createState() => _RotatingContainerState();
}

class _RotatingContainerState extends State<RotatingContainer>
    with SingleTickerProviderStateMixin {
  double rotationX = 0, goalRotationX = 0;
  double rotationY = 0, goalRotationY = 0;
  late AnimationController controller;

  StreamSubscription<GyroscopeEvent>? gyroSub;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this);
    controller.repeat(period: Duration(milliseconds: 16));

    DateTime? lastGyroTimestamp = DateTime.now();

    gyroSub = gyroscopeEventStream().listen((event) {
      final now = DateTime.now();
      // if (lastGyroTimestamp != null) {
      final dt = now.difference(lastGyroTimestamp!).inMilliseconds / 1000.0;
      goalRotationY += event.y * dt;
      goalRotationY = goalRotationY.clamp(-pi / 4, pi / 4);

      goalRotationX -= event.x * dt;
      goalRotationX = goalRotationX.clamp(-pi / 4, pi / 4);
      // }
      lastGyroTimestamp = now;
    });
  }

  @override
  void dispose() {
    gyroSub?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            rotationX = lerp(rotationX, goalRotationX, 0.1);
            rotationY = lerp(rotationY, goalRotationY, 0.1);

            goalRotationX = lerp(goalRotationX, 0, 0.04);
            goalRotationY = lerp(goalRotationY, 0, 0.04);
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(rotationX)
                ..rotateY(rotationY),
              child: child,
            );
          },
          child: Container(
            width: 250,
            height: 150,
            color: Colors.blue,
            child: Center(
              child: Text(
                "Rotating Container",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double lerp(double a, double b, double t) {
  return a + (b - a) * t;
}
