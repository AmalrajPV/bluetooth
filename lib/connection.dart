import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({Key? key, required this.tittle}) : super(key: key);
  final String tittle;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? ctdDevice;
  int _rssi = 0;
  String _mac = "";
  String? _name = "";
  int _cnt = 0;

  Future<void> getDevice() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } on PlatformException {
      // print("Error");
    }
    if (!mounted) {
      return;
    }
    setState(() {
      ctdDevice = null;
      _devicesList = devices;
      for (var i in _devicesList) {
        if (i.isConnected) {
          ctdDevice = i;
        }
      }
      if (ctdDevice == null) {
        _rssi = 0;
        _mac = "no device connected";
        _name = "no device connected";
      }
    });
    await FlutterBluetoothSerial.instance.cancelDiscovery();
    FlutterBluetoothSerial.instance.startDiscovery().forEach((element) {
      if (element.device.address == ctdDevice?.address) {
        setState(() {
          _rssi = element.rssi;
          _mac = element.device.address;
          _name = element.device.name;
          _cnt++;
        });
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tittle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            ElevatedButton(
              child: const Text("click"),
              onPressed: getDevice,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Device Name : '), Text('$_name')],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Device address : '), Text(_mac)],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Device rssi : '), Text(_rssi.toString())],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Click count : '), Text(_cnt.toString())],
            ),
          ],
        ),
      ),
    );
  }
}
