import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/property.dart';

const String TYPE_TAP = "tab";
const String TYPE_SCROLL = "scroll";

String _createTapEvent(String id, Map<String, dynamic> dataSet, String type) {
  Map<String, dynamic> target = Map();
  target.putIfAbsent('id', () => id);
  target.putIfAbsent('dataset', () => dataSet);
  Map<String, dynamic> event = Map();
  event.putIfAbsent('type', () => type);
  event.putIfAbsent('target', () => target);
  return jsonEncode(event);
}

String _createScrollEvent(String id, double offset, String type) {
  Map<String, dynamic> detail = Map();
  detail.putIfAbsent('id', () => id);
  detail.putIfAbsent('offset', () => offset);
  Map<String, dynamic> event = Map();
  event.putIfAbsent('type', () => type);
  event.putIfAbsent('detail', () => detail);
  return jsonEncode(event);
}

onTapEvent(MethodChannel methodChannel, String pageId, String id,
    Map<String, Property> properties, String event) {
  var prefix = 'data-';
  var dataSet = Map<String, dynamic>();
  properties.forEach((k, v) {
    if (k.startsWith(prefix)) {
      var key = k.substring(prefix.length);
      try {
        dataSet.putIfAbsent(key, jsonDecode(v.getValue()));
      } catch (e) {
        dataSet.putIfAbsent(key, () => v.getValue());
      }
    }
  });
  var func = event.replaceAll('()', '');
  String json = _createTapEvent(id, dataSet, TYPE_TAP);
  print('json = $json');
  methodChannel
      .invokeMethod('event', {'pageId': pageId, 'event': func, 'data': json});
}

onScrollEvent(MethodChannel methodChannel, String pageId, String id,
    String event, double offset) {
  var func = event.replaceAll('()', '');
  String json = _createScrollEvent(id, offset, TYPE_SCROLL);
  print('json = $json');
  methodChannel
      .invokeMethod('event', {'pageId': pageId, 'event': func, 'data': json});
}
