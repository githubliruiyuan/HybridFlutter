import 'dart:convert';

String createEvent(String id, Map<String, dynamic> dataSet, String type) {
  Map<String, dynamic> target = Map();
  target.putIfAbsent('id', () => id);
  target.putIfAbsent('dataset', () => dataSet);
  Map<String, dynamic> event = Map();
  event.putIfAbsent('type', () => type);
  event.putIfAbsent('target', () => target);
  return jsonEncode(event);
}
