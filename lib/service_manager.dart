import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class ServiceManager {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: (_) => false,
      ),
    );

    service.startService();
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Background Service",
        content: "Running background tasks",
      );
    }

    // Check if any alarms were running before and restart them if needed
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 3; i++) {
      // Assuming we have 3 alarms (3 switches)
      bool isAlarmRunning = prefs.getBool('isAlarmRunning_$i') ?? false;
      if (isAlarmRunning) {
        _startAlarm(i);
      }
    }

    service.on('startAlarm').listen((event) {
      int index = event!['index'] as int;
      _startAlarm(index);
    });

    service.on('stopAlarm').listen((event) {
      int index = event!['index'] as int;
      _stopAlarm(index);
    });
  }

  static Future<void> _startAlarm(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'isAlarmRunning_$index', true); // Save alarm running status

    Timer.periodic(Duration(seconds: 10), (timer) async {
      bool isAlarmRunning = prefs.getBool('isAlarmRunning_$index') ?? false;
      if (isAlarmRunning) {
        _showNotification(index);
      } else {
        timer.cancel();
      }
    });
  }

  static Future<void> _stopAlarm(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'isAlarmRunning_$index', false); // Set alarm status to false
  }

  static Future<void> _showNotification(int index) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Alarm Notification',
      'Alarm ${index + 1} triggered!',
      platformChannelSpecifics,
    );
  }

  static Future<void> startAlarm(int index) async {
    FlutterBackgroundService().invoke("startAlarm", {"index": index});
  }

  static Future<void> stopAlarm(int index) async {
    FlutterBackgroundService().invoke("stopAlarm", {"index": index});
  }

  static Future<bool> loadSwitchState(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('switchState_$index') ?? false;
  }

  static Future<void> saveSwitchState(int index, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('switchState_$index', value);
  }
}
