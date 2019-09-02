import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';
import 'package:hybrid_flutter/util/color_util.dart';
import 'package:hybrid_flutter/util/widget_util.dart';

import 'basic.dart';

class ContainerStateless extends BaseWidget {
  ContainerStateless(
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
    var width = dealDoubleDefNull(component.properties['width']);
    var height = dealDoubleDefNull(component.properties['height']);

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
        child: ValueListenableBuilder(
            builder:
                (BuildContext context, List<BaseWidget> value, Widget child) {
              return value.length > 0 ? value[0] : null;
            },
            valueListenable: children));
  }
}
