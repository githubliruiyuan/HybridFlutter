import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/ui/ui.dart';
import 'package:flutter_app/util/base64.dart';

var _methodChannel = MethodChannel("com.cc.hybrid/method");
var _basicChannel =
    BasicMessageChannel<String>('com.cc.hybrid/basic', StringCodec());

Map<String, String> _pages;
Map<String, MessageHandler> _handlers;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    _handlers = Map();
    _pages = Map();
    var home =
        "{\"style\":{\".btn-container\":{\"margin-top\":\"10\",\"margin-left\":\"10\",\"margin-right\":\"10\"},\".raisedbutton\":{\"color\":\"white\"},\".image-container\":{\"width\":\"100px\",\"height\":\"100px\",\"padding\":\"5\"},\".column-text\":{\"cross-axis-alignment\":\"start\"},\".text-title\":{\"font-size\":\"14px\",\"color\":\"black\"},\".text-publisher\":{\"font-size\":\"12px\",\"color\":\"gray\"},\".text-summary\":{\"font-size\":\"12px\",\"color\":\"gray\"}},\"body\":{\"tag\":\"body\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"singlechildscrollview\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"raisedbutton\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"row\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"image\",\"innerHTML\":\"\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"src\":\"{{item.image}}\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"image-container\"},{\"tag\":\"expanded\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3tpdGVtLnRpdGxlfX0=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"text-title\"},{\"tag\":\"text\",\"innerHTML\":\"e3tpdGVtLnB1Ymxpc2hlcn19\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"text-publisher\"},{\"tag\":\"text\",\"innerHTML\":\"e3tpdGVtLnN1bW1hcnkuc3Vic3RyaW5nKDAsIDIwKSArICcuLi4nfX0=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"text-summary\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"column-text\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{\"ex\":\"{{index}}\"},\"events\":{\"onclick\":\"onItemClick\"},\"directives\":{},\"attribStyle\":{},\"attrib\":{\"data-index\":\"{{index}}\"},\"id\":\"raisedbutton\"}],\"datasets\":{},\"events\":{},\"directives\":{\"repeat\":{\"name\":\"or\",\"expression\":\"{{list}}\",\"item\":\"item\",\"index\":\"index\"}},\"attribStyle\":{},\"attrib\":{},\"id\":\"btn-container\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},\"type\":{},\"align\":{},\"description\":{},\"script\":{\"tag\":\"script\",\"innerHTML\":\"IWZ1bmN0aW9uKGUpe3ZhciB0PXt9O2Z1bmN0aW9uIG8obil7aWYodFtuXSlyZXR1cm4gdFtuXS5leHBvcnRzO3ZhciByPXRbbl09e2k6bixsOiExLGV4cG9ydHM6e319O3JldHVybiBlW25dLmNhbGwoci5leHBvcnRzLHIsci5leHBvcnRzLG8pLHIubD0hMCxyLmV4cG9ydHN9by5tPWUsby5jPXQsby5kPWZ1bmN0aW9uKGUsdCxuKXtvLm8oZSx0KXx8T2JqZWN0LmRlZmluZVByb3BlcnR5KGUsdCx7ZW51bWVyYWJsZTohMCxnZXQ6bn0pfSxvLnI9ZnVuY3Rpb24oZSl7InVuZGVmaW5lZCIhPXR5cGVvZiBTeW1ib2wmJlN5bWJvbC50b1N0cmluZ1RhZyYmT2JqZWN0LmRlZmluZVByb3BlcnR5KGUsU3ltYm9sLnRvU3RyaW5nVGFnLHt2YWx1ZToiTW9kdWxlIn0pLE9iamVjdC5kZWZpbmVQcm9wZXJ0eShlLCJfX2VzTW9kdWxlIix7dmFsdWU6ITB9KX0sby50PWZ1bmN0aW9uKGUsdCl7aWYoMSZ0JiYoZT1vKGUpKSw4JnQpcmV0dXJuIGU7aWYoNCZ0JiYib2JqZWN0Ij09dHlwZW9mIGUmJmUmJmUuX19lc01vZHVsZSlyZXR1cm4gZTt2YXIgbj1PYmplY3QuY3JlYXRlKG51bGwpO2lmKG8ucihuKSxPYmplY3QuZGVmaW5lUHJvcGVydHkobiwiZGVmYXVsdCIse2VudW1lcmFibGU6ITAsdmFsdWU6ZX0pLDImdCYmInN0cmluZyIhPXR5cGVvZiBlKWZvcih2YXIgciBpbiBlKW8uZChuLHIsZnVuY3Rpb24odCl7cmV0dXJuIGVbdF19LmJpbmQobnVsbCxyKSk7cmV0dXJuIG59LG8ubj1mdW5jdGlvbihlKXt2YXIgdD1lJiZlLl9fZXNNb2R1bGU/ZnVuY3Rpb24oKXtyZXR1cm4gZS5kZWZhdWx0fTpmdW5jdGlvbigpe3JldHVybiBlfTtyZXR1cm4gby5kKHQsImEiLHQpLHR9LG8ubz1mdW5jdGlvbihlLHQpe3JldHVybiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwoZSx0KX0sby5wPSIiLG8oby5zPTEpfShbLGZ1bmN0aW9uKGUsdCl7UGFnZSh7ZGF0YTp7bGlzdDpbXX0sb25Mb2FkKGUpe2NjLnNldE5hdmlnYXRpb25CYXJUaXRsZSh7dGl0bGU6IlB5dGhvbuezu+WIl+S4m+S5piJ9KSxjYy5zaG93TG9hZGluZyh7bWVzc2FnZToi5q2j5Zyo546p5ZG95Yqg6L29Li4uIn0pO2xldCB0PXRoaXM7Y2MucmVxdWVzdCh7dXJsOiJodHRwczovL3d3dy5lYXN5LW1vY2suY29tL21vY2svNWFiNDYyMzZlMWMxN2IzYjJjYzU1ODQzL2V4YW1wbGUvYm9va3MiLGRhdGE6e30saGVhZGVyOnt9LG1ldGhvZDoiZ2V0IixzdWNjZXNzOmZ1bmN0aW9uKGUpe3Quc2V0RGF0YSh7bGlzdDplLmJvZHkuYm9va3N9KX0sZmFpbDpmdW5jdGlvbihlKXtjb25zb2xlLmxvZygicmVxdWVzdCBlcnJvcjoiK0pTT04uc3RyaW5naWZ5KGUpKX0sY29tcGxldGU6ZnVuY3Rpb24oKXtjb25zb2xlLmxvZygicmVxdWVzdCBjb21wbGV0ZSIpLGNjLmhpZGVMb2FkaW5nKCl9fSl9LG9uSXRlbUNsaWNrKGUpe3ZhciB0PXRoaXMuZGF0YS5saXN0W2UudGFyZ2V0LmRhdGFzZXQuaW5kZXhdO2NjLnNldFN0b3JhZ2Uoe2tleTp0LmlzYm4xMyxkYXRhOkpTT04uc3RyaW5naWZ5KHQpfSksY2MubmF2aWdhdGVUbyh7dXJsOiJkZXRhaWw/aXRlbT0iK0pTT04uc3RyaW5naWZ5KHQpfSl9LG9uVW5sb2FkKCl7fX0pfV0pOwovLyMgc291cmNlTWFwcGluZ1VSTD1ob21lLmJ1bmRsZS5qcy5tYXA=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}}";
    var detail =
        "{\"style\":{\".container\":{\"width\":\"100px\",\"height\":\"100px\",\"color\":\"blue\"},\".text\":{\"font-size\":\"14px\",\"color\":\"white\"}},\"body\":{\"tag\":\"body\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"singlechildscrollview\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"image\",\"innerHTML\":\"\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"src\":\"{{detail.image}}\"},\"attrib\":{},\"id\":\"image\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3tkZXRhaWwuY2F0YWxvZ319\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},\"type\":{},\"align\":{},\"description\":{},\"script\":{\"tag\":\"script\",\"innerHTML\":\"IWZ1bmN0aW9uKGUpe3ZhciB0PXt9O2Z1bmN0aW9uIG4ocil7aWYodFtyXSlyZXR1cm4gdFtyXS5leHBvcnRzO3ZhciBvPXRbcl09e2k6cixsOiExLGV4cG9ydHM6e319O3JldHVybiBlW3JdLmNhbGwoby5leHBvcnRzLG8sby5leHBvcnRzLG4pLG8ubD0hMCxvLmV4cG9ydHN9bi5tPWUsbi5jPXQsbi5kPWZ1bmN0aW9uKGUsdCxyKXtuLm8oZSx0KXx8T2JqZWN0LmRlZmluZVByb3BlcnR5KGUsdCx7ZW51bWVyYWJsZTohMCxnZXQ6cn0pfSxuLnI9ZnVuY3Rpb24oZSl7InVuZGVmaW5lZCIhPXR5cGVvZiBTeW1ib2wmJlN5bWJvbC50b1N0cmluZ1RhZyYmT2JqZWN0LmRlZmluZVByb3BlcnR5KGUsU3ltYm9sLnRvU3RyaW5nVGFnLHt2YWx1ZToiTW9kdWxlIn0pLE9iamVjdC5kZWZpbmVQcm9wZXJ0eShlLCJfX2VzTW9kdWxlIix7dmFsdWU6ITB9KX0sbi50PWZ1bmN0aW9uKGUsdCl7aWYoMSZ0JiYoZT1uKGUpKSw4JnQpcmV0dXJuIGU7aWYoNCZ0JiYib2JqZWN0Ij09dHlwZW9mIGUmJmUmJmUuX19lc01vZHVsZSlyZXR1cm4gZTt2YXIgcj1PYmplY3QuY3JlYXRlKG51bGwpO2lmKG4ucihyKSxPYmplY3QuZGVmaW5lUHJvcGVydHkociwiZGVmYXVsdCIse2VudW1lcmFibGU6ITAsdmFsdWU6ZX0pLDImdCYmInN0cmluZyIhPXR5cGVvZiBlKWZvcih2YXIgbyBpbiBlKW4uZChyLG8sZnVuY3Rpb24odCl7cmV0dXJuIGVbdF19LmJpbmQobnVsbCxvKSk7cmV0dXJuIHJ9LG4ubj1mdW5jdGlvbihlKXt2YXIgdD1lJiZlLl9fZXNNb2R1bGU/ZnVuY3Rpb24oKXtyZXR1cm4gZS5kZWZhdWx0fTpmdW5jdGlvbigpe3JldHVybiBlfTtyZXR1cm4gbi5kKHQsImEiLHQpLHR9LG4ubz1mdW5jdGlvbihlLHQpe3JldHVybiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwoZSx0KX0sbi5wPSIiLG4obi5zPTApfShbZnVuY3Rpb24oZSx0KXtQYWdlKHtkYXRhOntkZXRhaWw6e319LG9uTG9hZChlKXtjb25zb2xlLmxvZygiZSA9ICIrSlNPTi5zdHJpbmdpZnkoZSkpfSxvblVubG9hZCgpe319KX1dKTsKLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGV0YWlsLmJ1bmRsZS5qcy5tYXA=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}}";
    _pages.putIfAbsent('home', () => home);
    _pages.putIfAbsent('detail', () => detail);
    _initBasicChannel();
  }

  _initBasicChannel() async {
    _basicChannel.setMessageHandler((String message) {
      print('Flutter Received: $message');
      var jsonObj = jsonDecode(message);
      var pageId = jsonObj['pageId'];
      MessageHandler handler = _handlers[pageId];
      if (null != handler) {
        handler.onMessage(jsonObj);
      }
      return Future<String>.value("success");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _MainPage({}),
    );
  }
}

class _MainPage extends StatefulWidget {
  final Map<String, dynamic> _args;

  _MainPage(this._args);

  @override
  _MainPageState createState() => _MainPageState(_args);
}

abstract class MessageHandler {
  void onMessage(Map<String, dynamic> message);
}

class _MainPageState extends State<_MainPage> with MessageHandler {
  Map<String, dynamic> _args = Map();
  Map<String, dynamic> _data;
  String _pageCode = "";
  String _pageId = "";
  String _title = "";
  Widget _view;

  _MainPageState(this._args) {
    if (_args.containsKey("pageCode")) {
      _pageCode = _args['pageCode'];
      _args = _args['args'];
    } else {
      _pageCode = 'home';
    }
    _pageId = _pageCode + this.hashCode.toString();
    _handlers.putIfAbsent(_pageId, () => this);
  }

  _initData() async {
    _data = jsonDecode(_pages[_pageCode]);
    _create(true);
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
        args.putIfAbsent("args", () => params);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => _MainPage(args)));
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

    if (isInit) {
      _initScript(script);
      _callOnLoad();
    }
    var widget = await _createWidget(body, styles);
    setState(() {
      _view = widget;
    });
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
    //_handlers.remove(_pageId);
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
        key: Key(_view.hashCode.toString()),
        appBar: AppBar(
          title: Text(_title),
        ),
        backgroundColor: Colors.grey[200],
        body: _view);
  }

  @override
  void onMessage(Map<String, dynamic> message) {
    int type = message['type'];
    switch (type) {
      case 0: //socket
        _refresh(message);
        break;
      case 1: //onclick
        _update();
        break;
      case 2: //set_navigation_bar_title
        _updateTitle(message);
        break;
      case 3: //navigate_to
        _navigateTo(message);
        break;
    }
  }
}
