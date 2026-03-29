import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final ValueNotifier<CustomNotification?> currentNotification =
      ValueNotifier<CustomNotification?>(null);

  void showNotification(CustomNotification notification) {
    currentNotification.value = notification;
  }

  void removeNotification() {
    currentNotification.value = null;
  }
}

class CustomNotification {
  String uuid;
  String title;
  String body;

  IconData icon;

  CustomNotification(
      {required this.title, required this.body, required this.icon})
      : uuid = const Uuid().v4();
}
