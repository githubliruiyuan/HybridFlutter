import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/color_util.dart';
import 'package:flutter_app/util/event_util.dart';

class RaisedButtonStateful extends BaseWidgetStateful {
  RaisedButtonStateful(String pageId, MethodChannel methodChannel,
      Component component, List<BaseWidgetStateful> children) {
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.children = children;
  }

  @override
  State<StatefulWidget> createStateX() {
    return _RaisedButtonState(pageId, methodChannel, component, children);
  }
}

class _RaisedButtonState extends BaseState<RaisedButtonStateful> {
  _RaisedButtonState(String pageId, MethodChannel methodChannel,
      Component component, List<BaseWidgetStateful> children) {
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.children = children;
  }

  @override
  Widget build(BuildContext context) {
    Color color = dealColor(component.properties['color']);
    Color textColor = dealColor(component.properties['text-color']);
    Color disabledTextColor =
        dealColor(component.properties['disabled-text-color']);
    Color disabledColor = dealColor(component.properties['disabled-color']);
    Color focusColor = dealColor(component.properties['focus-color']);
    Color hoverColor = dealColor(component.properties['hover-color']);
    Color highlightColor = dealColor(component.properties['highlight-color']);
    Color splashColor = dealColor(component.properties['splash-color']);
    return RaisedButton(
      onPressed: () {
        if (null != component.events['onclick']) {
          onclickEvent(methodChannel, pageId, this.hashCode.toString(),
              component.properties, component.events);
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
      child: children[0],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void updateChild(BaseWidgetStateful oldChild, BaseWidgetStateful newChild) {
    setState(() {
      this.children = [newChild];
    });
  }
}
