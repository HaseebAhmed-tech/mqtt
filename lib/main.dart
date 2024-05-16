import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
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
  MqttServerClient? _client;

  String _topic = '';
  String _message = '';
  String _publishedMessage = '';
  final String broker = 'broker.hivemq.com';
  final String clientId = 'flutter_client';
  bool _isConnected = false;
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
      _client = MqttServerClient.withPort(
          broker, clientId, maxConnectionAttempts: 5, 8883);
      _client!.logging(on: true);

      await _client!.connect();
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      debugPrint('Connected to broker');
    } catch (e) {
      debugPrint('Error connecting to broker: $e');
    }
  }

  void _onConnected() {
    debugPrint('Connected to MQTT broker');
    setState(() {
      _isConnected = true;
    });

    // Subscribe to topics or perform other actions here
  }

  void _onDisconnected() {
    _isConnected = false;
    debugPrint('Disconnected from MQTT broker');
  }

  void _subscribe() {
    if (_topic.isNotEmpty) {
      if (_isConnected) {
        _client!.subscribe(_topic, MqttQos.atLeastOnce);
      }
    }
  }

  void _publish() {
    if (_message.isNotEmpty) {
      _client!.publishMessage(_topic, MqttQos.atLeastOnce,
          (MqttClientPayloadBuilder()..addString(_message)) as Uint8Buffer);
      setState(() {
        _publishedMessage = _message;
      });
    }
  }
}
