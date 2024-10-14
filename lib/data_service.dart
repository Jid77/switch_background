import 'dart:async';
import 'package:hive/hive.dart';
import 'alarm_manager.dart'; // Impor alarm_manager untuk checkAlarmCondition
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Stream untuk boiler, oiless, dan ofda
  final StreamController<int> _boilerStreamController = StreamController<int>();
  final StreamController<int> _oilessStreamController = StreamController<int>();
  final StreamController<int> _ofdaStreamController = StreamController<int>();

  Stream<int> get boilerStream => _boilerStreamController.stream;
  Stream<int> get oilessStream => _oilessStreamController.stream;
  Stream<int> get ofdaStream => _ofdaStreamController.stream;

  Future<void> fetchData(
    int index,
    List<FlSpot> tk201Data,
    List<FlSpot> tk202Data,
    List<FlSpot> tk103Data,
    List<String> timestamps,
    DateFormat formatter,
    Function(int, int, int, double, double, double) updateCallback,
  ) async {
    try {
      // Ambil data dari Firebase
      final dataSnapshot = await _database.child('sensor_data').get();
      if (dataSnapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(dataSnapshot.value as Map);
        final tk201 = data['tk201']?.toDouble() ?? 0;
        final tk202 = data['tk202']?.toDouble() ?? 0;
        final tk103 = data['tk103']?.toDouble() ?? 0;
        final boiler = data['boiler'] ?? 0;
        final ofda = data['ofda'] ?? 0;
        final oiless = data['oiless'] ?? 0;
        final timestamp = DateTime.now();

        // Simpan data, tk201, tk202, dan tk103 di-append, boiler, ofda, dan oiless di-replace
        await _saveToHive(tk201, tk202, tk103, boiler, ofda, oiless, timestamp);

        // Cek kondisi alarm berdasarkan pengaturan switch
        await checkAlarmCondition(
            tk201, tk202, tk103, boiler, ofda, oiless, timestamp);

        // Panggil callback dengan data yang diterima
        updateCallback(
            boiler.toInt(), oiless.toInt(), ofda.toInt(), tk201, tk202, tk103);

        // Update stream untuk boiler, oiless, dan ofda
        _boilerStreamController.add(boiler.toInt());
        _oilessStreamController.add(oiless.toInt());
        _ofdaStreamController.add(ofda.toInt());
      }
    } catch (e) {
      print("Error fetching data from Firebase: $e");
    }
  }

  Future<void> _saveToHive(double tk201, double tk202, double tk103, int boiler,
      int ofda, int oiless, DateTime timestamp) async {
    // Buka atau buat box bernama 'sensorDataBox'
    final sensorDataBox = await Hive.openBox('sensorDataBox');

    // Simpan data tk201, tk202, tk103 dengan append (tambahkan ke list)
    List<dynamic> sensorDataList =
        sensorDataBox.get('sensorDataList', defaultValue: []);
    final sensorData = {
      'tk201': tk201,
      'tk202': tk202,
      'tk103': tk103,
      'timestamp': timestamp.toIso8601String(), // Tipe data ini adalah String
    };
    sensorDataList.add(sensorData); // Append data baru ke dalam list
    await sensorDataBox.put(
        'sensorDataList', sensorDataList); // Simpan list baru

    // Replace data boiler, ofda, oiless
    final sensorStatus = {
      'boiler': boiler,
      'ofda': ofda,
      'oiless': oiless,
      'timestamp': timestamp.toIso8601String(), // Tipe data ini adalah String
    };
    await sensorDataBox.put(
        'sensorStatus', sensorStatus); // Replace data status

    print("Data sensor disimpan ke Hive");
  }

  // Jangan lupa untuk menutup stream controller saat tidak digunakan
  void dispose() {
    _boilerStreamController.close();
    _oilessStreamController.close();
    _ofdaStreamController.close();
  }
}
