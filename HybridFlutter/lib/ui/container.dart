import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';

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

          var alignment = MAlignment.parse(data.map['alignment'],
              defaultValue: Alignment.topLeft);

          return Container(
              key: ObjectKey(component),
              alignment: alignment,
              color: MColor.parse(data.map['color']),
              width: MDouble.parse(data.map['width']),
              height: MDouble.parse(data.map['height']),
              margin: MMargin.parse(data.map),
              padding: MPadding.parse(data.map),
              child: data.children.isNotEmpty ? data.children[0] : null);
        },
        valueListenable: this.data);
  }
}
