import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/ui/ui.dart';
import 'package:flutter_app/util/base64.dart';

Map<String, String> _pages;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    _pages = Map();
    var home =
        "{\"style\":{},\"body\":{\"tag\":\"body\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"row\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3snaWQ6JyArIGlkeCArICcgdGV4dDonICsgaXR9fQ==\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{\"repeat\":{\"name\":\"or\",\"expression\":\"{{item}}\",\"item\":\"it\",\"index\":\"idx\"}},\"attribStyle\":{\"width\":\"100px\",\"height\":\"100px\",\"color\":\"{{colors[index]}}\",\"margin-right\":\"15px\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{\"repeat\":{\"name\":\"or\",\"expression\":\"{{list}}\",\"item\":\"item\",\"index\":\"index\"}},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},\"type\":{},\"align\":{},\"description\":{},\"script\":{\"tag\":\"script\",\"innerHTML\":\"IWZ1bmN0aW9uKGUpe3ZhciB0PXt9O2Z1bmN0aW9uIG8obil7aWYodFtuXSlyZXR1cm4gdFtuXS5leHBvcnRzO3ZhciByPXRbbl09e2k6bixsOiExLGV4cG9ydHM6e319O3JldHVybiBlW25dLmNhbGwoci5leHBvcnRzLHIsci5leHBvcnRzLG8pLHIubD0hMCxyLmV4cG9ydHN9by5tPWUsby5jPXQsby5kPWZ1bmN0aW9uKGUsdCxuKXtvLm8oZSx0KXx8T2JqZWN0LmRlZmluZVByb3BlcnR5KGUsdCx7ZW51bWVyYWJsZTohMCxnZXQ6bn0pfSxvLnI9ZnVuY3Rpb24oZSl7InVuZGVmaW5lZCIhPXR5cGVvZiBTeW1ib2wmJlN5bWJvbC50b1N0cmluZ1RhZyYmT2JqZWN0LmRlZmluZVByb3BlcnR5KGUsU3ltYm9sLnRvU3RyaW5nVGFnLHt2YWx1ZToiTW9kdWxlIn0pLE9iamVjdC5kZWZpbmVQcm9wZXJ0eShlLCJfX2VzTW9kdWxlIix7dmFsdWU6ITB9KX0sby50PWZ1bmN0aW9uKGUsdCl7aWYoMSZ0JiYoZT1vKGUpKSw4JnQpcmV0dXJuIGU7aWYoNCZ0JiYib2JqZWN0Ij09dHlwZW9mIGUmJmUmJmUuX19lc01vZHVsZSlyZXR1cm4gZTt2YXIgbj1PYmplY3QuY3JlYXRlKG51bGwpO2lmKG8ucihuKSxPYmplY3QuZGVmaW5lUHJvcGVydHkobiwiZGVmYXVsdCIse2VudW1lcmFibGU6ITAsdmFsdWU6ZX0pLDImdCYmInN0cmluZyIhPXR5cGVvZiBlKWZvcih2YXIgciBpbiBlKW8uZChuLHIsZnVuY3Rpb24odCl7cmV0dXJuIGVbdF19LmJpbmQobnVsbCxyKSk7cmV0dXJuIG59LG8ubj1mdW5jdGlvbihlKXt2YXIgdD1lJiZlLl9fZXNNb2R1bGU/ZnVuY3Rpb24oKXtyZXR1cm4gZS5kZWZhdWx0fTpmdW5jdGlvbigpe3JldHVybiBlfTtyZXR1cm4gby5kKHQsImEiLHQpLHR9LG8ubz1mdW5jdGlvbihlLHQpe3JldHVybiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwoZSx0KX0sby5wPSIiLG8oby5zPTApfShbZnVuY3Rpb24oZSx0KXtQYWdlKHtkYXRhOntsaXN0OltbIngxIiwieDIiXSxbInkxIiwieTIiXSxbInoxIiwiejIiXV0sYnRuQ29sb3I6ImdyZWVuIixjb2xvcnM6WyJncmVlbiIsInJlZCIsImJsdWUiXSxpdGVtMjoieXl5eSIsd2lkdGg6LjIsaGVpZ2h0Oi4yLG5hbWU6ImNtcyBkZW1vIn0sb25jbGljaygpe2xldCBlPXRoaXMuZGF0YS53aWR0aCsuMSx0PXRoaXMuZGF0YS5oZWlnaHQrLjEsbz1NYXRoLmNlaWwoMypNYXRoLnJhbmRvbSgpKTtjb25zb2xlLmxvZygicmFuZG9tID0gIitvKTtsZXQgbj10aGlzLmRhdGEuY29sb3JzW29dO3RoaXMuc2V0RGF0YSh7bmFtZToiY21zIix3aWR0aDplLGhlaWdodDp0LGJ0bkNvbG9yOm59KTtsZXQgcj10aGlzO2NjLnJlcXVlc3Qoe3VybDoiaHR0cDovL3FhLnNjbS5wcG1vbmV5LmNvbTo3MzAwL21vY2svNWFiMjMyYTFhODgxNzEwMDZkMmI2MDY2L2Ntcy9wYWdlL2dldCIsZGF0YTp7fSxoZWFkZXI6e30sbWV0aG9kOiJwb3N0IixzdWNjZXNzOmZ1bmN0aW9uKGUpe2NvbnNvbGUubG9nKCJyZXF1ZXN0IHN1Y2Nlc3M6IitKU09OLnN0cmluZ2lmeShlKSksci5zZXREYXRhKHtpdGVtMjpKU09OLnN0cmluZ2lmeShlKX0pfSxmYWlsOmZ1bmN0aW9uKGUpe2NvbnNvbGUubG9nKCJyZXF1ZXN0IGVycm9yOiIrSlNPTi5zdHJpbmdpZnkoZSkpfSxjb21wbGV0ZTpmdW5jdGlvbigpe2NvbnNvbGUubG9nKCJyZXF1ZXN0IGNvbXBsZXRlIil9fSl9LG9uTG9hZChlKXtjb25zb2xlLmxvZygicHBjbXMgbmFtZSA9ICIrdGhpcy5kYXRhLm5hbWUpfSxvblVubG9hZCgpe319KX1dKTsKLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZXhhbXBsZS5idW5kbGUuanMubWFw\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}}";
    _pages.putIfAbsent('home', () => home);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _MainPage({}),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) {
          return _MainPage(settings.arguments);
        });
      },
      routes: <String, WidgetBuilder>{
        '/main': (BuildContext context) => _MainPage({}),
      },
    );
  }
}

class _MainPage extends StatefulWidget {
  Map<String, dynamic> _args;

  _MainPage(this._args);

  @override
  _MainPageState createState() => _MainPageState(_args);
}

class _MainPageState extends State<_MainPage> {
  var _methodChannel = MethodChannel("com.cc.hybrid/method");
  var _basicChannel =
      BasicMessageChannel<String>('com.cc.hybrid/basic', StringCodec());

  Map<String, dynamic> _args = Map();
  Map<String, dynamic> _data;
  String _pageCode = "";
  String _pageId = "";
  String _title = "";
  Widget view;

  _MainPageState(this._args) {
    if (_args.containsKey("pageCode")) {
      _args.forEach((k, v) {
        if (k == 'pageCode') {
          _pageCode = v;
        }
      });
    } else {
      _pageCode = 'home';
    }
  }

  _initData() async {
    _pageId = _pageCode + this.hashCode.toString();
    _data = jsonDecode(_pages[_pageCode]);
    _create(true);
  }

  _initBasicChannel() async {
    _basicChannel.setMessageHandler((String message) {
      print('Flutter Received: $message');
      Map<String, dynamic> map = jsonDecode(message);
      int type = map['type'];
      switch (type) {
        case 0: //socket
          _refresh(map);
          break;
        case 1: //onclick
          _update();
          break;
        case 2: //set_navigation_bar_title
          _updateTitle(map);
          break;
        case 3: //navigate_to
          _navigateTo(map);
          break;
      }
      return Future<String>.value("success");
    });
  }

  void _refresh(Map<String, dynamic> map) {
    var jsonObject = jsonDecode(map['message']);
    var content = jsonObject['content'];
    _data = jsonDecode(content);
    _create(true);
  }

  void _update() {
    _create(false);
  }

  void _updateTitle(Map<String, dynamic> map) {
    setState(() {
      _title = map['message'];
    });
  }

  void _navigateTo(Map<String, dynamic> map) {
    var jsonObject = jsonDecode(map['message']);
    var url = jsonObject['url'];
    if (null != url) {
      var uri = Uri.parse(url);
      var path = uri.path;
      var params = uri.queryParameters;
      if (null != path && path.isNotEmpty) {
        var args = Map<String, dynamic>();
        args.putIfAbsent("pageCode", () => path);
        params?.forEach((k, v) {
          args.putIfAbsent(k, () => v);
        });
        Navigator.of(context).pushNamed("/main", arguments: args);
      }
    }
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

  @override
  void initState() {
    super.initState();
    _initData();
    _initBasicChannel();
  }

  @override
  void dispose() {
    super.dispose();
    _callOnUnload();
  }

  void _initScript(String script) {
    _methodChannel.invokeMethod(
        "attach_page", {"pageId": _pageId, "script": decodeBase64(script)});
  }

  Future<Widget> _createWidget(
      Map<String, dynamic> body, Map<String, dynamic> styles) async {
    var factory = UIFactory(_pageId, _methodChannel);
    return factory.createView(body, styles);
  }

  void _callOnLoad() {
    _methodChannel
        .invokeMethod("onLoad", {"pageId": _pageId, "args": jsonEncode(_args)});
  }

  void _callOnUnload() {
    _methodChannel.invokeMethod("onUnload", {"pageId": _pageId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: Key(view.hashCode.toString()),
        appBar: AppBar(
          title: Text(_title),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
          Navigator.of(context).pushNamed("/main");
        }),
        backgroundColor: Colors.grey[200],
        body: view);
  }
}
