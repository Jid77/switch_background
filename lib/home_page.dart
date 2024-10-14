import 'package:flutter/material.dart';
import 'service_manager.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Switch untuk masing-masing alarm
  List<bool> switchStates = [false, false, false, false, false, false];
  // Index untuk masing-masing sensor switch: [tk201, tk202, tk103, boiler, ofda, oiless]

  @override
  void initState() {
    super.initState();
    _loadSwitchStates();
  }

  Future<void> _loadSwitchStates() async {
    for (int i = 0; i < switchStates.length; i++) {
      bool state = await ServiceManager.loadSwitchState(i);
      setState(() {
        switchStates[i] = state;
      });
    }
  }

  void _onSwitchChanged(int index, bool value) async {
    setState(() {
      switchStates[index] = value;
    });

    await ServiceManager.saveSwitchState(index, value);

    if (value) {
      ServiceManager.startAlarm(index);
    } else {
      ServiceManager.stopAlarm(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alarm Switches"),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Alarm tk201'),
            value: switchStates[0],
            onChanged: (value) => _onSwitchChanged(0, value),
          ),
          SwitchListTile(
            title: Text('Alarm tk202'),
            value: switchStates[1],
            onChanged: (value) => _onSwitchChanged(1, value),
          ),
          SwitchListTile(
            title: Text('Alarm tk103'),
            value: switchStates[2],
            onChanged: (value) => _onSwitchChanged(2, value),
          ),
          SwitchListTile(
            title: Text('Alarm Boiler'),
            value: switchStates[3],
            onChanged: (value) => _onSwitchChanged(3, value),
          ),
          SwitchListTile(
            title: Text('Alarm OFDA'),
            value: switchStates[4],
            onChanged: (value) => _onSwitchChanged(4, value),
          ),
          SwitchListTile(
            title: Text('Alarm Oiless'),
            value: switchStates[5],
            onChanged: (value) => _onSwitchChanged(5, value),
          ),
        ],
      ),
    );
  }
}
