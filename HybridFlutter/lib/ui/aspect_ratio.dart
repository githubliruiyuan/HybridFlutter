import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/widget_util.dart';

class AspectRatioStateful extends BaseWidgetStateful {
  AspectRatioStateful(
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
    return _AspectRatioState(pageId, methodChannel, component, children);
  }
}

class _AspectRatioState extends BaseState<AspectRatioStateful> {
  _AspectRatioState(String pageId, MethodChannel methodChannel,
      Component component, List<BaseWidgetStateful> children) {
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.children = children;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: dealDoubleDefZero(component.properties['aspect-ratio']),
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
