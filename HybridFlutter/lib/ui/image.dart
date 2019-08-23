import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/widget_util.dart';

class ImageStateful extends BaseWidgetStateful {
  ImageStateful(BaseWidgetStateful parent, String pageId,
      MethodChannel methodChannel, Component component) {
    this.parent = parent;
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
  }

  @override
  State<StatefulWidget> createStateX() {
    return _ImageState(pageId, methodChannel, component);
  }
}

class _ImageState extends BaseState<ImageStateful> {
  _ImageState(String pageId, MethodChannel methodChannel, Component component) {
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
  }

  @override
  Widget build(BuildContext context) {
    var width = dealDoubleDefNull(component.properties['width']);
    var height = dealDoubleDefNull(component.properties['height']);
    var src = component.properties['src'].getValue();
    return Image.network(null == src ? '' : src, width: width, height: height);
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
  void updateChild(BaseWidgetStateful oldChild, BaseWidgetStateful newChild) {}
}
