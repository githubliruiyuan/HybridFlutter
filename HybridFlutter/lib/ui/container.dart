import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
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
    this.data = ValueNotifier(Data(component.properties));
  }

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(
        builder: (BuildContext context, Data data, Widget child) {

          var width = dealDoubleDefNull(data.map['width']);
          var height = dealDoubleDefNull(data.map['height']);

          Color color = dealColor(data.map['color']);
          var alignment = MAlignment.parse(data.map['alignment'],
              defaultValue: Alignment.topLeft);

          return Container(
              key: ObjectKey(component),
              alignment: alignment,
              color: color,
              width: width,
              height: height,
              margin: MMargin.parse(data.map),
              padding: MPadding.parse(data.map),
              child: data.children.isNotEmpty ? data.children[0] : null);
        },
        valueListenable: this.data);

  }
}
