import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';

import 'basic.dart';

class SingleChildScrollViewStateful extends BaseWidgetStateful {

  SingleChildScrollViewStateful(String pageId, MethodChannel methodChannel,
      Component component, List<BaseWidgetStateful> children) {
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.children = children;
  }

  @override
  State<StatefulWidget> createStateX() {
    return _SingleChildScrollViewState(pageId, methodChannel, component, children);
  }
}

class _SingleChildScrollViewState extends BaseState<SingleChildScrollViewStateful> {

  _SingleChildScrollViewState(String pageId, MethodChannel methodChannel,
      Component component, List<BaseWidgetStateful> children) {
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.children = children;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: MAxis.parse(component.properties["scrollDirection"],
            defaultValue: Axis.vertical),
        child: children[0]);
  }

  @override
  void initState() {
    super.initState();
    //_initProp();
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
