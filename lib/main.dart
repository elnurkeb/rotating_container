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
    return MaterialApp(
      home: GyroscopeRotationWidget(),
    );
  }
}

class GyroscopeRotationWidget extends StatefulWidget {
  const GyroscopeRotationWidget({super.key});

  @override
  GyroscopeRotationWidgetState createState() => GyroscopeRotationWidgetState();
}

class GyroscopeRotationWidgetState extends State<GyroscopeRotationWidget> {
  double rotationX = 0;
  double rotationY = 0;

  double gyroX = 0;
  double gyroY = 0;

  final double alpha = 0.98;

  DateTime? lastGyroTimestamp;

  StreamSubscription<GyroscopeEvent>? gyroSub;
  StreamSubscription<AccelerometerEvent>? accelSub;

  @override
  void initState() {
    super.initState();

    gyroSub = gyroscopeEventStream().listen((event) {
      final now = DateTime.now();

      if (lastGyroTimestamp != null) {
        double dt =
            now.difference(lastGyroTimestamp!).inMilliseconds.toDouble() / 1000;

        gyroX += event.x * dt;
        gyroY -= event.y * dt;
      }
      lastGyroTimestamp = now;
    });

    accelSub = accelerometerEventStream().listen((event) {
      double accAngleX = atan2(event.y, event.z);
      double accAngleY =
          atan2(event.x, sqrt(event.y * event.y + event.z * event.z));

      rotationX = alpha * gyroX + (1 - alpha) * accAngleX;
      rotationY = alpha * gyroY + (1 - alpha) * accAngleY;

      rotationX = rotationX.clamp(-pi / 4, pi / 4);
      rotationY = rotationY.clamp(-pi / 4, pi / 4);

      setState(() {});
    });
  }

  @override
  void dispose() {
    gyroSub?.cancel();
    accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(rotationX)
            ..rotateY(rotationY),
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
