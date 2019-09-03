import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';

bool containExpressionSimple(String content) {
  if (null == content) return false;
  var trim = content.trim();
  if (trim.isEmpty) return false;
  return trim.contains("{{") && trim.contains("}}");
}

//在双花括号中获取表达式
String getExpression(String dataSource) {
  var trim = dataSource?.trim();
  if (trim.length <= 4) return "";
  return trim.substring(2, trim.length - 2);
}


///获取在for里面的表达式 判断是否有表达式前缀，有则需要拼接
///e.g.：return list
///e.g.：var index = 0; var item = list[index]; return item
String getInRepeatExp(Component component, String exp) {
  if (null == component.inRepeatPrefixExp) {
    return 'return $exp';
  }
  return '${component.inRepeatPrefixExp} return $exp';
}

///获取在for里面的表达前缀，判断父层级是否有前缀，有则需要在拼接在前面
///e.g.：var index = 0; var item = list[index];
///e.g.; var index = 0; var item = list[index]; var idx = 0; var it = item[idx];
String getInRepeatPrefixExp(Component component) {
  var indexName = component.getForIndexName();
  var itemName = component.getForItemName();
  var exp = component.getRealForExpression();
  var prefix =
      'var $indexName = ${component.inRepeatIndex}; var $itemName = $exp[$indexName];';
  var parentInRepeatPrefixExp = component.parent?.inRepeatPrefixExp;
  if (null != parentInRepeatPrefixExp && parentInRepeatPrefixExp.isNotEmpty) {
    prefix = '$parentInRepeatPrefixExp $prefix';
  }
  return prefix;
}


///处理property以及innerHTML
Future handleProperty(MethodChannel methodChannel, String pageId, Component component) async {
  component.properties.forEach((k, v) async {
    var exp = v.property;
    if (containExpressionSimple(exp)) {
      exp = getExpression(exp);
      if (component.isInRepeat) {
        exp = getInRepeatExp(component, exp);
      } else {
        exp = 'return $exp';
      }
      v.setValue(await _calcExpression(methodChannel, pageId, exp));
    }
  });

  var exp = component.innerHTML.property;
  if (containExpressionSimple(exp)) {
    exp = getExpression(exp);
    if (component.isInRepeat) {
      exp = getInRepeatExp(component, exp);
    } else {
      exp = 'return $exp';
    }
    component.innerHTML.setValue(await _calcExpression(methodChannel, pageId, exp));
  }
}

Future<dynamic> _calcExpression(MethodChannel methodChannel, String pageId, String expression) async {
//  print("pageId = $pageId exp = $expression");
  return await methodChannel.invokeMethod(
      'handle_expression', {'pageId': pageId, 'expression': expression});
}
