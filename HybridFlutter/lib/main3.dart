import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _ipAddress = 'Unknown';

  _getIPAddress() async {
    await http.post('http://192.168.13.106:7001/table/data',
        body: {'tableName': 'testTable'}).then((response) {
      print("post方式->status: ${response.statusCode}");
      print("post方式->body: ${response.body}");
      print("post方式->body: ${jsonDecode(response.body)['payload'].runtimeType.toString()}");
      if (!mounted) return;

      setState(() {
        _ipAddress = jsonDecode(response.body)['payload'].toString();
      });
    });

    // If the widget was removed from the tree while the message was in flight,
    // we want to discard the reply rather than calling setState to update our
    // non-existent appearance.
  }

  @override
  Widget build(BuildContext context) {
    var spacer = new SizedBox(height: 32.0);

    return new Scaffold(
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text('Your current IP address is:'),
            new Text('$_ipAddress.'),
            spacer,
            new RaisedButton(
              onPressed: _getIPAddress,
              child: new Text('Get IP address'),
            ),
          ],
        ),
      ),
    );
  }
}
