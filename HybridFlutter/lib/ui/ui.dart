import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/entity/property.dart';
import 'package:flutter_app/util/base64.dart';
import 'package:flutter_app/util/color_util.dart';
import 'package:flutter_app/util/event_util.dart';
import 'package:flutter_app/util/expression_util.dart';
import 'package:flutter_app/util/widget_util.dart';

import 'basic.dart';

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

  Future<Widget> createView(
      Map<String, dynamic> data, Map<String, dynamic> styles) async {
    var component = await _createComponentTree(null, data, styles);
    return _createWidget(component);
  }

  Future<dynamic> _createComponentTree(Component parent,
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
        var result = await _createComponentTree(parent, child, styles);
        if (result is List) {
          parent.children.addAll(result as List<Component>);
        } else {
          parent.children.add(result);
        }
      }
    }
  }

  Widget _createColumn(
      Map<String, Property> properties, List<Widget> children) {
    return Column(
        mainAxisAlignment: MMainAxisAlignment.parse(
            properties["main-axis-alignment"],
            defaultValue: MainAxisAlignment.start),
        mainAxisSize: MMainAxisSize.parse(properties["main-axis-size"],
            defaultValue: MainAxisSize.max),
        crossAxisAlignment: MCrossAxisAlignment.parse(
            properties["cross-axis-alignment"],
            defaultValue: CrossAxisAlignment.center),
        textDirection: MTextDirection.parse(properties["text-direction"]),
        verticalDirection: MVerticalDirection.parse(
            properties["vertical-direction"],
            defaultValue: VerticalDirection.down),
        textBaseline: MTextBaseline.parse(properties["text-baseline"]),
        children: children);
  }

  Widget _createRow(Map<String, Property> properties, List<Widget> children) {
    return Row(
      mainAxisAlignment: MMainAxisAlignment.parse(
          properties["main-axis-alignment"],
          defaultValue: MainAxisAlignment.start),
      mainAxisSize: MMainAxisSize.parse(properties["main-axis-size"],
          defaultValue: MainAxisSize.max),
      crossAxisAlignment: MCrossAxisAlignment.parse(
          properties["cross-axis-alignment"],
          defaultValue: CrossAxisAlignment.center),
      textDirection: MTextDirection.parse(properties["text-direction"]),
      verticalDirection: MVerticalDirection.parse(
          properties["vertical-direction"],
          defaultValue: VerticalDirection.down),
      textBaseline: MTextBaseline.parse(properties["text-baseline"]),
      children: children);
  }

  Widget _createSingleChildScrollView(
      Map<String, Property> properties, Widget child) {
    return SingleChildScrollView(
        scrollDirection: MAxis.parse(properties["scrollDirection"],
            defaultValue: Axis.vertical),
        child: child);
  }

//  Widget _createNestedScrollView(Map<String, Property> properties, Widget child) {
//    return NestedScrollView(
//      body: child,
//    );
//  }

  Widget _createContainer(Map<String, Property> properties, Widget child) {
    var width = dealDoubleDefNull(properties['width']);
    var height = dealDoubleDefNull(properties['height']);

    //处理背景
    Color color = dealColor(properties['color']);
    var alignment = MAlignment.parse(properties['alignment'],
        defaultValue: Alignment.topLeft);

    return Container(
        alignment: alignment,
        color: color,
        width: width,
        height: height,
        margin: MMargin.parse(properties),
        padding: MPadding.parse(properties),
        child: child);
  }

  Widget _createVisibility(
      Map<String, Property> properties, Widget child, Widget replacement) {
    var visiblePro = properties['visible'];
    var visible =
        (null != visiblePro && "false" == visiblePro.getValue()) ? false : true;
    return Visibility(visible: visible, child: child, replacement: replacement);
  }

  Widget _createAspectRatio(Map<String, Property> properties, Widget child) {
    return AspectRatio(
        aspectRatio: dealDoubleDefZero(properties['aspect-ratio']),
        child: child);
  }

  Widget _createFractionallySizedBox(
      Map<String, Property> properties, Widget child) {
    var widthFactor = dealDoubleDefZero(properties['width-factor']);
    var heightFactor = dealDoubleDefZero(properties['height-factor']);
    print("widthFactor = " +
        widthFactor.toString() +
        " heightFactor = " +
        heightFactor.toString());
    return FractionallySizedBox(
        child: child, widthFactor: widthFactor, heightFactor: heightFactor);
  }

  Widget _createClipOval(Map<String, Property> properties, Widget child) {
    return ClipOval(child: child);
  }

  Widget _createRaisedButton(Map<String, Property> properties,
      Map<String, dynamic> events, Widget child) {
    //处理背景
    Color color = dealColor(properties['color']);
    Color textColor = dealColor(properties['text-color']);
    Color disabledTextColor = dealColor(properties['disabled-text-color']);
    Color disabledColor = dealColor(properties['disabled-color']);
    Color focusColor = dealColor(properties['focus-color']);
    Color hoverColor = dealColor(properties['hover-color']);
    Color highlightColor = dealColor(properties['highlight-color']);
    Color splashColor = dealColor(properties['splash-color']);
    return RaisedButton(
      onPressed: () {
        print("onclick");
        if (null != events['onclick']) {
          onclickEvent(_methodChannel, _pageId, this.hashCode.toString(),
              properties, events);
        }
      },
      textColor: textColor,
      disabledTextColor: disabledTextColor,
      color: color,
      disabledColor: disabledColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      child: child,
    );
  }

  Widget _createText(Map<String, Property> properties, String text) {
    var fontSize = dealFontSize(properties['font-size']);
    Color color = dealFontColor(properties['color']);
    Color backgroundColor = dealColor(properties['background-color']);
    var inherit = dealBoolDefNull(properties['inherit']);
    if (null == inherit) {
      inherit = true;
    }
    return Text(text,
        style: TextStyle(
            inherit: inherit,
            fontSize: fontSize,
            backgroundColor: backgroundColor,
            color: color));
  }

  Widget _createImage(Map<String, Property> properties) {
    var width = dealDoubleDefNull(properties['width']);
    var height = dealDoubleDefNull(properties['height']);
    var src = properties['src'].getValue();
    return Image.network(null == src ? '' : src, width: width, height: height);
  }

  onclickEvent(MethodChannel methodChannel, String pageId, String id,
      Map<String, Property> properties, Map<String, dynamic> events) {
    var prefix = 'data-';
    var dataSet = Map<String, dynamic>();
    properties.forEach((k, v) {
      if (k.startsWith(prefix)) {
        var key = k.substring(prefix.length);
        try {
          dataSet.putIfAbsent(key, jsonDecode(v.getValue()));
        } catch (e) {
          dataSet.putIfAbsent(key, () => v.getValue());
        }
      }
    });
    String onclick = events['onclick'];
    onclick = onclick.replaceAll('()', '');
    String json = createEvent(id, dataSet, 'onclick');
    print('json = $json');
    methodChannel.invokeMethod(
        'onclick', {'pageId': pageId, 'event': onclick, 'data': json});
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

  List<Widget> _getChildren(Component component) {
    List<Widget> children = []; //先建一个数组用于存放循环生成的widget
    if (null == component) {
      return children;
    }
    component.children?.forEach((it) {
      children.add(_createWidget(it));
    });
    return children;
  }

  Widget _createWidget(Component component) {
    print("createChild tag ${component.tag}");

    var children = _getChildren(component);
    var widget;
    switch (component.tag) {
      case "body":
        var child = _getFirstChild(children);
        widget = Center(child: child);
        break;
      case "column":
        widget = _createColumn(component.properties, children);
        break;
      case "row":
        widget = _createRow(component.properties, children);
        break;
      case "singlechildscrollview":
        var child = _getFirstChild(children);
        widget = _createSingleChildScrollView(component.properties, child);
        break;
//      case "nestedscrollview":
//        var child = _getFirstChild(children);
//        widget = _createNestedScrollView(component.properties, child);
//        break;
      case "clipoval":
        var child = _getFirstChild(children);
        widget = _createClipOval(component.properties, child);
        break;
      case "container":
        var child = _getFirstChild(children);
        widget = _createContainer(component.properties, child);
        break;
      case "expanded":
        var child = _getFirstChild(children);
        widget = Expanded(child: child);
        break;
      case "fractionallysizedbox":
        var child = _getFirstChild(children);
        widget = _createFractionallySizedBox(component.properties, child);
        break;
      case "aspectratio":
        var child = _getFirstChild(children);
        widget = _createAspectRatio(component.properties, child);
        break;
      case "raisedbutton":
        var child = _getFirstChild(children);
        widget =
            _createRaisedButton(component.properties, component.events, child);
        break;
      case "visibility":
        var child = _getFirstChild(children);
        var replacement = _getSecondChild(children);
        widget = _createVisibility(component.properties, child, replacement);
        break;
      case "text":
        widget =
            _createText(component.properties, component.innerHTML.getValue());
        break;
      case "image":
        widget = _createImage(component.properties);
        break;
      default:
        var text = '未实现控件${component.tag}';
        var font = Property('14');
        var color = Property('red');
        component.properties.putIfAbsent('font-size', () => font);
        component.properties.putIfAbsent('color', () => color);
        widget = _createText(component.properties, text);
        break;
    }
    return widget;
  }
}
