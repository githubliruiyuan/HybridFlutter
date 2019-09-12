import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/ui/ui_factory.dart';
import 'package:hybrid_flutter/util/base64.dart';
import 'package:hybrid_flutter/util/color_util.dart';

import 'entity/component.dart';
import 'entity/data.dart';
import 'entity/property.dart';

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
//    var example =
//        "{\"style\":{\".item-container\":{\"height\":\"150\",\"margin-top\":\"10\",\"margin-left\":\"10\",\"margin-right\":\"10\",\"padding\":\"10\"}},\"body\":{\"tag\":\"body\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"singlechildscrollview\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"5paH5pysMeaWh+acrDHmlofmnKwx5paH5pysMeaWh+acrDHmlofmnKwx5paH5pysMeaWh+acrDHmlofmnKwx5paH5pysMeaWh+acrDE=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"color\":\"{{color1}}\"},\"attrib\":{},\"id\":\"item-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"5paH5pysMg==\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"color\":\"{{color2}}\"},\"attrib\":{},\"id\":\"item-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"5paH5pysMw==\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"color\":\"{{color3}}\"},\"attrib\":{},\"id\":\"item-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"raisedbutton\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"5L+u5pS56aKc6Imy\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{\"onclick\":\"onclick\"},\"directives\":{},\"attribStyle\":{\"color\":\"green\"},\"attrib\":{},\"id\":\"item-container\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"color\":\"yellow\"},\"attrib\":{},\"id\":\"item-container\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},\"script\":\"IWZ1bmN0aW9uKGUpe3ZhciByPXt9O2Z1bmN0aW9uIHQobyl7aWYocltvXSlyZXR1cm4gcltvXS5leHBvcnRzO3ZhciBuPXJbb109e2k6byxsOiExLGV4cG9ydHM6e319O3JldHVybiBlW29dLmNhbGwobi5leHBvcnRzLG4sbi5leHBvcnRzLHQpLG4ubD0hMCxuLmV4cG9ydHN9dC5tPWUsdC5jPXIsdC5kPWZ1bmN0aW9uKGUscixvKXt0Lm8oZSxyKXx8T2JqZWN0LmRlZmluZVByb3BlcnR5KGUscix7ZW51bWVyYWJsZTohMCxnZXQ6b30pfSx0LnI9ZnVuY3Rpb24oZSl7InVuZGVmaW5lZCIhPXR5cGVvZiBTeW1ib2wmJlN5bWJvbC50b1N0cmluZ1RhZyYmT2JqZWN0LmRlZmluZVByb3BlcnR5KGUsU3ltYm9sLnRvU3RyaW5nVGFnLHt2YWx1ZToiTW9kdWxlIn0pLE9iamVjdC5kZWZpbmVQcm9wZXJ0eShlLCJfX2VzTW9kdWxlIix7dmFsdWU6ITB9KX0sdC50PWZ1bmN0aW9uKGUscil7aWYoMSZyJiYoZT10KGUpKSw4JnIpcmV0dXJuIGU7aWYoNCZyJiYib2JqZWN0Ij09dHlwZW9mIGUmJmUmJmUuX19lc01vZHVsZSlyZXR1cm4gZTt2YXIgbz1PYmplY3QuY3JlYXRlKG51bGwpO2lmKHQucihvKSxPYmplY3QuZGVmaW5lUHJvcGVydHkobywiZGVmYXVsdCIse2VudW1lcmFibGU6ITAsdmFsdWU6ZX0pLDImciYmInN0cmluZyIhPXR5cGVvZiBlKWZvcih2YXIgbiBpbiBlKXQuZChvLG4sZnVuY3Rpb24ocil7cmV0dXJuIGVbcl19LmJpbmQobnVsbCxuKSk7cmV0dXJuIG99LHQubj1mdW5jdGlvbihlKXt2YXIgcj1lJiZlLl9fZXNNb2R1bGU/ZnVuY3Rpb24oKXtyZXR1cm4gZS5kZWZhdWx0fTpmdW5jdGlvbigpe3JldHVybiBlfTtyZXR1cm4gdC5kKHIsImEiLHIpLHJ9LHQubz1mdW5jdGlvbihlLHIpe3JldHVybiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwoZSxyKX0sdC5wPSIiLHQodC5zPTApfShbZnVuY3Rpb24oZSxyKXtQYWdlKHtkYXRhOntjb2xvcjE6InJlZCIsY29sb3IyOiJncmVlbiIsY29sb3IzOiJibHVlIn0sb25jbGljaygpe3ZhciBlPSJibGFjayI9PT10aGlzLmRhdGEuY29sb3IxPyJncmVlbiI6ImJsYWNrIjt0aGlzLnNldERhdGEoe2NvbG9yMTplLGNvbG9yMjplLGNvbG9yMzplfSl9LG9uTG9hZChlKXt9LG9uVW5sb2FkKCl7fX0pfV0pOwovLyMgc291cmNlTWFwcGluZ1VSTD1leGFtcGxlLmJ1bmRsZS5qcy5tYXA=\",\"config\":{\"navigationBarTitleText\":\"\",\"backgroundColor\":\"#eeeeee\",\"enablePullDownRefresh\":false}}";
//    var example =
//        "{\"style\":{\".item-container\":{\"margin-top\":\"10\",\"margin-left\":\"10\",\"margin-right\":\"10\",\"padding\":\"10\",\"color\":\"white\"}},\"body\":{\"tag\":\"body\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"singlechildscrollview\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"row\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"Y2Muc2V0TmF2aWdhdGlvbkJhclRpdGxl\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"expanded\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"raisedbutton\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"6K6+572u5qCH6aKY\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{\"onclick\":\"setNavigationBarTitle\"},\"directives\":{},\"attribStyle\":{\"color\":\"green\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"item-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"row\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"Y2Muc2V0TmF2aWdhdGlvbkJhckNvbG9y\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"expanded\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"raisedbutton\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"6K6+572u6aKc6Imy\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{\"onclick\":\"setNavigationBarColor\"},\"directives\":{},\"attribStyle\":{\"color\":\"red\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"item-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"row\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"Y2Muc2V0QmFja2dyb3VuZENvbG9y\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"expanded\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"raisedbutton\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"6K6+572u6IOM5pmv\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{\"onclick\":\"setBackgroundColor\"},\"directives\":{},\"attribStyle\":{\"color\":\"blue\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"item-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"row\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"Y2Muc2hvd1RvYXN0\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"expanded\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"raisedbutton\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"VG9hc3Q=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{\"onclick\":\"showToast\"},\"directives\":{},\"attribStyle\":{\"color\":\"yellow\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"item-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"row\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"Y2Muc2hvd0xvYWRpbmc=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"text\",\"innerHTML\":\"Y2MuaGlkZUxvYWRpbmc=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"expanded\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"raisedbutton\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"TG9hZGluZw==\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{\"onclick\":\"showLoading\"},\"directives\":{},\"attribStyle\":{\"color\":\"green\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"item-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"row\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"Y2Muc3RhcnRQdWxsRG93blJlZnJlc2g=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"text\",\"innerHTML\":\"Y2Muc3RvcFB1bGxEb3duUmVmcmVzaA==\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"expanded\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"raisedbutton\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"c3RhcnQ=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{\"onclick\":\"startPullDownRefresh\"},\"directives\":{},\"attribStyle\":{\"color\":\"green\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"item-container\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},\"script\":\"IWZ1bmN0aW9uKG8pe3ZhciB0PXt9O2Z1bmN0aW9uIGUobil7aWYodFtuXSlyZXR1cm4gdFtuXS5leHBvcnRzO3ZhciByPXRbbl09e2k6bixsOiExLGV4cG9ydHM6e319O3JldHVybiBvW25dLmNhbGwoci5leHBvcnRzLHIsci5leHBvcnRzLGUpLHIubD0hMCxyLmV4cG9ydHN9ZS5tPW8sZS5jPXQsZS5kPWZ1bmN0aW9uKG8sdCxuKXtlLm8obyx0KXx8T2JqZWN0LmRlZmluZVByb3BlcnR5KG8sdCx7ZW51bWVyYWJsZTohMCxnZXQ6bn0pfSxlLnI9ZnVuY3Rpb24obyl7InVuZGVmaW5lZCIhPXR5cGVvZiBTeW1ib2wmJlN5bWJvbC50b1N0cmluZ1RhZyYmT2JqZWN0LmRlZmluZVByb3BlcnR5KG8sU3ltYm9sLnRvU3RyaW5nVGFnLHt2YWx1ZToiTW9kdWxlIn0pLE9iamVjdC5kZWZpbmVQcm9wZXJ0eShvLCJfX2VzTW9kdWxlIix7dmFsdWU6ITB9KX0sZS50PWZ1bmN0aW9uKG8sdCl7aWYoMSZ0JiYobz1lKG8pKSw4JnQpcmV0dXJuIG87aWYoNCZ0JiYib2JqZWN0Ij09dHlwZW9mIG8mJm8mJm8uX19lc01vZHVsZSlyZXR1cm4gbzt2YXIgbj1PYmplY3QuY3JlYXRlKG51bGwpO2lmKGUucihuKSxPYmplY3QuZGVmaW5lUHJvcGVydHkobiwiZGVmYXVsdCIse2VudW1lcmFibGU6ITAsdmFsdWU6b30pLDImdCYmInN0cmluZyIhPXR5cGVvZiBvKWZvcih2YXIgciBpbiBvKWUuZChuLHIsZnVuY3Rpb24odCl7cmV0dXJuIG9bdF19LmJpbmQobnVsbCxyKSk7cmV0dXJuIG59LGUubj1mdW5jdGlvbihvKXt2YXIgdD1vJiZvLl9fZXNNb2R1bGU/ZnVuY3Rpb24oKXtyZXR1cm4gby5kZWZhdWx0fTpmdW5jdGlvbigpe3JldHVybiBvfTtyZXR1cm4gZS5kKHQsImEiLHQpLHR9LGUubz1mdW5jdGlvbihvLHQpe3JldHVybiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwobyx0KX0sZS5wPSIiLGUoZS5zPTApfShbZnVuY3Rpb24obyx0KXtQYWdlKHtkYXRhOntjb2xvcnM6WyJyZWQiLCJncmVlbiIsImJsdWUiXSxiYWNrZ3JvdW5kQ29sb3JzOlsid2hpdGUiLCJncmF5IiwiI2VlZWVlZSJdLGNvdW50OjAscmFuZG9tOjB9LHNldE5hdmlnYXRpb25CYXJUaXRsZSgpe3RoaXMuZGF0YS5jb3VudCsrLGNjLnNldE5hdmlnYXRpb25CYXJUaXRsZSh7dGl0bGU6Iuiuvue9ruagh+mimCIrdGhpcy5kYXRhLmNvdW50fSl9LHNldE5hdmlnYXRpb25CYXJDb2xvcigpe3RoaXMuZGF0YS5yYW5kb20rKyx0aGlzLmRhdGEucmFuZG9tPjImJih0aGlzLmRhdGEucmFuZG9tPTApO2xldCBvPXRoaXMuZGF0YS5jb2xvcnNbdGhpcy5kYXRhLnJhbmRvbV07Y2Muc2V0TmF2aWdhdGlvbkJhckNvbG9yKHtiYWNrZ3JvdW5kQ29sb3I6b30pfSxzZXRCYWNrZ3JvdW5kQ29sb3IoKXt0aGlzLmRhdGEucmFuZG9tKyssdGhpcy5kYXRhLnJhbmRvbT4yJiYodGhpcy5kYXRhLnJhbmRvbT0wKTtsZXQgbz10aGlzLmRhdGEuYmFja2dyb3VuZENvbG9yc1t0aGlzLmRhdGEucmFuZG9tXTtjYy5zZXRCYWNrZ3JvdW5kQ29sb3Ioe2JhY2tncm91bmRDb2xvcjpvfSl9LHNob3dUb2FzdCgpe2NjLnNob3dUb2FzdCh7dGl0bGU6IkknbSB0b2FzdCEifSl9LHNob3dMb2FkaW5nKCl7Y2Muc2hvd0xvYWRpbmcoe30pO3ZhciBvPXNldFRpbWVvdXQoZnVuY3Rpb24oLi4ubyl7Y29uc29sZS5sb2coSlNPTi5zdHJpbmdpZnkoLi4ubykpLGNjLmhpZGVMb2FkaW5nKCl9LDNlMywiMSIsIjIiKTtjb25zb2xlLmxvZygidGltZXJJZCA9ICIrbyl9LHN0YXJ0UHVsbERvd25SZWZyZXNoKCl7Y2Muc3RhcnRQdWxsRG93blJlZnJlc2goKX0sb25jbGljaygpe30sb25Mb2FkKG8pe30sb25QdWxsRG93blJlZnJlc2goKXtjb25zb2xlLmxvZygib25QdWxsRG93blJlZnJlc2giKSxzZXRUaW1lb3V0KGZ1bmN0aW9uKCl7Y2Muc3RvcFB1bGxEb3duUmVmcmVzaCgpfSwzZTMpfSxvblVubG9hZCgpe319KX1dKTsKLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZXhhbXBsZS5idW5kbGUuanMubWFw\",\"config\":{\"navigationBarTitleText\":\"\",\"backgroundColor\":\"#eeeeee\",\"enablePullDownRefresh\":true}}";
    var example =
        "{\"style\":{\".item-container\":{\"height\":\"150\",\"margin-top\":\"10\",\"margin-left\":\"10\",\"margin-right\":\"10\",\"padding\":\"10\"}},\"body\":{\"tag\":\"body\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"singlechildscrollview\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"row\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3t0ZXh0ICsgaW5kZXggKyBjb2xvcnNbaW5kZXhdfX0=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{\"repeat\":{\"name\":\"or\",\"expression\":\"{{list}}\",\"item\":\"item\",\"index\":\"index\"}},\"attribStyle\":{\"color\":\"{{colors[index]}}\",\"width\":\"85\",\"height\":\"15\",\"margin-left\":\"5\",\"text\":\"{{colors[index]}}\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"raisedbutton\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"5L+u5pS56aKc6Imy\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"font-size\":\"14px\",\"color\":\"white\"},\"attrib\":{}}],\"datasets\":{},\"events\":{\"onclick\":\"onclick\"},\"directives\":{},\"attribStyle\":{\"color\":\"green\"},\"attrib\":{},\"id\":\"item-container\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"color\":\"yellow\"},\"attrib\":{},\"id\":\"item-container\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},\"script\":\"IWZ1bmN0aW9uKGUpe3ZhciB0PXt9O2Z1bmN0aW9uIHIobil7aWYodFtuXSlyZXR1cm4gdFtuXS5leHBvcnRzO3ZhciBvPXRbbl09e2k6bixsOiExLGV4cG9ydHM6e319O3JldHVybiBlW25dLmNhbGwoby5leHBvcnRzLG8sby5leHBvcnRzLHIpLG8ubD0hMCxvLmV4cG9ydHN9ci5tPWUsci5jPXQsci5kPWZ1bmN0aW9uKGUsdCxuKXtyLm8oZSx0KXx8T2JqZWN0LmRlZmluZVByb3BlcnR5KGUsdCx7ZW51bWVyYWJsZTohMCxnZXQ6bn0pfSxyLnI9ZnVuY3Rpb24oZSl7InVuZGVmaW5lZCIhPXR5cGVvZiBTeW1ib2wmJlN5bWJvbC50b1N0cmluZ1RhZyYmT2JqZWN0LmRlZmluZVByb3BlcnR5KGUsU3ltYm9sLnRvU3RyaW5nVGFnLHt2YWx1ZToiTW9kdWxlIn0pLE9iamVjdC5kZWZpbmVQcm9wZXJ0eShlLCJfX2VzTW9kdWxlIix7dmFsdWU6ITB9KX0sci50PWZ1bmN0aW9uKGUsdCl7aWYoMSZ0JiYoZT1yKGUpKSw4JnQpcmV0dXJuIGU7aWYoNCZ0JiYib2JqZWN0Ij09dHlwZW9mIGUmJmUmJmUuX19lc01vZHVsZSlyZXR1cm4gZTt2YXIgbj1PYmplY3QuY3JlYXRlKG51bGwpO2lmKHIucihuKSxPYmplY3QuZGVmaW5lUHJvcGVydHkobiwiZGVmYXVsdCIse2VudW1lcmFibGU6ITAsdmFsdWU6ZX0pLDImdCYmInN0cmluZyIhPXR5cGVvZiBlKWZvcih2YXIgbyBpbiBlKXIuZChuLG8sZnVuY3Rpb24odCl7cmV0dXJuIGVbdF19LmJpbmQobnVsbCxvKSk7cmV0dXJuIG59LHIubj1mdW5jdGlvbihlKXt2YXIgdD1lJiZlLl9fZXNNb2R1bGU/ZnVuY3Rpb24oKXtyZXR1cm4gZS5kZWZhdWx0fTpmdW5jdGlvbigpe3JldHVybiBlfTtyZXR1cm4gci5kKHQsImEiLHQpLHR9LHIubz1mdW5jdGlvbihlLHQpe3JldHVybiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwoZSx0KX0sci5wPSIiLHIoci5zPTApfShbZnVuY3Rpb24oZSx0KXtQYWdlKHtkYXRhOntjb2xvcnM6WyJyZWQiLCJncmVlbiIsImJsdWUiXSx0ZXh0OiJ4eHgiLGxpc3Q6WzEsMiwzXX0sb25jbGljaygpe3ZhciBlPSJibGFjayI9PT10aGlzLmRhdGEuY29sb3IxPyJncmVlbiI6ImJsYWNrIix0PTM9PT10aGlzLmRhdGEubGlzdC5sZW5ndGg/WzEsMl06WzEsMiwzXSxyPSJ4eHgiPT09dGhpcy5kYXRhLnRleHQ/Inh4eCI6Inl5eSI7dGhpcy5zZXREYXRhKHtjb2xvcjE6ZSxjb2xvcjI6ZSxsaXN0OnQsdGV4dDpyfSl9LG9uTG9hZChlKXt9LG9uVW5sb2FkKCl7fX0pfV0pOwovLyMgc291cmNlTWFwcGluZ1VSTD1leGFtcGxlLmJ1bmRsZS5qcy5tYXA=\",\"config\":{\"navigationBarTitleText\":\"\",\"backgroundColor\":\"#eeeeee\",\"enablePullDownRefresh\":false}}";
    var home =
        "{\"style\":{\".btn-container\":{\"margin-top\":\"10\",\"margin-left\":\"10\",\"margin-right\":\"10\"},\".raised-button\":{\"color\":\"white\"},\".image-container\":{\"width\":\"100px\",\"height\":\"100px\",\"padding\":\"5\"},\".column-text\":{\"cross-axis-alignment\":\"start\"},\".text-title\":{\"font-size\":\"14px\",\"color\":\"black\"},\".text-publisher\":{\"font-size\":\"12px\",\"color\":\"gray\"},\".text-summary\":{\"font-size\":\"12px\",\"color\":\"gray\"}},\"body\":{\"tag\":\"body\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"singlechildscrollview\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"raisedbutton\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"row\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"image\",\"innerHTML\":\"\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"src\":\"{{item.image}}\"},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"image-container\"},{\"tag\":\"expanded\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3tpdGVtLnRpdGxlfX0=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"text-title\"},{\"tag\":\"text\",\"innerHTML\":\"e3tpdGVtLnB1Ymxpc2hlcn19\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"text-publisher\"},{\"tag\":\"text\",\"innerHTML\":\"e3tpdGVtLnN1bW1hcnkuc3Vic3RyaW5nKDAsIDIwKSArICcuLi4nfX0=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"text-summary\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"column-text\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{\"ex\":\"{{index}}\"},\"events\":{\"onclick\":\"onItemClick\"},\"directives\":{},\"attribStyle\":{},\"attrib\":{\"data-index\":\"{{index}}\"},\"id\":\"raised-button\"}],\"datasets\":{},\"events\":{},\"directives\":{\"repeat\":{\"name\":\"or\",\"expression\":\"{{list}}\",\"item\":\"item\",\"index\":\"index\"}},\"attribStyle\":{},\"attrib\":{},\"id\":\"btn-container\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},\"script\":\"IWZ1bmN0aW9uKGUpe3ZhciB0PXt9O2Z1bmN0aW9uIG8obil7aWYodFtuXSlyZXR1cm4gdFtuXS5leHBvcnRzO3ZhciByPXRbbl09e2k6bixsOiExLGV4cG9ydHM6e319O3JldHVybiBlW25dLmNhbGwoci5leHBvcnRzLHIsci5leHBvcnRzLG8pLHIubD0hMCxyLmV4cG9ydHN9by5tPWUsby5jPXQsby5kPWZ1bmN0aW9uKGUsdCxuKXtvLm8oZSx0KXx8T2JqZWN0LmRlZmluZVByb3BlcnR5KGUsdCx7ZW51bWVyYWJsZTohMCxnZXQ6bn0pfSxvLnI9ZnVuY3Rpb24oZSl7InVuZGVmaW5lZCIhPXR5cGVvZiBTeW1ib2wmJlN5bWJvbC50b1N0cmluZ1RhZyYmT2JqZWN0LmRlZmluZVByb3BlcnR5KGUsU3ltYm9sLnRvU3RyaW5nVGFnLHt2YWx1ZToiTW9kdWxlIn0pLE9iamVjdC5kZWZpbmVQcm9wZXJ0eShlLCJfX2VzTW9kdWxlIix7dmFsdWU6ITB9KX0sby50PWZ1bmN0aW9uKGUsdCl7aWYoMSZ0JiYoZT1vKGUpKSw4JnQpcmV0dXJuIGU7aWYoNCZ0JiYib2JqZWN0Ij09dHlwZW9mIGUmJmUmJmUuX19lc01vZHVsZSlyZXR1cm4gZTt2YXIgbj1PYmplY3QuY3JlYXRlKG51bGwpO2lmKG8ucihuKSxPYmplY3QuZGVmaW5lUHJvcGVydHkobiwiZGVmYXVsdCIse2VudW1lcmFibGU6ITAsdmFsdWU6ZX0pLDImdCYmInN0cmluZyIhPXR5cGVvZiBlKWZvcih2YXIgciBpbiBlKW8uZChuLHIsZnVuY3Rpb24odCl7cmV0dXJuIGVbdF19LmJpbmQobnVsbCxyKSk7cmV0dXJuIG59LG8ubj1mdW5jdGlvbihlKXt2YXIgdD1lJiZlLl9fZXNNb2R1bGU/ZnVuY3Rpb24oKXtyZXR1cm4gZS5kZWZhdWx0fTpmdW5jdGlvbigpe3JldHVybiBlfTtyZXR1cm4gby5kKHQsImEiLHQpLHR9LG8ubz1mdW5jdGlvbihlLHQpe3JldHVybiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwoZSx0KX0sby5wPSIiLG8oby5zPTEpfShbLGZ1bmN0aW9uKGUsdCl7UGFnZSh7ZGF0YTp7bGlzdDpbXX0sb25Mb2FkKGUpe2NjLnNldE5hdmlnYXRpb25CYXJUaXRsZSh7dGl0bGU6IlB5dGhvbuezu+WIl+S4m+S5piJ9KSxjYy5zaG93TG9hZGluZyh7fSksdGhpcy5kb1JlcXVlc3QoITApfSxkb1JlcXVlc3QoZSl7bGV0IHQ9dGhpcztjYy5yZXF1ZXN0KHt1cmw6Imh0dHA6Ly9xYS5zY20ucHBtb25leS5jb206NzMwMC9tb2NrLzVkNzYzZjBlYTNjYzcxMDA4YmMyM2IyYS9ib29rL2l0ZW1zIixkYXRhOnt9LGhlYWRlcjp7fSxtZXRob2Q6ImdldCIsc3VjY2VzczpmdW5jdGlvbihlKXt0LnNldERhdGEoe2xpc3Q6ZS5ib2R5LmJvb2tzfSksY2Muc2hvd1RvYXN0KHt0aXRsZToi5Yqg6L295oiQ5YqfIn0pfSxmYWlsOmZ1bmN0aW9uKGUpe2NvbnNvbGUubG9nKCJyZXF1ZXN0IGVycm9yOiIrSlNPTi5zdHJpbmdpZnkoZSkpLGNjLnNob3dUb2FzdCh7dGl0bGU6IuWKoOi9veWksei0pSJ9KX0sY29tcGxldGU6ZnVuY3Rpb24oKXtjb25zb2xlLmxvZygicmVxdWVzdCBjb21wbGV0ZSIpLGU/Y2MuaGlkZUxvYWRpbmcoKTpjYy5zdG9wUHVsbERvd25SZWZyZXNoKCl9fSl9LG9uSXRlbUNsaWNrKGUpe3ZhciB0PXRoaXMuZGF0YS5saXN0W2UudGFyZ2V0LmRhdGFzZXQuaW5kZXhdO2NjLm5hdmlnYXRlVG8oe3VybDoiZGV0YWlsP2l0ZW09IitKU09OLnN0cmluZ2lmeSh0KX0pfSxvblB1bGxEb3duUmVmcmVzaCgpe2NvbnNvbGUubG9nKCJvblB1bGxEb3duUmVmcmVzaCIpLHRoaXMuZG9SZXF1ZXN0KCExKX0sb25VbmxvYWQoKXt9fSl9XSk7Ci8vIyBzb3VyY2VNYXBwaW5nVVJMPWhvbWUuYnVuZGxlLmpzLm1hcA==\",\"config\":{\"navigationBarTitleText\":\"\",\"backgroundColor\":\"#eeeeee\",\"enablePullDownRefresh\":true}}";
    var detail =
        "{\"style\":{\".scroll-container\":{\"width-factor\":\"1\",\"height-factor\":\"1\"},\".column\":{\"cross-axis-alignment\":\"start\"},\".row-container\":{\"color\":\"white\",\"padding\":\"10\"},\".image-container\":{\"width\":\"120px\",\"height\":\"160px\",\"margin-right\":\"5\"},\".title\":{\"font-size\":\"14px\",\"color\":\"black\"},\".summary-container\":{\"color\":\"white\",\"padding\":\"10\"},\".label-container\":{\"padding-left\":\"10\",\"padding-top\":\"5\",\"padding-bottom\":\"5\"},\".summary-label\":{\"font-size\":\"16\",\"color\":\"green\"},\".catalog-container\":{\"color\":\"white\",\"padding-top\":\"10\",\"padding-left\":\"10\",\"padding-right\":\"10\"},\".more-container\":{\"padding-left\":\"10\",\"padding-right\":\"10\",\"padding-bottom\":\"10\",\"color\":\"white\"},\".more-btn\":{\"color\":\"white\"},\".more\":{\"color\":\"blue\"}},\"body\":{\"tag\":\"body\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"fractionallysizedbox\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"singlechildscrollview\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"row\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"image\",\"innerHTML\":\"\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{\"src\":\"{{detail.image}}\"},\"attrib\":{},\"id\":\"image\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"image-container\"},{\"tag\":\"column\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3si5Lmm5ZCN77yaIiArIGRldGFpbC50aXRsZX19\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"title\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3si5L2c6ICF77yaIiArIGRldGFpbC5hdXRob3J9fQ==\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"title\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3si5Ye654mI56S+77yaIiArIGRldGFpbC5wdWJsaXNoZXJ9fQ==\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"title\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3si5Ymv5qCH6aKY77yaIiArIGRldGFpbC5zdWJ0aXRsZX19\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"title\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"column\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"row-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"5YaF5a65566A5LuL\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"summary-label\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"label-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3tkZXRhaWwuc3VtbWFyeX19\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"summary\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"summary-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"5L2c6ICF566A5LuL\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"summary-label\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"label-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3tkZXRhaWwuYXV0aG9yX2ludHJvfX0=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"author\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"summary-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"55uu5b2V\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"summary-label\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"label-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3tjYXRhbG9nU2hvcnR9fQ==\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"catalog\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"catalog-container\"},{\"tag\":\"container\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"raisedbutton\",\"innerHTML\":\"\",\"childNodes\":[{\"tag\":\"text\",\"innerHTML\":\"e3tidG5UZXh0fX0=\",\"childNodes\":[],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"more\"}],\"datasets\":{},\"events\":{\"onclick\":\"onMoreClick\"},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"more-btn\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"more-container\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"column\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{},\"id\":\"scroll-container\"}],\"datasets\":{},\"events\":{},\"directives\":{},\"attribStyle\":{},\"attrib\":{}},\"script\":\"IWZ1bmN0aW9uKHQpe3ZhciBlPXt9O2Z1bmN0aW9uIG4ocil7aWYoZVtyXSlyZXR1cm4gZVtyXS5leHBvcnRzO3ZhciBvPWVbcl09e2k6cixsOiExLGV4cG9ydHM6e319O3JldHVybiB0W3JdLmNhbGwoby5leHBvcnRzLG8sby5leHBvcnRzLG4pLG8ubD0hMCxvLmV4cG9ydHN9bi5tPXQsbi5jPWUsbi5kPWZ1bmN0aW9uKHQsZSxyKXtuLm8odCxlKXx8T2JqZWN0LmRlZmluZVByb3BlcnR5KHQsZSx7ZW51bWVyYWJsZTohMCxnZXQ6cn0pfSxuLnI9ZnVuY3Rpb24odCl7InVuZGVmaW5lZCIhPXR5cGVvZiBTeW1ib2wmJlN5bWJvbC50b1N0cmluZ1RhZyYmT2JqZWN0LmRlZmluZVByb3BlcnR5KHQsU3ltYm9sLnRvU3RyaW5nVGFnLHt2YWx1ZToiTW9kdWxlIn0pLE9iamVjdC5kZWZpbmVQcm9wZXJ0eSh0LCJfX2VzTW9kdWxlIix7dmFsdWU6ITB9KX0sbi50PWZ1bmN0aW9uKHQsZSl7aWYoMSZlJiYodD1uKHQpKSw4JmUpcmV0dXJuIHQ7aWYoNCZlJiYib2JqZWN0Ij09dHlwZW9mIHQmJnQmJnQuX19lc01vZHVsZSlyZXR1cm4gdDt2YXIgcj1PYmplY3QuY3JlYXRlKG51bGwpO2lmKG4ucihyKSxPYmplY3QuZGVmaW5lUHJvcGVydHkociwiZGVmYXVsdCIse2VudW1lcmFibGU6ITAsdmFsdWU6dH0pLDImZSYmInN0cmluZyIhPXR5cGVvZiB0KWZvcih2YXIgbyBpbiB0KW4uZChyLG8sZnVuY3Rpb24oZSl7cmV0dXJuIHRbZV19LmJpbmQobnVsbCxvKSk7cmV0dXJuIHJ9LG4ubj1mdW5jdGlvbih0KXt2YXIgZT10JiZ0Ll9fZXNNb2R1bGU/ZnVuY3Rpb24oKXtyZXR1cm4gdC5kZWZhdWx0fTpmdW5jdGlvbigpe3JldHVybiB0fTtyZXR1cm4gbi5kKGUsImEiLGUpLGV9LG4ubz1mdW5jdGlvbih0LGUpe3JldHVybiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwodCxlKX0sbi5wPSIiLG4obi5zPTApfShbZnVuY3Rpb24odCxlKXtQYWdlKHtkYXRhOntkZXRhaWw6e30sY2F0YWxvZ1Nob3J0OiIiLHNob3dMb25nOiExLGJ0blRleHQ6Iuafpeeci+abtOWkmiJ9LG9uTG9hZCh0KXt2YXIgZT1KU09OLnBhcnNlKHQuaXRlbSk7Y2Muc2V0TmF2aWdhdGlvbkJhclRpdGxlKHt0aXRsZTplLnRpdGxlfSk7dmFyIG49ZS5jYXRhbG9nO24ubGVuZ3RoPjUwJiYobj1uLnN1YnN0cmluZygwLDUwKSsiLi4uIiksdGhpcy5zZXREYXRhKHtkZXRhaWw6ZSxjYXRhbG9nU2hvcnQ6bn0pfSxvbk1vcmVDbGljayh0KXt2YXIgZT0hdGhpcy5kYXRhLnNob3dMb25nLG49dGhpcy5kYXRhLmRldGFpbC5jYXRhbG9nLHI9IuaUtui1t+abtOWkmiI7ZXx8KG4ubGVuZ3RoPjUwJiYobj1uLnN1YnN0cmluZygwLDUwKSsiLi4uIikscj0i5p+l55yL5pu05aSaIiksdGhpcy5zZXREYXRhKHtzaG93TG9uZzplLGNhdGFsb2dTaG9ydDpuLGJ0blRleHQ6cn0pfSxvblVubG9hZCgpe319KX1dKTsKLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGV0YWlsLmJ1bmRsZS5qcy5tYXA=\",\"config\":{\"navigationBarTitleText\":\"\",\"backgroundColor\":\"#eeeeee\"}}";
    _pages.putIfAbsent('home', () => home);
    _pages.putIfAbsent('detail', () => detail);
    _pages.putIfAbsent('example', () => example);
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
      } else {
        // 实时调试socket过来的数据
        var jsonObject = jsonDecode(jsonObj['message']);
        var pageCode = jsonObject['pageCode'];
        var content = jsonObject['content'];
        _pages.putIfAbsent(pageCode, () => content);
        _handlers.forEach((k, v) {
          if (k.startsWith(pageCode)) {
            v.onMessage(jsonObj);
          }
        });
      }
      return Future<String>.value("success");
    });
  }

  @override
  Widget build(BuildContext context) {
//    return MaterialApp(home: _MainPage({}));
    return MaterialApp(home: _TestPage());
  }
}

class _TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TestPageState();
  }
}

class _TestPageState extends State<_TestPage> {
  @override
  Widget build(BuildContext context) {
    Component component = Component();
    component.id = "x1";
    var text = Property('未实现控件');
    var font = Property('14');
    var color = Property('red');
    component.properties = Map();
    component.properties.putIfAbsent('font-size', () => font);
    component.properties.putIfAbsent('color', () => color);
    component.properties.putIfAbsent('innerHTML', () => text);
    ValueNotifier<Data> valueNotifier = ValueNotifier(Data(component.properties));


    var textW = ValueListenableBuilder(
        builder:
            (BuildContext context, Data data, Widget child) {
          return Text(data.map['innerHTML'].getValue(), style: TextStyle(color: Colors.white, fontSize: 18));
        },
        valueListenable: valueNotifier);

    var container =
        Container(width: 100, height: 100, color: Colors.green, child: textW);

    return Scaffold(
      appBar: AppBar(
        title: Text("TEST"),
      ),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => _MainPage({})));
//          component.properties['innerHTML'].setValue("1111");
//          valueNotifier.value = Data(component.properties);
        });
      }),
      body: container,
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

  Color _appBarColor;
  Color _backgroundColor;
  bool _enablePullDownRefresh;

  String _pageCode = "";
  String _pageId = "";
  String _title = "";
  Widget _tree;

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;
  Completer<bool> _completer;

  UIFactory _factory;

  _MainPageState(this._args) {
    if (_args.containsKey("pageCode")) {
      _pageCode = _args['pageCode'];
      _args = _args['args'];
    } else {
      _pageCode = 'example';
    }
    _appBarColor = Colors.blue;
    _backgroundColor = Colors.grey[200];
    _enablePullDownRefresh = false;
    _pageId = _pageCode + this.hashCode.toString();
    _factory = UIFactory(_pageId, _methodChannel);
    _handlers.putIfAbsent(_pageId, () => this);
  }

  void _socket(Map<String, dynamic> map) {
    if (null == context) return;
    if (null != _factory) {
      _factory.clear();
      _callOnUnload();
    }
    var jsonObject = jsonDecode(map['message']);
    var pageCode = jsonObject['pageCode'];
    var content = jsonObject['content'];
    if (_pageCode == pageCode) {
      _data = jsonDecode(content);
      _factory.clear();
      _create();
    }
  }

  Future _update(Map<String, dynamic> map) async {
    var jsonObject = jsonDecode(map['message']);
    _factory.updateTree(jsonObject);
  }

  void _updateTitle(Map<String, dynamic> map) {
    setState(() {
      _title = map['message'];
    });
  }

  void _setNavigationBarColor(Map<String, dynamic> map) {
    setState(() {
      _appBarColor = parseColor(map['message'], defaultValue: Colors.blue);
    });
  }

  void _setBackgroundColor(Map<String, dynamic> map) {
    setState(() {
      _backgroundColor =
          parseColor(map['message'], defaultValue: Colors.grey[200]);
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

  void _create() async {
    var body = _data['body'];
    var styles = _data['style'];
    var script = _data['script'];
    var config = _data['config'];
    if (null == script) {
      script = "";
    }

    _initConfig(config);
    _initScript(script);
    _callOnLoad();
    var component = await _factory.createComponentTree(null, body, styles);
    setState(() {
      _tree = _factory.createWidgetTree(null, component);
    });
  }

  void _initConfig(Map<String, dynamic> config) {
    if (null == config) {
      return;
    }
    _title = config['navigationBarTitleText'];
    _appBarColor = parseColor(config['navigationBarBackgroundColor'],
        defaultValue: Colors.blue);
    _backgroundColor =
        parseColor(config['backgroundColor'], defaultValue: Colors.grey[200]);
    _enablePullDownRefresh = config['enablePullDownRefresh'];
  }

  @override
  void initState() {
    super.initState();
//    print("lifecycle initState $_pageId");
    _data = jsonDecode(_pages[_pageCode]);
    _create();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
//    print("lifecycle didChangeDependencies $_pageId");
  }

  @override
  void dispose() {
    super.dispose();
//    print("lifecycle dispose $_pageId");
    _handlers.remove(_pageId);
    _factory.clear();
    _callOnUnload();
  }

  void _initScript(String script) {
    _methodChannel.invokeMethod(
        "attachPage", {"pageId": _pageId, "script": decodeBase64(script)});
    _methodChannel.invokeMethod("initComplete", {"pageId": _pageId});
  }

  void _callOnLoad() {
    _methodChannel
        .invokeMethod("onLoad", {"pageId": _pageId, "args": jsonEncode(_args)});
  }

  void _callOnUnload() {
    _methodChannel.invokeMethod("onUnload", {"pageId": _pageId});
  }

  void _startPullDownRefresh(Map<String, dynamic> map) {
    if (null != _refreshIndicatorKey) {
      _refreshIndicatorKey.currentState.show();
    }
  }

  void _stopPullDownRefresh(Map<String, dynamic> map) {
    if (null != _completer) {
      _completer.complete(true);
    }
  }

  Future<void> _onRefresh() {
    _methodChannel.invokeMethod("onPullDownRefresh", {"pageId": _pageId});
    _completer = new Completer<bool>();
    return _completer.future.then((bool success) {
      return success;
    });
  }

  @override
  Widget build(BuildContext context) {
    var child = _tree;
    if (null != _enablePullDownRefresh &&
        _enablePullDownRefresh &&
        null != _tree) {
      _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
      child = RefreshIndicator(
          key: _refreshIndicatorKey, onRefresh: _onRefresh, child: _tree);
    }

    return Scaffold(
        key: PageStorageKey(_tree),
        appBar: AppBar(
          title: Text(_title),
          centerTitle: true,
          backgroundColor: _appBarColor,
        ),
        backgroundColor: _backgroundColor,
        body: child);
  }

  @override
  void onMessage(Map<String, dynamic> message) {
    int type = message['type'];
    switch (type) {
      case 0: //socket
        _socket(message);
        break;
      case 1: //onclick setData
        _update(message);
        break;
      case 2: //set_navigation_bar_title
        _updateTitle(message);
        break;
      case 3: //navigate_to
        _navigateTo(message);
        break;
      case 4: //set_navigation_bar_color
        _setNavigationBarColor(message);
        break;
      case 5: //set_background_color
        _setBackgroundColor(message);
        break;
      case 6: //start_pull_down_refresh
        _startPullDownRefresh(message);
        break;
      case 7: //stop_pull_down_refresh
        _stopPullDownRefresh(message);
        break;
    }
  }
}
