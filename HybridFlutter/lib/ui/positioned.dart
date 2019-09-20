import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';

import 'basic.dart';

class PositionedStateless extends BaseWidget {
  PositionedStateless(BaseWidget parent, String pageId,
      MethodChannel methodChannel, Component component) {
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
          return Positioned(
              key: ObjectKey(component),
              left: MDouble.parse(data.map['left']),
              right: MDouble.parse(data.map['right']),
              top: MDouble.parse(data.map['top']),
              bottom: MDouble.parse(data.map['bottom']),
              width: MDouble.parse(data.map['width']),
              height: MDouble.parse(data.map['height']),
              child: data.children.isNotEmpty ? data.children[0] : null);
        },
        valueListenable: this.data);
  }
}
