import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EventProvider with ChangeNotifier {
  final List<Event> _events = [];
  final Uuid _uuid = const Uuid();

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  List<Event> get events => [..._events];

  Future<void> loadEventsFromStorage() async {
    final box = Hive.box<Event>('events');
    _events.clear();
    _events.addAll(box.values);
    notifyListeners();

    if (_notificationsEnabled) {
      for (final event in _events) {
        if (event.isNotificationOn) {
          _scheduleAllEventNotifications(event);
        }
      }
    }
  }

  void toggleGlobalNotifications(bool isEnabled) {
    _notificationsEnabled = isEnabled;
    notifyListeners();

    for (final event in _events) {
      if (isEnabled && event.isNotificationOn) {
        _scheduleAllEventNotifications(event);
      } else {
        _cancelAllEventNotifications(event);
      }
    }
  }

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
    Hive.box<Event>('events').put(newEvent.id, newEvent);
    notifyListeners();

    if (_notificationsEnabled && newEvent.isNotificationOn) {
      _scheduleAllEventNotifications(newEvent);
    }
  }

  void deleteEvent(String id) {
    final event = _events.firstWhere((e) => e.id == id);
    _cancelAllEventNotifications(event);
    _events.removeWhere((e) => e.id == id);
    Hive.box<Event>('events').delete(id);
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

      _cancelAllEventNotifications(oldEvent);

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
      Hive.box<Event>('events').put(id, updated);
      notifyListeners();

      if (_notificationsEnabled && updated.isNotificationOn) {
        _scheduleAllEventNotifications(updated);
      }
    }
  }

  void toggleNotification(String id, bool isOn) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index].isNotificationOn = isOn;
      Hive.box<Event>('events').put(_events[index].id, _events[index]);
      notifyListeners();

      if (_notificationsEnabled && isOn) {
        _scheduleAllEventNotifications(_events[index]);
      } else {
        _cancelAllEventNotifications(_events[index]);
      }
    }
  }

  void _scheduleAllEventNotifications(Event event) {
    final scheduledTimes = [
      event.startTime.subtract(const Duration(hours: 1)),
      event.startTime.subtract(const Duration(minutes: 30)),
      event.startTime.subtract(const Duration(minutes: 10)),
      event.startTime,
    ];

    for (int i = 0; i < scheduledTimes.length; i++) {
      if (scheduledTimes[i].isAfter(DateTime.now())) {
        NotificationService.scheduleNotification(
          id: event.hashCode + i,
          title: event.title,
          body: event.description,
          scheduledTime: scheduledTimes[i],
        );
      }
    }
  }

  void _cancelAllEventNotifications(Event event) {
    for (int i = 0; i < 4; i++) {
      AwesomeNotifications().cancel(event.hashCode + i);
    }
  }
}
