import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_app/entity/property.dart';

Color hexToColor(String s) {
// 如果传入的十六进制颜色值不符合要求，返回默认值
  if (s.length == 7) {
    return Color(int.parse(s.substring(1, 7), radix: 16) + 0xFF000000);
  } else {
    return Color(int.parse(s.substring(1, 9), radix: 16));
  }
}

Color dealFontColor(Property property) {
  Color color = Colors.black;
  if (null == property) {
    return color;
  }
  String str = property.getValue();
  if (null != str) {
    if (str.startsWith('#')) {
      color = hexToColor(str);
    } else {
      color = _getColor(str, defaultValue: Colors.black);
    }
  }
  return color;
}

Color dealColor(Property property) {
  Color color = Colors.transparent;
  if (null == property) {
    return color;
  }
  String str = property.getValue();
  if (null != str) {
    if (str.startsWith('#')) {
      color = hexToColor(str);
    } else {
      color = _getColor(str);
    }
  }
  return color;
}

Color _getColor(String str, {Color defaultValue = Colors.transparent}) {
  switch (str) {
    case 'white':
      return Colors.white;
    case 'blue':
      return Colors.blue;
    case 'green':
      return Colors.green;
    case 'yellow':
      return Colors.yellow;
    case 'cyan':
      return Colors.cyan;
    case 'gray':
      return Colors.grey;
    case 'black':
      return Colors.black;
    case 'red':
      return Colors.red;
    case 'orange':
      return Colors.orange;
    case 'brown':
      return Colors.brown;
    case 'pink':
      return Colors.pink;
    case 'purple':
      return Colors.purple;
    case 'indigo':
      return Colors.indigo;
    case 'teal':
      return Colors.teal;
    case 'lime':
      return Colors.lime;
    case 'amber':
      return Colors.amber;
    case 'transparent':
      return Colors.transparent;
    default:
      return defaultValue;
  }
}
