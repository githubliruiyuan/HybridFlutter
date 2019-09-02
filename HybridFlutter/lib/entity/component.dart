import 'package:hybrid_flutter/entity/property.dart';
import 'package:hybrid_flutter/util/expression_util.dart';

class Component {
  String id;
  String tag;
  Component parent;
  Property innerHTML;
  Map<String, dynamic> events;
  Map<String, dynamic> directives;
  Map<String, Property> properties;
  List<Component> children = [];

  /// 是否在for里面
  bool isInRepeat = false;
  /// 在for里面的下标
  int inRepeatIndex;
  /// 在for里面的表达式前缀
  String inRepeatPrefixExp;

  String getIfExpression() {
    if (null == directives) {
      return null;
    }
    var shown = directives["shown"];
    if (null == shown) {
      return null;
    }
    var directiveName = shown["name"];
    if (directiveName == "if") {
      return shown["expression"];
    }
    return null;
  }

  String getElseIfExpression() {
    if (null == directives) {
      return null;
    }
    var shown = directives["shown"];
    if (null == shown) {
      return null;
    }
    var directiveName = shown["name"];
    if (directiveName == "elif") {
      return shown["expression"];
    }
    return null;
  }

  bool containElseExpression() {
    if (null == directives) {
      return false;
    }
    var shown = directives["shown"];
    if (null == shown) {
      return false;
    }
    var directiveName = shown["name"];
    if (directiveName == "else") {
      return true;
    }
    return false;
  }

  void handleShown() {
    if (null == directives) {
      return;
    }
    var shown = directives["shown"];
    if (null == shown) {
      return;
    }
  }

  String getForExpression() {
    if (null == directives) {
      return null;
    }
    var repeat = directives["repeat"];
    if (null == repeat) {
      return null;
    }
    return repeat["expression"];
  }

  String getForIndexName() {
    if (null == directives) {
      return null;
    }
    var repeat = directives["repeat"];
    if (null == repeat) {
      return null;
    }
    return repeat["index"];
  }

  String getForItemName() {
    if (null == directives) {
      return null;
    }
    var repeat = directives["repeat"];
    if (null == repeat) {
      return null;
    }
    return repeat["item"];
  }

  bool containRepeat() {
    if (null == directives) {
      return false;
    }
    return directives.containsKey("repeat");
  }

  String getRealForExpression() {
    if (null == directives) {
      return null;
    }
    var repeat = directives["repeat"];
    if (null == repeat) {
      return null;
    }
    return getExpression(repeat["expression"]);
  }

  Component clone() {
    var clone = Component();
    clone.tag = tag;
    clone.parent = parent;
    clone.events = events;
    clone.directives = directives;
    clone.properties = properties;
    clone.innerHTML = innerHTML;
    clone.isInRepeat = isInRepeat;
    clone.children = [];
    return clone;
  }
}
