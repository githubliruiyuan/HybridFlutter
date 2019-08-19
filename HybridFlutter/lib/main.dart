import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/ui/ui.dart';
import 'package:flutter_app/util/base64.dart';

//Socket socket;

const methodChannel = const MethodChannel("com.cc.hybrid/method");
const basicChannel =
    BasicMessageChannel<String>('com.cc.hybrid/basic', StringCodec());

var pageId = "1111-2222-3333";

var json =
    "{\"style\":{},\"body\":{\"tag\":\"body\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"row\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3snaWQ6JyArIGlkeCArICcgdGV4dDonICsgaXR9fQ==\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{\"repeat\":{\"name\":\"or\",\"expression\":\"{{item}}\",\"item\":\"it\",\"index\":\"idx\"}},\"attribStyle\":{\"width\":\"100px\",\"height\":\"100px\",\"color\":\"{{colors[index]}}\",\"margin-right\":\"15px\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{\"repeat\":{\"name\":\"or\",\"expression\":\"{{list}}\",\"item\":\"item\",\"index\":\"index\"}},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},\"type\":{},\"align\":{},\"description\":{},\"script\":{\"tag\":\"script\",\"innerHTML\":\"IWZ1bmN0aW9uKGUpe3ZhciB0PXt9O2Z1bmN0aW9uIG8obil7aWYodFtuXSlyZXR1cm4gdFtuXS5leHBvcnRzO3ZhciByPXRbbl09e2k6bixsOiExLGV4cG9ydHM6e319O3JldHVybiBlW25dLmNhbGwoci5leHBvcnRzLHIsci5leHBvcnRzLG8pLHIubD0hMCxyLmV4cG9ydHN9by5tPWUsby5jPXQsby5kPWZ1bmN0aW9uKGUsdCxuKXtvLm8oZSx0KXx8T2JqZWN0LmRlZmluZVByb3BlcnR5KGUsdCx7ZW51bWVyYWJsZTohMCxnZXQ6bn0pfSxvLnI9ZnVuY3Rpb24oZSl7InVuZGVmaW5lZCIhPXR5cGVvZiBTeW1ib2wmJlN5bWJvbC50b1N0cmluZ1RhZyYmT2JqZWN0LmRlZmluZVByb3BlcnR5KGUsU3ltYm9sLnRvU3RyaW5nVGFnLHt2YWx1ZToiTW9kdWxlIn0pLE9iamVjdC5kZWZpbmVQcm9wZXJ0eShlLCJfX2VzTW9kdWxlIix7dmFsdWU6ITB9KX0sby50PWZ1bmN0aW9uKGUsdCl7aWYoMSZ0JiYoZT1vKGUpKSw4JnQpcmV0dXJuIGU7aWYoNCZ0JiYib2JqZWN0Ij09dHlwZW9mIGUmJmUmJmUuX19lc01vZHVsZSlyZXR1cm4gZTt2YXIgbj1PYmplY3QuY3JlYXRlKG51bGwpO2lmKG8ucihuKSxPYmplY3QuZGVmaW5lUHJvcGVydHkobiwiZGVmYXVsdCIse2VudW1lcmFibGU6ITAsdmFsdWU6ZX0pLDImdCYmInN0cmluZyIhPXR5cGVvZiBlKWZvcih2YXIgciBpbiBlKW8uZChuLHIsZnVuY3Rpb24odCl7cmV0dXJuIGVbdF19LmJpbmQobnVsbCxyKSk7cmV0dXJuIG59LG8ubj1mdW5jdGlvbihlKXt2YXIgdD1lJiZlLl9fZXNNb2R1bGU/ZnVuY3Rpb24oKXtyZXR1cm4gZS5kZWZhdWx0fTpmdW5jdGlvbigpe3JldHVybiBlfTtyZXR1cm4gby5kKHQsImEiLHQpLHR9LG8ubz1mdW5jdGlvbihlLHQpe3JldHVybiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwoZSx0KX0sby5wPSIiLG8oby5zPTApfShbZnVuY3Rpb24oZSx0KXtQYWdlKHtkYXRhOntsaXN0OltbIngxIiwieDIiXSxbInkxIiwieTIiXSxbInoxIiwiejIiXV0sYnRuQ29sb3I6ImdyZWVuIixjb2xvcnM6WyJncmVlbiIsInJlZCIsImJsdWUiXSxpdGVtMjoieXl5eSIsd2lkdGg6LjIsaGVpZ2h0Oi4yLG5hbWU6ImNtcyBkZW1vIn0sb25jbGljaygpe2xldCBlPXRoaXMuZGF0YS53aWR0aCsuMSx0PXRoaXMuZGF0YS5oZWlnaHQrLjEsbz1NYXRoLmNlaWwoMypNYXRoLnJhbmRvbSgpKTtjb25zb2xlLmxvZygicmFuZG9tID0gIitvKTtsZXQgbj10aGlzLmRhdGEuY29sb3JzW29dO3RoaXMuc2V0RGF0YSh7bmFtZToiY21zIix3aWR0aDplLGhlaWdodDp0LGJ0bkNvbG9yOm59KTtsZXQgcj10aGlzO2NjLnJlcXVlc3Qoe3VybDoiaHR0cDovL3FhLnNjbS5wcG1vbmV5LmNvbTo3MzAwL21vY2svNWFiMjMyYTFhODgxNzEwMDZkMmI2MDY2L2Ntcy9wYWdlL2dldCIsZGF0YTp7fSxoZWFkZXI6e30sbWV0aG9kOiJwb3N0IixzdWNjZXNzOmZ1bmN0aW9uKGUpe2NvbnNvbGUubG9nKCJyZXF1ZXN0IHN1Y2Nlc3M6IitKU09OLnN0cmluZ2lmeShlKSksci5zZXREYXRhKHtpdGVtMjpKU09OLnN0cmluZ2lmeShlKX0pfSxmYWlsOmZ1bmN0aW9uKGUpe2NvbnNvbGUubG9nKCJyZXF1ZXN0IGVycm9yOiIrSlNPTi5zdHJpbmdpZnkoZSkpfSxjb21wbGV0ZTpmdW5jdGlvbigpe2NvbnNvbGUubG9nKCJyZXF1ZXN0IGNvbXBsZXRlIil9fSl9LG9uTG9hZChlKXtjb25zb2xlLmxvZygicHBjbXMgbmFtZSA9ICIrdGhpcy5kYXRhLm5hbWUpfSxvblVubG9hZCgpe319KX1dKTsKLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZXhhbXBsZS5idW5kbGUuanMubWFw\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}}";

var template = jsonDecode(json);

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new FirstPage(title: '测试界面'),
      routes: <String, WidgetBuilder>{
        '/main_page': (BuildContext context) => MainPage(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map<String, dynamic> _data;
  Widget view;

  _getData() async {
    _data = template;
    _create(true);
  }

  _createSocket() {
//    print("1111");
//    Socket.connect("192.168.13.106", 9999).then((Socket sock) {
//      sock.listen(dataHandler,
//          onError: errorHandler, onDone: doneHandler, cancelOnError: false);
//    }).catchError((AsyncError e) {
//      print("Unable to connect: $e");
//    });
  }

  _initBasicChannel() async {
    basicChannel.setMessageHandler((String message) {
      print('Flutter Received: $message');
      Map<String, dynamic> map = jsonDecode(message);
      int type = map['type'];
      switch (type) {
        case 0:
          _refresh(map);
          break;
        case 1:
          _update();
          break;
      }
      return Future<String>.value("success");
    });
  }

  void _refresh(Map<String, dynamic> map) {
    String jsonString = map['message'];
    Map<String, dynamic> jsonObject = jsonDecode(jsonString);
    var content = jsonObject['content'];
    _data = jsonDecode(content);
    _create(true);
  }

  void _update() {
    _create(false);
  }

  void _create(bool isInit) async {
    var body = _data['body'];
    var styles = _data['style'];
    var script = _data['script'];
    if (null == script) {
      script = "";
    } else {
      script = script['innerHTML'];
    }

    var widget;
    if (isInit) {
      _initScript(script);
      widget = await _createWidget(body, styles);
      _callOnLoad();
    } else {
      widget = await _createWidget(body, styles);
    }

    setState(() {
      view = widget;
    });
  }

  //接收报文
  void dataHandler(data) {
    print(utf8.decode(data));
//    print("222222");
//    var str = String.fromCharCodes(data);
//    tempData = tempData + str;
//    if (tempData.endsWith('}')) {
//      print(tempData);
//      var map = jsonDecode(tempData);
//      var content = map['content'];
//      setState(() {
//        _data = jsonDecode(content);
//      });
//      tempData = "";
//    }
  }

  void _errorHandler(error, StackTrace trace) {
    print(error);
  }

//  void _doneHandler() {
//    if (null != socket) {
//      socket.destroy();
//    }
//  }

  @override
  void initState() {
    super.initState();
    _getData();
//    _createSocket();
    _initBasicChannel();
  }

  @override
  void dispose() {
    super.dispose();
//    if (null != socket) {
//      socket.destroy();
//    }
  }

  void _initScript(String script) {
    methodChannel.invokeMethod("attach_page",
        {"pageId": pageId, "script": decodeBase64(script)});
  }

  Future<Widget> _createWidget(
      Map<String, dynamic> body, Map<String, dynamic> styles) async {
    var factory = UIFactory(pageId, methodChannel);
    return factory.createView(body, styles);
  }

  void _callOnLoad() {
    methodChannel.invokeMethod("onLoad", {"pageId": pageId});
  }

  void _callOnUnload() {
    methodChannel.invokeMethod("onUnload", {"pageId": pageId});
  }

  @override
  Widget build(BuildContext context) {
    print("widget id ${view.hashCode}");
    var scaffold = Scaffold(
        key: Key(view.hashCode.toString()),
        appBar: AppBar(
          title: Text('获取数据 ${view.hashCode} '),
        ),
        backgroundColor: Colors.grey[200],
        body: view);
    print("scaffold = ${scaffold.hashCode}");
    return scaffold;
  }
}

class FirstPage extends StatefulWidget {
  FirstPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  // Default placeholder text
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sample App"),
        ),
        body: Center(
          child: new CustomButton(
              "main_page", "/main_page"), //因为后面可能还要加别的方法  我把它写在了一个通用的方法里
        ));
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  String link;

  CustomButton(this.label, this.link);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: RaisedButton(
        onPressed: () {
          //类似android中的Button MateriaButton是没有背景的
          Navigator.of(context).pushNamed(link); // 根据page名称跳转  也就是上面路有定义的
        },
        child: Text(
          label,
          style: new TextStyle(height: 1),
        ), //按钮上的文字
      ),
      width: double.infinity,
    ); //宽度占满
  }
}
