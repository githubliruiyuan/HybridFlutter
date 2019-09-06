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
        list.add(clone);
      }
      return list;
    } else {
      await _addChildren(component, data, styles);
      await handleProperty(_methodChannel, _pageId, component);
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

  Widget _createClipOval(Map<String, Property> properties, Widget child) {
    return ClipOval(child: child);
  }

  ValueNotifier<List<BaseWidget>> _getChildren(
      BaseWidget parent, Component component) {
    ValueNotifier<List<BaseWidget>> children = ValueNotifier([]);
    if (null == component) {
      return children;
    }
    component.children?.forEach((it) {
      children.value.add(createWidgetTree(parent, it));
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
        var text = '未实现控件${component.tag}';
        var font = Property('14');
        var color = Property('red');
        component.properties.putIfAbsent('font-size', () => font);
        component.properties.putIfAbsent('color', () => color);
        component.innerHTML = Property(text);
        widget = TextStateless(parent, _pageId, _methodChannel, component);
        break;
    }
    widget.setChildren(_getChildren(widget, component));
    return widget;
  }

  void compareTreeAndUpdate(BaseWidget oldOne, BaseWidget newOne) {
    var same = true;
    if (oldOne.component.tag != newOne.component.tag) {
      if (null != oldOne.parent) {
        same = false;
      } else {
        same = false;
      }
    } else {
      oldOne.component.properties.forEach((k, v) {
        if (!newOne.component.properties.containsKey(k)) {
          same = false;
        } else if (newOne.component.properties[k].getValue() != v.getValue()) {
          same = false;
        }
      });

      if (oldOne.children.value.length != newOne.children.value.length) {
        same = false;
      }

      if (oldOne.component.innerHTML.getValue() !=
          newOne.component.innerHTML.getValue()) {
        same = false;
      }
    }
    if (same) {
      for (var i = 0; i < oldOne.children.value.length; i++) {
        compareTreeAndUpdate(
            oldOne.children.value[i], newOne.children.value[i]);
      }
    } else {
      oldOne.updateChildrenOfParent(newOne.parent.children);
    }
  }

//  void updateTree(BaseWidget tree) {
//    var pros = tree.component.properties.values.toList();
//    for (var i = 0; i < pros.length; i++) {
//      var it = pros[i];
//      if (it.containExpression) {
//        var newValue = calcExpression(
//            tree.methodChannel, tree.pageId, it.property);
//      }
//    }
//  }
}
