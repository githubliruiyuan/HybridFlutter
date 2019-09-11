import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/property.dart';
import 'package:hybrid_flutter/ui/raised_button.dart';
import 'package:hybrid_flutter/ui/row.dart';
import 'package:hybrid_flutter/ui/single_child_scrollview.dart';
import 'package:hybrid_flutter/ui/text.dart';
import 'package:hybrid_flutter/ui/visibility.dart';
import 'package:hybrid_flutter/util/base64.dart';
import 'package:hybrid_flutter/util/expression_util.dart';

import 'aspect_ratio.dart';
import 'base_widget.dart';
import 'center.dart';
import 'column.dart';
import 'container.dart';
import 'expanded.dart';
import 'fractionally_sized_box.dart';
import 'image.dart';

class UIFactory {
  final String _pageId;
  final MethodChannel _methodChannel;
  final Map<String, Component> _componentMap = Map();
  final Map<String, BaseWidget> _widgetMap = Map();

  UIFactory(this._pageId, this._methodChannel);

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

  Future<dynamic> createComponentTree(Component parent,
      Map<String, dynamic> data, Map<String, dynamic> styles) async {
    var component = Component();
    component.id = data["tag"] + component.hashCode.toString();
    component.tag = data["tag"];
    component.data = data;
    component.styles = styles;
    component.properties = _initProperties(data, styles);
    component.directives = _initDirectives(data);
    component.events = _initEvents(data);
    component.isInRepeat = null == parent ? false : parent?.isInRepeat;
    component.inRepeatIndex = parent?.inRepeatIndex;
    component.inRepeatPrefixExp = parent?.inRepeatPrefixExp;
    component.parent = parent;

    var repeat = component.getRealForExpression();
    if (null != repeat) {
      repeat = getInRepeatExp(component, repeat);
      int size = await calcRepeatSize(_methodChannel, _pageId, component.id,
          TYPE_DIRECTIVE, 'repeat', repeat);

      /// 处理for出来的
      List<Component> list = [];
      if (size > 0) {
        for (var index = 0; index < size; index++) {
          var clone = (0 == index) ? component : component.clone();
          clone.isInRepeat = true;
          clone.inRepeatIndex = index;
          clone.inRepeatPrefixExp = getInRepeatPrefixExp(clone);

          /// 需要添加 await，否则会出现异步导致children为空
          await _addChildren(clone, data, styles);
          await handleProperty(_methodChannel, _pageId, clone);
          _componentMap.putIfAbsent(clone.id, () => clone);
          list.add(clone);
        }
      } else {
        _componentMap.putIfAbsent(component.id, () => component);
      }
      return list;
    } else {
      _componentMap.putIfAbsent(component.id, () => component);
      await _addChildren(component, data, styles);
      await handleProperty(_methodChannel, _pageId, component);
      return component;
    }
  }

  /// e.g. 创建指定length的children
  Future<List<Component>> _createRepeatComponent(
      Component component, int start, int size) async {
    List<Component> list = [];
    if (size > start) {
      for (var index = start; index < size; index++) {
        var clone = (0 == index) ? component : component.clone();
        clone.isInRepeat = true;
        clone.inRepeatIndex = index;
        clone.inRepeatPrefixExp = getInRepeatPrefixExp(clone);
        /// 需要添加 await，否则会出现异步导致children为空
        await _addChildren(clone, component.data, component.styles);
        await handleProperty(_methodChannel, _pageId, clone);
        _componentMap.putIfAbsent(clone.id, () => clone);
        list.add(clone);
      }
    } else {
      _componentMap.putIfAbsent(component.id, () => component);
    }
    return list;
  }

  ///为Component添加children
  Future _addChildren(Component parent, Map<String, dynamic> data,
      Map<String, dynamic> styles) async {
    var children = data['childNodes'];
    if (null != children) {
      for (var child in children) {
        var result = await createComponentTree(parent, child, styles);
        if (result is List) {
          parent.children.addAll(result as List<Component>);
        } else {
          parent.children.add(result);
        }
      }
    }
  }

  Widget _createClipOval(Map<String, Property> properties, Widget child) {
    return ClipOval(child: child);
  }

  List<BaseWidget> _getChildren(BaseWidget parent, Component component) {
    List<BaseWidget> children = [];
    if (null == component) {
      return children;
    }
    component.children?.forEach((it) {
      children.add(createWidgetTree(parent, it));
    });
    return children;
  }

  BaseWidget createWidgetTree(BaseWidget parent, Component component) {
//    print("createChild tag ${component.tag}");
    BaseWidget widget;
    switch (component.tag) {
      case "body":
        component.properties['width-factor'] = Property("1");
        component.properties['height-factor'] = Property("1");
        widget = CenterStateless(parent, _pageId, _methodChannel, component);
        break;
      case "center":
        widget = CenterStateless(parent, _pageId, _methodChannel, component);
        break;
      case "column":
        widget = ColumnStateless(parent, _pageId, _methodChannel, component);
        break;
      case "row":
        widget = RowStateless(parent, _pageId, _methodChannel, component);
        break;
      case "singlechildscrollview":
        widget = SingleChildScrollViewStateless(
            parent, _pageId, _methodChannel, component);
        break;
//      case "nestedscrollview":
//        widget = _createNestedScrollView(component.properties, child);
//        break;
//      case "clipoval":
//        widget = _createClipOval(component.properties, child);
//        break;
      case "container":
        widget = ContainerStateless(parent, _pageId, _methodChannel, component);
        break;
      case "expanded":
        widget = ExpandedStateless(parent, _pageId, _methodChannel, component);
        break;
      case "fractionallysizedbox":
        widget = FractionallySizedBoxStateless(
            parent, _pageId, _methodChannel, component);
        break;
      case "aspectratio":
        widget =
            AspectRatioStateless(parent, _pageId, _methodChannel, component);
        break;
      case "raisedbutton":
        widget =
            RaisedButtonStateless(parent, _pageId, _methodChannel, component);
        break;
      case "visibility":
        widget =
            VisibilityStateless(parent, _pageId, _methodChannel, component);
        break;
      case "text":
        widget = TextStateless(parent, _pageId, _methodChannel, component);
        break;
      case "image":
        widget = ImageStateless(parent, _pageId, _methodChannel, component);
        break;
      default:
        var text = Property('未实现控件${component.tag}');
        var font = Property('14');
        var color = Property('red');
        component.properties = Map();
        component.properties.putIfAbsent('font-size', () => font);
        component.properties.putIfAbsent('color', () => color);
        component.properties.putIfAbsent('innerHTML', () => text);
        widget = TextStateless(parent, _pageId, _methodChannel, component);
        break;
    }
    widget.setChildren(_getChildren(widget, component));
    _widgetMap.putIfAbsent(component.id, () => widget);
    return widget;
  }

  void clear() {
    _componentMap.clear();
    _widgetMap.clear();
  }

  void _updateChildren(BaseWidget widget) {
    widget.data.value.children.forEach((it) async {
      await handleProperty(_methodChannel, _pageId, it.component);
      it.updateProperty(it.component.properties);
    });
  }

  Future updateTree(List<dynamic> list) async {
    list.forEach((it) async {
      var type = it['type'];
      var id = it['id'];
      print("updateTree type = $type");
      switch (type) {
        case TYPE_DIRECTIVE:
          if (_componentMap.containsKey(id)) {
            var component = _componentMap[id];
            var parentId = component.parent.id;
            if (_widgetMap.containsKey(parentId)) {
              var parentWidget = _widgetMap[parentId];

              /// for 出来的children复用
              var start = parentWidget.data.value.children.length;
              var size = it['value'];
              if (start < size) {
                /// size 由少变多
                if (start > 0) {
                  _updateChildren(parentWidget);
                }
                var tree = await _createRepeatComponent(component, start, size);
                List<BaseWidget> children = [];
                tree.forEach((it) {
                  var child = createWidgetTree(parentWidget, it);
                  children.add(child);
                });
                parentWidget.addChildren(children);
              } else if (start == size) {
                /// size 相等，只更新属性
                _updateChildren(parentWidget);
              } else {
                /// size 由多变少
                List<BaseWidget> children = [];
                if (size > 0) {
                  children.addAll(
                      parentWidget.data.value.children.getRange(0, size));
                  var length = parentWidget.data.value.children.length;
                  List<String> ids = [];
                  parentWidget.data.value.children
                      .getRange(size - 1, length)
                      .forEach((it) {
                        print("remove id = ${it.component.id}");
                    ids.add(it.component.id);
                  });
                  removeObserver(_methodChannel, _pageId, ids);
                }
                parentWidget.updateChildren(children);
                if (size > 0) {
                  _updateChildren(parentWidget);
                }
              }
            }
          }
          break;
        case TYPE_PROPERTY:
          if (_widgetMap.containsKey(id)) {
            var widget = _widgetMap[id];
            widget.updateProperty(it);
          }
          break;
      }
    });
  }
}
