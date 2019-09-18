import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/property.dart';
import 'package:hybrid_flutter/ui/circular_progress_indicator.dart';
import 'package:hybrid_flutter/ui/list_view.dart';
import 'package:hybrid_flutter/ui/raised_button.dart';
import 'package:hybrid_flutter/ui/row.dart';
import 'package:hybrid_flutter/ui/single_child_scrollview.dart';
import 'package:hybrid_flutter/ui/text.dart';
import 'package:hybrid_flutter/ui/visibility.dart';
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

  Future<dynamic> createComponentTree(Component parent,
      Map<String, dynamic> data, Map<String, dynamic> styles) async {
    var component = Component(parent, data, styles);
    var repeat = component.getRealForExpression();
    _componentMap.putIfAbsent(component.id, () => component);
    if (null != repeat) {
      repeat = getInRepeatExp(component, repeat);
      int size = await calcRepeatSize(_methodChannel, _pageId, component.id,
          TYPE_DIRECTIVE, 'repeat', repeat);

      /// 处理for出来的
      List<Component> list = [];
      for (var index = 0; index < size; index++) {
        var clone = (0 == index) ? component : component.clone();
        clone.isInRepeat = true;
        clone.setInRepeatIndex(index);
        clone.inRepeatPrefixExp = getInRepeatPrefixExp(clone);

        /// 需要添加 await，否则会出现异步导致children为空
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

  /// e.g. 创建指定length的children
  Future<List<Component>> _createRepeatComponent(
      Component component, int start, int size) async {
    List<Component> list = [];
    if (size > start) {
      for (var index = start; index < size; index++) {
        var clone = (0 == index) ? component : component.clone();
        clone.isInRepeat = true;
        clone.setInRepeatIndex(index);
        clone.inRepeatPrefixExp = getInRepeatPrefixExp(clone);

        /// 需要添加 await，否则会出现异步导致children为空
        await _addChildren(clone, component.data, component.styles);
        await handleProperty(_methodChannel, _pageId, clone);
        list.add(clone);
      }
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
      case "listview":
        widget = ListViewStateless(parent, _pageId, _methodChannel, component);
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
      case "circularprogressindicator":
        widget = CircularProgressIndicatorStateless(
            parent, _pageId, _methodChannel, component);
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

  Future _updateRangeChildren(BaseWidget widget, int start, int end) async {
    if (widget.data.value.children.isEmpty) return;
    for (int i = start; i <= end; i++) {
      var it = widget.data.value.children[i];
      await handleProperty(_methodChannel, _pageId, it.component);
      it.updateProperties(it.component.properties);
      if (it.data.value.children.isNotEmpty) {
        _updateChildren(it);
      }
    }
  }

  Future _updateChildren(BaseWidget widget) async {
    for (var it in widget.data.value.children) {
      await handleProperty(_methodChannel, _pageId, it.component);
      it.updateProperties(it.component.properties);
      if (it.data.value.children.isNotEmpty) {
        _updateChildren(it);
      }
    }
  }

  /// 计算对应id的for列表的size
  List<int> _calcForRange(id, List<BaseWidget> children) {
    int first;
    int last;
    for (int i = 0; i < children.length; i++) {
      var it = children[i].component;
      if (it.id.startsWith(id)) {
        if (null == first) {
          first = i;
        }
        last = i;
      }
    }
    return [first ?? 0, last ?? 0];
  }

  Future updateTree(List<dynamic> list) async {
    for (var it in list) {
      var type = it['type'];
      var id = it['id'];
      switch (type) {
        case TYPE_DIRECTIVE:
          if (_componentMap.containsKey(id)) {
            var component = _componentMap[id];
            var parentId = component.parent.id;
            if (_widgetMap.containsKey(parentId)) {
              var parentWidget = _widgetMap[parentId];

              /// for 出来的children复用
              var range = _calcForRange(id, parentWidget.data.value.children);
              /// for 的起始下标
              var rangeStart = range[0];
              /// for 的终止下标
              var rangeEnd = range[1];
              // print("range $range");
              var oldSize = rangeEnd - rangeStart + 1;
              var newSize = it['value'];
              if (oldSize < newSize) {
                /// size 由少变多
                /// 由于for的每个item不单独监听，所以每次改动需要更新已有的item
                if (oldSize > 0) {
                  await _updateRangeChildren(parentWidget, rangeStart, rangeEnd);
                }
                var tree =
                    await _createRepeatComponent(component, oldSize, newSize);
                List<BaseWidget> children = [];
                tree.forEach((it) {
                  children.add(createWidgetTree(parentWidget, it));
                });
                var insertIndex = 0 == rangeEnd ? 0 : rangeEnd + 1;
                parentWidget.insertChildren(insertIndex, children);
              } else if (oldSize == newSize) {
                /// size 相等，只更新属性
                await _updateRangeChildren(parentWidget, rangeStart, rangeEnd);
              } else {
                /// size 由多变少
                var diff = oldSize - newSize;
                var diffStart = rangeEnd - diff;
                var diffEnd = rangeEnd + 1;

                /// 更新for列表
                parentWidget.data.value.children
                    .removeRange(diffStart + 1, diffEnd);
                parentWidget.updateChildren(parentWidget.data.value.children);
                if (newSize > 0) {
                  await _updateRangeChildren(
                      parentWidget, rangeStart, rangeStart + newSize - 1);
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
    }
  }
}
