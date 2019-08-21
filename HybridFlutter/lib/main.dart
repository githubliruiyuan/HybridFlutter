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
    var home = "{\"style\":{\".btn-container\":{\"margin-top\":\"10\",\"margin-left\":\"10\",\"margin-right\":\"10\"},\".raisedbutton\":{\"color\":\"white\"},\".image-container\":{\"width\":\"100px\",\"height\":\"100px\",\"padding\":\"5\"},\".column-text\":{\"cross-axis-alignment\":\"start\"},\".text-title\":{\"font-size\":\"14px\",\"color\":\"black\"},\".text-publisher\":{\"font-size\":\"12px\",\"color\":\"gray\"},\".text-summary\":{\"font-size\":\"12px\",\"color\":\"gray\"}},\"body\":{\"tag\":\"body\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"singlechildscrollview\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"raisedbutton\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"row\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"image\",\"innerHTML\":\"\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"src\":\"{{item.images.medium}}\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"image-container\"},{\"tag\":\"expanded\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3tpdGVtLnRpdGxlfX0=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"text-title\"},{\"tag\":\"text\",\"innerHTML\":\"e3tpdGVtLnB1Ymxpc2hlcn19\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"text-publisher\"},{\"tag\":\"text\",\"innerHTML\":\"e3tpdGVtLnN1bW1hcnkuc3Vic3RyaW5nKDAsIDIwKSArICcuLi4nfX0=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"text-summary\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"column-text\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{\"onclick\":\"onItemClick\"},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"raisedbutton\"}],\"datasets\":{},\"events\":{},\"directives\":{\"repeat\":{\"name\":\"or\",\"expression\":\"{{list}}\",\"item\":\"item\",\"index\":\"index\"}},\"attribStyle\":{},\"attrib\":{},\"id\":\"btn-container\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},\"type\":{},\"align\":{},\"description\":{},\"script\":{\"tag\":\"script\",\"innerHTML\":\"IWZ1bmN0aW9uKGUpe3ZhciB0PXt9O2Z1bmN0aW9uIG8obil7aWYodFtuXSlyZXR1cm4gdFtuXS5leHBvcnRzO3ZhciByPXRbbl09e2k6bixsOiExLGV4cG9ydHM6e319O3JldHVybiBlW25dLmNhbGwoci5leHBvcnRzLHIsci5leHBvcnRzLG8pLHIubD0hMCxyLmV4cG9ydHN9by5tPWUsby5jPXQsby5kPWZ1bmN0aW9uKGUsdCxuKXtvLm8oZSx0KXx8T2JqZWN0LmRlZmluZVByb3BlcnR5KGUsdCx7ZW51bWVyYWJsZTohMCxnZXQ6bn0pfSxvLnI9ZnVuY3Rpb24oZSl7InVuZGVmaW5lZCIhPXR5cGVvZiBTeW1ib2wmJlN5bWJvbC50b1N0cmluZ1RhZyYmT2JqZWN0LmRlZmluZVByb3BlcnR5KGUsU3ltYm9sLnRvU3RyaW5nVGFnLHt2YWx1ZToiTW9kdWxlIn0pLE9iamVjdC5kZWZpbmVQcm9wZXJ0eShlLCJfX2VzTW9kdWxlIix7dmFsdWU6ITB9KX0sby50PWZ1bmN0aW9uKGUsdCl7aWYoMSZ0JiYoZT1vKGUpKSw4JnQpcmV0dXJuIGU7aWYoNCZ0JiYib2JqZWN0Ij09dHlwZW9mIGUmJmUmJmUuX19lc01vZHVsZSlyZXR1cm4gZTt2YXIgbj1PYmplY3QuY3JlYXRlKG51bGwpO2lmKG8ucihuKSxPYmplY3QuZGVmaW5lUHJvcGVydHkobiwiZGVmYXVsdCIse2VudW1lcmFibGU6ITAsdmFsdWU6ZX0pLDImdCYmInN0cmluZyIhPXR5cGVvZiBlKWZvcih2YXIgciBpbiBlKW8uZChuLHIsZnVuY3Rpb24odCl7cmV0dXJuIGVbdF19LmJpbmQobnVsbCxyKSk7cmV0dXJuIG59LG8ubj1mdW5jdGlvbihlKXt2YXIgdD1lJiZlLl9fZXNNb2R1bGU/ZnVuY3Rpb24oKXtyZXR1cm4gZS5kZWZhdWx0fTpmdW5jdGlvbigpe3JldHVybiBlfTtyZXR1cm4gby5kKHQsImEiLHQpLHR9LG8ubz1mdW5jdGlvbihlLHQpe3JldHVybiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwoZSx0KX0sby5wPSIiLG8oby5zPTApfShbZnVuY3Rpb24oZSx0KXtQYWdlKHtkYXRhOntsaXN0OltdfSxvbkxvYWQoZSl7Y2Muc2V0TmF2aWdhdGlvbkJhclRpdGxlKHt0aXRsZToiUHl0aG9u57O75YiX5Lib5LmmIn0pLGNjLnNob3dMb2FkaW5nKHttZXNzYWdlOiLmraPlnKjnjqnlkb3liqDovb0uLi4ifSk7bGV0IHQ9dGhpcztjYy5yZXF1ZXN0KHt1cmw6Imh0dHBzOi8vd3d3LmVhc3ktbW9jay5jb20vbW9jay81YWI0NjIzNmUxYzE3YjNiMmNjNTU4NDMvZXhhbXBsZS9ib29rcyIsZGF0YTp7fSxoZWFkZXI6e30sbWV0aG9kOiJnZXQiLHN1Y2Nlc3M6ZnVuY3Rpb24oZSl7dC5zZXREYXRhKHtsaXN0OmUuYm9keS5ib29rc30pfSxmYWlsOmZ1bmN0aW9uKGUpe2NvbnNvbGUubG9nKCJyZXF1ZXN0IGVycm9yOiIrSlNPTi5zdHJpbmdpZnkoZSkpfSxjb21wbGV0ZTpmdW5jdGlvbigpe2NvbnNvbGUubG9nKCJyZXF1ZXN0IGNvbXBsZXRlIiksY2MuaGlkZUxvYWRpbmcoKX19KX0sb25JdGVtQ2xpY2soZSl7Y29uc29sZS5sb2coSlNPTi5zdHJpbmdpZnkoZSkpLGNjLm5hdmlnYXRlVG8oe3VybDoiaG9tZT9hPTEmYj0yIn0pfSxvblVubG9hZCgpe319KX1dKTsKLy8jIHNvdXJjZU1hcHBpbmdVUkw9aG9tZS5idW5kbGUuanMubWFw\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}}";
    _pages.putIfAbsent('home', () => home);
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
      _args.remove("pageCode");
    } else {
      _pageCode = 'home';
    }
    _pageId = _pageCode + this.hashCode.toString();
  }

  _initData() async {
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
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => _MainPage(args)));
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
        backgroundColor: Colors.grey[200],
        body: view);
  }
}
