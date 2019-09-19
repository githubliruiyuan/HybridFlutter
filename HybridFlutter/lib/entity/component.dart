import 'package:hybrid_flutter/entity/property.dart';
import 'package:hybrid_flutter/util/base64.dart';
import 'package:hybrid_flutter/util/expression_util.dart';

class Component {
  /// 唯一id
  String id;

  /// 标签类型
  String tag;

  /// 父节点
  Component parent;

  /// 节点
  Map<String, dynamic> node;

  /// 样式
  Map<String, dynamic> styles;

  /// 事件
  Map<String, dynamic> events;

  /// 指令
  Map<String, dynamic> directives;

  /// 属性
  Map<String, Property> properties;

  /// 子节点
  List<Component> children = [];

  /// 是否在for里面
  bool isInRepeat = false;

  /// 在for里面的下标
  int inRepeatIndex;

  /// 在for里面的表达式前缀
  String inRepeatPrefixExp;

  /// 克隆节点id, inRepeatIndex, inRepeatPrefixExp不为空
  Component(this.parent, this.node, this.styles,
      {id, inRepeatIndex, inRepeatPrefixExp}) {
    this.tag = node["tag"];
    this.id = id ?? "$tag-$hashCode";
    this.properties = _initProperties(node, styles);
    this.directives = _initDirectives(node);
    this.events = _initEvents(node);
    this.isInRepeat = _isInRepeat();
    this.inRepeatIndex = inRepeatIndex ?? parent?.inRepeatIndex;
    this.inRepeatPrefixExp = inRepeatPrefixExp ?? parent?.inRepeatPrefixExp;
    this.parent = parent;
  }

  bool _isInRepeat() {
    if (null != getForExpression()) {
      return true;
    } else {
      return null == parent ? false : parent?.isInRepeat;
    }
  }

  void insertChildren(int index, List<Component> children) {
    this.children.insertAll(index, children);
  }

  void removeRangeChildren(int start, int end) {
    this.children.removeRange(start, end);
  }

  Map<String, Property> _initProperties(
      Map<String, dynamic> node, Map<String, dynamic> styles) {
    if (null == node) {
      return null;
    }
    Map properties = new Map<String, Property>();
    if (null != node['id'] && node['id'] != '') {
      Map<String, dynamic> idStyles = styles['.' + node['id']];
      if (idStyles != null) {
        idStyles.forEach((k, v) {
          properties.putIfAbsent(k, () => Property(v));
        });
      }
    }
    var attr = node['attrib'];
    if (null != attr) {
      attr.forEach((k, v) {
        properties.putIfAbsent(k, () => Property(v));
      });
    }
    var attrStyle = node['attribStyle'];
    if (null != attrStyle) {
      attrStyle.forEach((k, v) {
        properties.putIfAbsent(k, () => Property(v));
      });
    }

    if (null != node["innerHTML"]) {
      properties.putIfAbsent(
          "innerHTML", () => Property(decodeBase64(node["innerHTML"])));
    }
    return properties;
  }

  Map<String, dynamic> _initEvents(Map<String, dynamic> node) {
    if (null == node) {
      return null;
    }
    return node['events'];
  }

  Map<String, dynamic> _initDirectives(Map<String, dynamic> node) {
    if (null == node) {
      return null;
    }
    return node['directives'];
  }

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

//  Component clone() {
//    return Component(parent, node, styles, id: this.id);
//  }
}
