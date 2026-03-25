import 'dart:async';
import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:notiflex/services/icon_service.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService _instance =
      NotificationService._privateConstructor();
  factory NotificationService() {
    return _instance;
  }

  AppIcon? _lastAppIcon;
  final Uuid _uuid = const Uuid();
  final Map<int, AppIcon> _scheduledNotificationIcons = {};

  Future<void> initNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'scheduled_channel',
          channelName: 'Scheduled Notifications',
          channelDescription: 'Notification channel for scheduled alerts',
          importance: NotificationImportance.High,
        ),
      ],
    );

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  int generateUniqueNotificationId() {
    int randomId = Random().nextInt(10000);
    int timestamp = DateTime.now().minute;
    int uniqueId = timestamp + randomId;

    return uniqueId;
  }

  Future<void> cancelNotificationsWithDifferentIcon(AppIcon newIcon) async {
    List<int> notificationsToCancel = [];

    _scheduledNotificationIcons.forEach((id, icon) {
      if (icon != newIcon) {
        notificationsToCancel.add(id);
      }
    });

    for (int id in notificationsToCancel) {
      await AwesomeNotifications().cancel(id);
      _scheduledNotificationIcons.remove(id);
    }
  }

  Future<void> scheduleNotification({
    String? title,
    String? body,
    String? payLoad,
    String? image,
    DateTime? scheduledTime,
    Duration? interval,
    int? notificationCount,
    required AppIcon platform,
  }) async {
    int uniqueId = generateUniqueNotificationId();
    DateTime startTime = scheduledTime ?? DateTime.now();
    int count = notificationCount ?? 1;
    Duration repeatInterval = interval ?? const Duration(milliseconds: 1);

    _scheduledNotificationIcons[uniqueId] = platform;

    await cancelNotificationsWithDifferentIcon(platform);
    await _checkAndUpdateAppIcon(platform);

    for (int i = 0; i < count; i++) {
      int notificationId = uniqueId + i;

      DateTime currentNotificationTime = startTime
          .add(Duration(milliseconds: repeatInterval.inMilliseconds * i));

      if (currentNotificationTime
          .isBefore(DateTime.now().add(const Duration(seconds: 1)))) {
        currentNotificationTime =
            DateTime.now().add(const Duration(seconds: 1));
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'scheduled_channel',
          title: title ?? 'Instant Notification',
          body: body ?? 'Testing without schedule...',
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture: 'file://$image',
        ),
        schedule: NotificationCalendar.fromDate(date: currentNotificationTime),
        actionButtons: [
          platform == AppIcon.whatsapp || platform == AppIcon.ig
              ? NotificationActionButton(
                  key: 'reply',
                  label: 'Reply',
                  requireInputText: true,
                )
              : NotificationActionButton(
                  key: 'dismiss',
                  label: 'Dismiss',
                  actionType: ActionType.DismissAction,
                ),
        ],
      );

      _scheduledNotificationIcons[notificationId] = platform;
    }
  }

  Future<void> _checkAndUpdateAppIcon(AppIcon newIcon) async {
    if (_lastAppIcon != newIcon) {
      await IconService.changeAppIcon(newIcon);
      _lastAppIcon = newIcon;
    }
  }

  Future<void> showCallkitIncoming({
    required AppIcon newIcon,
    required String title,
    required String body,
  }) async {
    if (_lastAppIcon != newIcon) {
      await IconService.changeAppIcon(newIcon);
      _lastAppIcon = newIcon;
    }
    final params = CallKitParams(
      id: _uuid.v4(),
      nameCaller: title,
      appName: 'Local Call',
      handle: '123456789',
      type: 1,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: true,
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }
}
