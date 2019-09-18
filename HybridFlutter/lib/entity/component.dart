import 'package:hybrid_flutter/entity/property.dart';
import 'package:hybrid_flutter/util/base64.dart';
import 'package:hybrid_flutter/util/expression_util.dart';

class Component {
  String id;
  String tag;
  Component parent;
  Map<String, dynamic> data;
  Map<String, dynamic> styles;
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

  Component(this.parent, this.data, this.styles, {id}) {
    this.tag = data["tag"];
    this.id = id ?? "$tag-$hashCode";
    this.properties = _initProperties(data, styles);
    this.directives = _initDirectives(data);
    this.events = _initEvents(data);
    this.isInRepeat = null == parent ? false : parent?.isInRepeat;
    this.inRepeatIndex = parent?.inRepeatIndex;
    this.inRepeatPrefixExp = parent?.inRepeatPrefixExp;
    this.parent = parent;
  }

  void setInRepeatIndex(int index) {
    this.inRepeatIndex = index;
    if (index > 0) {
      this.id = "$id-$index";
    }
  }

  Map<String, Property> _initProperties(
      Map<String, dynamic> data, Map<String, dynamic> styles) {
    if (null == data) {
      return null;
    }
    Map properties = new Map<String, Property>();
    if (null != data['id'] && data['id'] != '') {
      Map<String, dynamic> idStyles = styles['.' + data['id']];
      if (idStyles != null) {
        idStyles.forEach((k, v) {
          properties.putIfAbsent(k, () => Property(v));
        });
      }
    }
    var attr = data['attrib'];
    if (null != attr) {
      attr.forEach((k, v) {
        properties.putIfAbsent(k, () => Property(v));
      });
    }
    var attrStyle = data['attribStyle'];
    if (null != attrStyle) {
      attrStyle.forEach((k, v) {
        properties.putIfAbsent(k, () => Property(v));
      });
    }

    if (null != data["innerHTML"]) {
      properties.putIfAbsent(
          "innerHTML", () => Property(decodeBase64(data["innerHTML"])));
    }
    return properties;
  }

  Map<String, dynamic> _initEvents(Map<String, dynamic> data) {
    if (null == data) {
      return null;
    }
    return data['events'];
  }

  Map<String, dynamic> _initDirectives(Map<String, dynamic> data) {
    if (null == data) {
      return null;
    }
    return data['directives'];
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

  Component clone() {
    return Component(parent, data, styles, id: this.id);
  }
}
