import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multicast_dns/multicast_dns.dart';

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
      home: MyHomePage(mDnsClient: mDnsClient),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final MDnsClient mDnsClient;

  MyHomePage({Key? key, required this.mDnsClient}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlinedButton(
                child: Image.asset('images/button.png'),
                onPressed: () async {
                  var record = await widget.mDnsClient
                      .lookup<IPAddressResourceRecord>(
                          ResourceRecordQuery.addressIPv4('garage-door.local'))
                      .first;
                  var address = record.address;
                  http.get(Uri.http('${address.address}', '/press-button'));
                }),
          ],
        ),
      ),
    );
  }
}
