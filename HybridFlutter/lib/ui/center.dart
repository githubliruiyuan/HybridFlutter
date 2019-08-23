import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';

class CenterStateful extends BaseWidgetStateful {

  CenterStateful(String pageId, MethodChannel methodChannel,
      Component component, List<BaseWidgetStateful> children) {
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.children = children;
  }

  @override
  State<StatefulWidget> createStateX() {
    return _CenterState(pageId, methodChannel, component, children);
  }
}

class _CenterState extends BaseState<CenterStateful> {
  _CenterState(String pageId, MethodChannel methodChannel,
      Component component, List<BaseWidgetStateful> children) {
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.children = children;
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: children[0]);
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
