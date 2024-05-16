import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:typed_data/typed_buffers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MQTT Client',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final MqttServerClient _client =
      MqttServerClient('test.mosquitto.org', 'my_client_id');
  String _topic = '';
  String _message = '';
  String _publishedMessage = '';
  Uint8Buffer myBuffer = Uint8Buffer(); // Creates an empty buffer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('MQTT Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _connect,
              child: const Text('Connect to Broker'),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  _topic = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Topic',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _subscribe,
              child: const Text('Subscribe to Topic'),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  _message = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Message',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _publish,
              child: const Text('Publish Message'),
            ),
            const SizedBox(height: 16),
            Text(
              _publishedMessage,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  void _connect() async {
    try {
      await _client.connect();
      print('Connected to broker');
    } catch (e) {
      print('Error connecting to broker: $e');
    }
  }

  void _subscribe() {
    if (_topic.isNotEmpty) {
      _client.subscribe(_topic, mqtt.MqttQos.atLeastOnce);
    }
  }

  void _publish() {
    if (_message.isNotEmpty) {
      if (_client.connectionStatus!.state ==
          mqtt.MqttConnectionState.connected) {
        debugPrint('publishing Message');
        (myBuffer.addAll(utf8.encode(_message)));
        _client.publishMessage(
          _topic,
          mqtt.MqttQos.atLeastOnce,
          myBuffer,
        );
        debugPrint('Message Published');
        setState(() {
          _publishedMessage = _message;
        });
      }
    }
  }
}
