import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/color_util.dart';
import 'package:flutter_app/util/widget_util.dart';

import 'basic.dart';

class ContainerStateful extends BaseWidgetStateful {
  ContainerStateful(
      BaseWidgetStateful parent,
      String pageId,
      MethodChannel methodChannel,
      Component component,
      List<BaseWidgetStateful> children) {
    this.parent = parent;
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.children = children;
  }

  @override
  State<StatefulWidget> createStateX() {
    return _ContainerState(pageId, methodChannel, component, children);
  }
}

class _ContainerState extends BaseState<ContainerStateful> {
  _ContainerState(String pageId, MethodChannel methodChannel,
      Component component, List<BaseWidgetStateful> children) {
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.children = children;
  }

  @override
  Widget build(BuildContext context) {
    var width = dealDoubleDefNull(component.properties['width']);
    var height = dealDoubleDefNull(component.properties['height']);

    //处理背景
    Color color = dealColor(component.properties['color']);
    var alignment = MAlignment.parse(component.properties['alignment'],
        defaultValue: Alignment.topLeft);

    return Container(
        alignment: alignment,
        color: color,
        width: width,
        height: height,
        margin: MMargin.parse(component.properties),
        padding: MPadding.parse(component.properties),
        child: children[0]);
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
