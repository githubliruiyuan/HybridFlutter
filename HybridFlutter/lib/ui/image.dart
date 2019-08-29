import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/widget_util.dart';

class ImageStateless extends BaseWidget {
  ImageStateless(BaseWidget parent, String pageId,
      MethodChannel methodChannel, Component component) {
    this.parent = parent;
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
  }

  @override
  Widget build(BuildContext context) {
    var width = dealDoubleDefNull(component.properties['width']);
    var height = dealDoubleDefNull(component.properties['height']);
    var src = component.properties['src'].getValue();
    return Image.network(
        null == src ? '' : src,
        key: Key(component.id.toString()),
        width: width,
        height: height);
  }
}
