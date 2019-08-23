import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_app/entity/property.dart';

String createEvent(String id, Map<String, dynamic> dataSet, String type) {
  Map<String, dynamic> target = Map();
  target.putIfAbsent('id', () => id);
  target.putIfAbsent('dataset', () => dataSet);
  Map<String, dynamic> event = Map();
  event.putIfAbsent('type', () => type);
  event.putIfAbsent('target', () => target);
  return jsonEncode(event);
}

onclickEvent(MethodChannel methodChannel, String pageId, String id,
    Map<String, Property> properties, Map<String, dynamic> events) {
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
  String onclick = events['onclick'];
  onclick = onclick.replaceAll('()', '');
  String json = createEvent(id, dataSet, 'onclick');
  print('json = $json');
  methodChannel.invokeMethod(
      'onclick', {'pageId': pageId, 'event': onclick, 'data': json});
}
