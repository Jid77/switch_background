// //////////////////
import 'package:flutter/material.dart';
import 'package:testhive/home_page.dart';
import 'package:testhive/service_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceManager.initializeService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Foreground Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}
