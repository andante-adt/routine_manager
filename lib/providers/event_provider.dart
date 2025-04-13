import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class EventProvider with ChangeNotifier {
  final List<Event> _events = [];
  final Uuid _uuid = const Uuid();

  List<Event> get events => [..._events];

  void addEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String categoryId,
  }) {
    final newEvent = Event(
      id: _uuid.v4(),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      categoryId: categoryId,
    );

    _events.add(newEvent);
    notifyListeners();

    NotificationService.scheduleNotification(
      id: newEvent.hashCode,
      title: newEvent.title,
      body: newEvent.description,
      scheduledTime: newEvent.startTime,
    );
  }

  void deleteEvent(String id) {
    final event = _events.firstWhere((e) => e.id == id);
    AwesomeNotifications().cancel(event.hashCode);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void updateEvent({
    required String id,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String categoryId,
  }) {
    final index = _events.indexWhere((event) => event.id == id);
    if (index != -1) {
      final oldEvent = _events[index];

      // Cancel old notification
      AwesomeNotifications().cancel(oldEvent.hashCode);

      final updated = Event(
        id: id,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        categoryId: categoryId,
        isNotificationOn: oldEvent.isNotificationOn,
      );

      _events[index] = updated;
      notifyListeners();

      if (updated.isNotificationOn) {
        NotificationService.scheduleNotification(
          id: updated.hashCode,
          title: updated.title,
          body: updated.description,
          scheduledTime: updated.startTime,
        );
      }
    }
  }

  void toggleNotification(String id, bool isOn) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index].isNotificationOn = isOn;
      notifyListeners();

      if (isOn) {
        NotificationService.scheduleNotification(
          id: _events[index].hashCode,
          title: _events[index].title,
          body: _events[index].description,
          scheduledTime: _events[index].startTime,
        );
      } else {
        AwesomeNotifications().cancel(_events[index].hashCode);
      }
    }
  }
}
