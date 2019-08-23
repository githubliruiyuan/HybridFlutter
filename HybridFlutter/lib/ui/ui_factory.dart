import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/entity/property.dart';
import 'package:flutter_app/ui/raised_button.dart';
import 'package:flutter_app/ui/row.dart';
import 'package:flutter_app/ui/single_child_scrollview.dart';
import 'package:flutter_app/ui/text.dart';
import 'package:flutter_app/util/base64.dart';
import 'package:flutter_app/util/expression_util.dart';

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

  UIFactory(this._pageId, this._methodChannel);

  Future<dynamic> _calcRepeatSize(String expression) async {
    return await _methodChannel.invokeMethod(
        'handle_repeat', {'pageId': _pageId, 'expression': expression});
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
    return properties;
  }

  Map<String, dynamic> _initEvents(Map<String, dynamic> data) {
    if (null == data) {
      return null;
    }
    Map events = new Map<String, dynamic>();
    events.addAll(data['events']);
    return events;
  }

  Map<String, dynamic> _initDirectives(Map<String, dynamic> data) {
    if (null == data) {
      return null;
    }
    Map events = Map<String, dynamic>();
    events.addAll(data['directives']);
    return events;
  }

  Future<dynamic> createComponentTree(Component parent,
      Map<String, dynamic> data, Map<String, dynamic> styles) async {
    var component = Component();
    component.id = component.hashCode.toString();
    component.tag = data["tag"];
    component.innerHTML = Property(decodeBase64(data["innerHTML"]));
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
      int size = await _calcRepeatSize(repeat);
      //处理for出来的
      List<Component> list = [];
      for (var index = 0; index < size; index++) {
        var clone = (0 == index) ? component : component.clone();
        clone.isInRepeat = true;
        clone.inRepeatIndex = index;
        clone.inRepeatPrefixExp = getInRepeatPrefixExp(clone);
        //需要添加 await，否则会出现异步导致children为空
        await _addChildren(clone, data, styles);
        await handleProperty(_methodChannel, _pageId, clone);
        clone.widget = _createWidget(parent?.widget, clone);
        list.add(clone);
      }
      return list;
    } else {
      await _addChildren(component, data, styles);
      await handleProperty(_methodChannel, _pageId, component);
      component.widget = _createWidget(parent?.widget, component);
      return component;
    }
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

//  Widget _createNestedScrollView(Map<String, Property> properties, Widget child) {
//    return NestedScrollView(
//      body: child,
//    );
//  }

  Widget _createVisibility(
      Map<String, Property> properties, Widget child, Widget replacement) {
    var visiblePro = properties['visible'];
    var visible =
        (null != visiblePro && "false" == visiblePro.getValue()) ? false : true;
    return Visibility(visible: visible, child: child, replacement: replacement);
  }

  Widget _createClipOval(Map<String, Property> properties, Widget child) {
    return ClipOval(child: child);
  }

  Widget _getFirstChild(List<Widget> children) {
    var child;
    if (null == children) {
      return child;
    }
    if (children.length > 0) {
      child = children[0];
    }
    return child;
  }

  Widget _getSecondChild(List<Widget> children) {
    var child;
    if (null == children) {
      return child;
    }
    if (children.length > 1) {
      child = children[1];
    }
    return child;
  }

  List<BaseWidgetStateful> _getChildren(
      BaseWidgetStateful parent, Component component) {
    List<BaseWidgetStateful> children = []; //先建一个数组用于存放循环生成的widget
    if (null == component) {
      return children;
    }
    component.children?.forEach((it) {
      children.add(_createWidget(parent, it));
    });
    return children;
  }

  BaseWidgetStateful _createWidget(
      BaseWidgetStateful parent, Component component) {
//    print("createChild tag ${component.tag}");
    var children = _getChildren(null, component);
    var widget;
    switch (component.tag) {
      case "body":
        widget = CenterStateful(
            parent, _pageId, _methodChannel, component, children);
        break;
      case "column":
        widget = ColumnStateful(
            parent, _pageId, _methodChannel, component, children);
        break;
      case "row":
        widget =
            RowStateful(parent, _pageId, _methodChannel, component, children);
        break;
      case "singlechildscrollview":
        widget = SingleChildScrollViewStateful(
            parent, _pageId, _methodChannel, component, children);
        break;
//      case "nestedscrollview":
//        widget = _createNestedScrollView(component.properties, child);
//        break;
//      case "clipoval":
//        widget = _createClipOval(component.properties, child);
//        break;
      case "container":
        widget = ContainerStateful(
            parent, _pageId, _methodChannel, component, children);
        break;
      case "expanded":
        widget = ExpandedStateful(
            parent, _pageId, _methodChannel, component, children);
        break;
      case "fractionallysizedbox":
        widget = FractionallySizedBoxStateful(
            parent, _pageId, _methodChannel, component, children);
        break;
      case "aspectratio":
        widget = AspectRatioStateful(
            parent, _pageId, _methodChannel, component, children);
        break;
      case "raisedbutton":
        widget = RaisedButtonStateful(
            parent, _pageId, _methodChannel, component, children);
        break;
//      case "visibility":
//        var child = _getFirstChild(children);
//        var replacement = _getSecondChild(children);
//        widget = _createVisibility(component.properties, child, replacement);
//        break;
      case "text":
        widget = TextStateful(parent, _pageId, _methodChannel, component);
        break;
      case "image":
        widget = ImageStateful(parent, _pageId, _methodChannel, component);
        break;
      default:
        var text = '未实现控件${component.tag}';
        var font = Property('14');
        var color = Property('red');
        component.properties.putIfAbsent('font-size', () => font);
        component.properties.putIfAbsent('color', () => color);
        component.innerHTML = Property(text);
        widget = TextStateful(parent, _pageId, _methodChannel, component);
        break;
    }
    children.forEach((child) {
      child.parent = widget;
    });
    return widget;
  }

  void compareComponent(Component oldOne, Component newOne) {
    var same = true;
    if (oldOne.tag != newOne.tag) {
      if (null != oldOne.widget.parent) {
        same = false;
      } else {
        same = false;
        oldOne.widget = newOne.widget;
      }
    } else {
      if (oldOne.properties.length != newOne.properties.length) {
        same = false;
      } else {
        oldOne.properties.forEach((k, v) {
          if (!newOne.properties.containsKey(k)) {
            same = false;
          } else if (newOne.properties[k].getValue() != v.getValue()) {
            same = false;
          }
        });
      }
      if (oldOne.children?.length != newOne.children?.length) {
        same = false;
      }

      if (oldOne.innerHTML.getValue() != newOne.innerHTML.getValue()) {
        same = false;
      }
    }
    if (!same) {
      for (var i = 0; i < oldOne.children?.length; i++) {
        compareComponent(oldOne.children[i], newOne.children[i]);
      }
    } else {
      oldOne.widget.updateChild(oldOne.widget, newOne.widget);
    }
  }
}
