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

  /// 克隆节点id, inRepeatIndex, inRepeatPrefixExp不为空
  Future<Component> createComponentTree(
      Component parent, Map<String, dynamic> node, Map<String, dynamic> styles,
      {id, inRepeatIndex, inRepeatPrefixExp}) async {
    var component = Component(parent, node, styles,
        id: id,
        inRepeatIndex: inRepeatIndex,
        inRepeatPrefixExp: inRepeatPrefixExp);
    _componentMap.putIfAbsent(component.id, () => component);
    await _addChildren(component, node, styles);
    return component;
  }

  /// 为Component添加children
  Future _addChildren(Component parent, Map<String, dynamic> data,
      Map<String, dynamic> styles) async {
    var children = data['childNodes'];
    if (null != children) {
      for (var child in children) {
        var result = await createComponentTree(parent, child, styles);
        parent.children.add(result);
      }
    }
  }

  Future<List<BaseWidget>> _getChildren(
      BaseWidget parent, Component component) async {
    List<BaseWidget> children = [];
    for (var it in component?.children) {
      var child = await createWidgetTree(parent, it);
      if (null != child) {
        if (child is List<BaseWidget>) {
          children.addAll(child);
        } else {
          children.add(child);
        }
      }
    }
    return children;
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

  Future<dynamic> createWidgetTree(BaseWidget parent, Component component,
      {newSize}) async {
    var repeat = component.getRealForExpression();
    if (null != repeat) {
      repeat = getInRepeatExp(component, repeat);
      var id = component.id;
      int size = newSize ??
          await calcRepeatSize(
              _methodChannel, _pageId, id, TYPE_DIRECTIVE, 'repeat', repeat);

      if (size > 0) {
        var indexName = component.getForIndexName();
        var itemName = component.getForItemName();
        var exp = component.getRealForExpression();
        var parentInRepeatPrefixExp = component.parent?.inRepeatPrefixExp;
        List<BaseWidget> widgets = [];
        for (var index = 0; index < size; index++) {
          var inRepeatPrefixExp = getInRepeatPrefixExp(
              indexName, itemName, exp, index, parentInRepeatPrefixExp);
          var inRepeatId = "$id-$index";
          /// 缓存复用
          var clone = _componentMap[inRepeatId];
          if (null == clone) {
            clone = await createComponentTree(
                component.parent, component.node, component.styles,
                id: inRepeatId,
                inRepeatIndex: index,
                inRepeatPrefixExp: inRepeatPrefixExp);
          }
          /// 处理表达式
          await handleProperty(_methodChannel, _pageId, clone);
          /// 缓存复用
          var widget = _widgetMap[inRepeatId];
          if (null == widget) {
            widget = _createWidget(parent, clone);
            widget.setChildren(await _getChildren(widget, clone));
            _widgetMap.putIfAbsent(clone.id, () => widget);
          } else {
            /// 此处复用需要更新复用的属性及children的属性的表达式值
            widget.updateProperties(clone.properties);
            await _updateChildren(widget);
          }
          widgets.add(widget);
        }
        return widgets;
      } else {
        return null;
      }
    } else {
      await handleProperty(_methodChannel, _pageId, component);
      BaseWidget widget = _createWidget(parent, component);
      widget.setChildren(await _getChildren(widget, component));
      _widgetMap.putIfAbsent(component.id, () => widget);
      return widget;
    }
  }

  BaseWidget _createWidget(BaseWidget parent, Component component) {
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
    return widget;
  }

  void clear() {
    _componentMap.clear();
    _widgetMap.clear();
  }

  Future<List<BaseWidget>> _getNewChildren(Component parent,
      Component component, BaseWidget parentWidget, int size) async {
    List<BaseWidget> children = [];
    for (var it in parent.children) {
      if (it == component) {
        List<BaseWidget> result =
            await createWidgetTree(parentWidget, component, newSize: size);
        if (null != result) {
          children.addAll(result);
        }
      } else {
        /// 如果是for节点需要把原来的children迁移过来
        if (null != it.getForExpression()) {
          parentWidget.data.value.children.forEach((child) {
            if (child.component.id.startsWith(it.id)) {
              children.add(child);
            }
          });
        } else {
          var widget = _widgetMap[it.id];
          if (null != widget) {
            children.add(widget);
          }
        }
      }
    }
    return children;
  }

  Future updateTree(List<dynamic> list) async {
    for (var it in list) {
      var type = it['type'];
      var id = it['id'];
      switch (type) {
        case TYPE_DIRECTIVE:

          /// 更新for需要将parentComponent的children重新检查更新一遍
          if (_componentMap.containsKey(id)) {
            var component = _componentMap[id];
            var parentId = component.parent.id;
            if (_componentMap.containsKey(parentId) &&
                _widgetMap.containsKey(parentId)) {
              var parentComponent = _componentMap[parentId];
              var parentWidget = _widgetMap[parentId];
              var newSize = it['value'];
              var children = await _getNewChildren(
                  parentComponent, component, parentWidget, newSize);
              parentWidget.updateChildren(children);
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
