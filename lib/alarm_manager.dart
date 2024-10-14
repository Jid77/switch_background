import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'service_manager.dart'; // Pastikan service_manager diimpor untuk pengelolaan switch

Future<void> checkAlarmCondition(double tk201, double tk202, double tk103,
    int boiler, int ofda, int oiless, DateTime timestamp) async {
  const double minRange = 65.0;
  const double maxRange = 80.0;
  final alarmBox = Hive.box('alarmHistoryBox');

  // Load kondisi switch untuk setiap sensor
  bool isTk201Active = await ServiceManager.loadSwitchState(0);
  bool isTk202Active = await ServiceManager.loadSwitchState(1);
  bool isTk103Active = await ServiceManager.loadSwitchState(2);
  bool isBoilerActive = await ServiceManager.loadSwitchState(3);
  bool isOfdaActive = await ServiceManager.loadSwitchState(4);
  bool isOilessActive = await ServiceManager.loadSwitchState(5);

  // Cek tk201 jika switch aktif
  if (isTk201Active && (tk201 < minRange || tk201 > maxRange)) {
    await sendAlarmNotification("Warning: tk201 out of range: $tk201");
    alarmBox.add({
      'timestamp': DateTime.now(),
      'alarmName': 'tk201',
      'sensorValue': tk201
    });
  }

  // Cek tk202 jika switch aktif
  if (isTk202Active && (tk202 < minRange || tk202 > maxRange)) {
    await sendAlarmNotification("Warning: tk202 out of range: $tk202");
    alarmBox.add({
      'timestamp': DateTime.now(),
      'alarmName': 'tk202',
      'sensorValue': tk202
    });
  }

  // Cek tk103 jika switch aktif
  if (isTk103Active && (tk103 < minRange || tk103 > maxRange)) {
    await sendAlarmNotification("Warning: tk103 out of range: $tk103");
    alarmBox.add({
      'timestamp': DateTime.now(),
      'alarmName': 'tk103',
      'sensorValue': tk103
    });
  }

  // Cek kondisi Boiler jika switch aktif
  if (isBoilerActive && boiler == 0) {
    await sendAlarmNotification("Warning: Boiler System Abnormal");
    alarmBox.add({
      'timestamp': DateTime.now(),
      'alarmName': 'boiler',
      'sensorValue': boiler
    });
  }

  // Cek kondisi OFDA jika switch aktif
  if (isOfdaActive && ofda == 0) {
    await sendAlarmNotification("Warning: OFDA System Abnormal");
    alarmBox.add({
      'timestamp': DateTime.now(),
      'alarmName': 'ofda',
      'sensorValue': ofda
    });
  }

  // Cek kondisi Oiless jika switch aktif
  if (isOilessActive && oiless == 0) {
    await sendAlarmNotification("Warning: Oiless System Abnormal");
    alarmBox.add({
      'timestamp': DateTime.now(),
      'alarmName': 'oiless',
      'sensorValue': oiless
    });
  }
}

Future<void> sendAlarmNotification(String message) async {
  print("Sending alarm notification: $message");
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'alarm_channel', // ID unik untuk channel
    'Sensor Alarm', // Nama channel
    channelDescription: 'Alarm when sensor data is out of range',
    importance: Importance.max,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('classicalarm'),
    ticker: 'Sensor Alarm',
    playSound: true,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Menampilkan notifikasi
  await flutterLocalNotificationsPlugin.show(
    0, // ID notifikasi
    'Sensor Alarm', // Judul notifikasi
    message, // Pesan notifikasi
    platformChannelSpecifics,
    // payload: 'Sensor Alarm Payload', // Payload tambahan (opsional)
  );
}
