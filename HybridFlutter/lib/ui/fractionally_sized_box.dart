import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/widget_util.dart';

class FractionallySizedBoxStateful extends BaseWidgetStateful {
  FractionallySizedBoxStateful(
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
    return _FractionallySizedBoxState(
        pageId, methodChannel, component, children);
  }
}

class _FractionallySizedBoxState
    extends BaseState<FractionallySizedBoxStateful> {
  _FractionallySizedBoxState(String pageId, MethodChannel methodChannel,
      Component component, List<BaseWidgetStateful> children) {
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.children = children;
  }

  @override
  Widget build(BuildContext context) {
    var widthFactor = dealDoubleDefZero(component.properties['width-factor']);
    var heightFactor = dealDoubleDefZero(component.properties['height-factor']);
    return FractionallySizedBox(
        child: children[0],
        widthFactor: widthFactor,
        heightFactor: heightFactor);
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
