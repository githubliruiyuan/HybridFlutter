import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';
import 'package:hybrid_flutter/util/color_util.dart';
import 'package:hybrid_flutter/util/event_util.dart';

class RaisedButtonStateless extends BaseWidget {
  RaisedButtonStateless(
      BaseWidget parent,
      String pageId,
      MethodChannel methodChannel,
      Component component) {
    this.parent = parent;
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
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
        child: ValueListenableBuilder(
            builder:
                (BuildContext context, List<BaseWidget> value, Widget child) {
              return value.length > 0 ? value[0] : null;
            },
            valueListenable: children));
  }
}
