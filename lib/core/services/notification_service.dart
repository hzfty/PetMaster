import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart'; // Обновлённый импорт
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;

class NotificationService {
  // Singleton pattern
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  // Плагин для локальных уведомлений
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> init() async {
    // Инициализируем часовые пояса
    initializeTimeZones();
    tz.setLocalLocation(
        tz.getLocation('Europe/Moscow')); // Установите вашу временную зону

    // Настройки для Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Настройки для iOS
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // Общие настройки инициализации
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Инициализация плагина
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );
  }

  void onSelectNotification(NotificationResponse notificationResponse) async {
    // Обработка нажатия на уведомление
    print('Уведомление нажато: ${notificationResponse.payload}');
    // Здесь вы можете реализовать навигацию или другие действия
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    print('Планируем уведомление с ID $id на $scheduledDate');

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel_id', // Уникальный идентификатор канала
            'Default Channel', // Название канала
            channelDescription: 'Канал по умолчанию для уведомлений',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null, // Для точного времени
      );
      print('Уведомление запланировано');
    } catch (e) {
      print('Ошибка при планировании уведомления: $e');
    }
  }

  // Метод для повторного планирования уведомления
  Future<void> scheduleRepeatingNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
    Duration repeatInterval,
  ) async {
    print(
        'Планируем повторяющееся уведомление с ID $id начиная с $scheduledDate каждые $repeatInterval');

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'repeating_channel_id',
            'Repeating Notifications',
            channelDescription: 'Канал для повторяющихся уведомлений',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents
            .time, // Повторяется каждый день в указанное время
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // Устанавливаем интервал повторения
        payload:
            repeatInterval.inSeconds.toString(), // Передаём интервал в payload
      );
      print('Повторяющееся уведомление запланировано');
    } catch (e) {
      print('Ошибка при планировании повторяющегося уведомления: $e');
    }
  }

  // Метод для отмены уведомления
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print('Уведомление с ID $id отменено');
  }
}
