import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'routine_channel',
          channelName: 'Routine Notifications',
          channelDescription: 'Notification for routine reminders',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: const Color(0xFF9D50DD),
        ),
      ],
      debug: true,
    );

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required int id,
    required DateTime scheduledTime,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'routine_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduledTime,
        preciseAlarm: true,
      ),
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'routine_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduledTime,
        preciseAlarm: true,
      ),
    );
  }

  /// 🆕 Schedule multiple reminders: 1hr, 30m, 10m, and exact time
  static Future<void> scheduleMultipleNotifications({
    required String title,
    required String body,
    required DateTime eventTime,
    required int baseId,
  }) async {
    final reminderTimes = [
      eventTime.subtract(const Duration(hours: 1)),
      eventTime.subtract(const Duration(minutes: 30)),
      eventTime.subtract(const Duration(minutes: 10)),
      eventTime,
    ];

    for (int i = 0; i < reminderTimes.length; i++) {
      final reminderTime = reminderTimes[i];
      if (reminderTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: baseId + i,
          title: title,
          body: body,
          scheduledTime: reminderTime,
        );
      }
    }
  }
}
