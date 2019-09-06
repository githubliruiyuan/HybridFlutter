import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';

import 'basic.dart';

class RowStateless extends BaseWidget {
  RowStateless(BaseWidget parent, String pageId, MethodChannel methodChannel,
      Component component) {
    this.parent = parent;
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        builder: (BuildContext context, List<BaseWidget> value, Widget child) {
          return Row(
              key: ObjectKey(component),
              mainAxisAlignment: MMainAxisAlignment.parse(
                  component.properties["main-axis-alignment"],
                  defaultValue: MainAxisAlignment.start),
              mainAxisSize: MMainAxisSize.parse(
                  component.properties["main-axis-size"],
                  defaultValue: MainAxisSize.max),
              crossAxisAlignment: MCrossAxisAlignment.parse(
                  component.properties["cross-axis-alignment"],
                  defaultValue: CrossAxisAlignment.center),
              textDirection:
                  MTextDirection.parse(component.properties["text-direction"]),
              verticalDirection: MVerticalDirection.parse(
                  component.properties["vertical-direction"],
                  defaultValue: VerticalDirection.down),
              textBaseline:
                  MTextBaseline.parse(component.properties["text-baseline"]),
              children: value);
        },
        valueListenable: children);
  }
}
