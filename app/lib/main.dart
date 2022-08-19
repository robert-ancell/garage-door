import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multicast_dns/multicast_dns.dart';

import 'dns.dart';

Future<void> main() async {
  final mDnsClient = MDnsClient();
  await mDnsClient.start();
  runApp(MyApp(mDnsClient: mDnsClient));
}

class MyApp extends StatelessWidget {
  final MDnsClient mDnsClient;

  MyApp({Key? key, required this.mDnsClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          OutlinedButton(
              child: Text('Press Me'),
              onPressed: () async {
                var address = await lookupLocalServiceAddress(
                    'button._garagedoor._tcp.local');
                if (address != null) {
                  http.get(
                      Uri.http('${address.address.address}:${address.port}', '/press-button'));
                }
              }),
        ],
      ),
    );
  }
}
