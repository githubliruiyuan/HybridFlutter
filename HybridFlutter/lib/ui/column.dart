import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';

import 'basic.dart';

class ColumnStateful extends BaseWidgetStateful {
  ColumnStateful(
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
    return _ColumnState(pageId, methodChannel, component, children);
  }
}

class _ColumnState extends BaseState<ColumnStateful> {
  _ColumnState(String pageId, MethodChannel methodChannel, Component component,
      List<BaseWidgetStateful> children) {
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.children = children;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MMainAxisAlignment.parse(
            component.properties["main-axis-alignment"],
            defaultValue: MainAxisAlignment.start),
        mainAxisSize: MMainAxisSize.parse(
            component.properties["main-axis-size"],
            defaultValue: MainAxisSize.max),
        crossAxisAlignment: MCrossAxisAlignment.parse(
            component.properties["cross-axis-alignment"],
            defaultValue: CrossAxisAlignment.center),
        textDirection:
            MTextDirection.parse(component.properties["text-direction"]),
        verticalDirection: MVerticalDirection.parse(
            component.properties["vertical-direction"],
            defaultValue: VerticalDirection.down),
        textBaseline:
            MTextBaseline.parse(component.properties["text-baseline"]),
        children: children);
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
    var index = children.indexOf(oldChild);
    children[index] = newChild;
    setState(() {});
  }
}
