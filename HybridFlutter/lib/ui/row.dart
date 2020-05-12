import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';

import 'basic.dart';

class RowStateless extends BaseWidget {
  RowStateless(BaseWidget parent, String pageId, MethodChannel methodChannel,
      Component component)
      : super(
            parent: parent,
            pageId: pageId,
            methodChannel: methodChannel,
            component: component,
            data: ValueNotifier(Data(component.properties)));

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        builder: (BuildContext context, Data data, Widget child) {
          return Row(
              key: ObjectKey(component),
              mainAxisAlignment: MMainAxisAlignment.parse(
                  data.map["main-axis-alignment"],
                  defaultValue: MainAxisAlignment.start),
              mainAxisSize: MMainAxisSize.parse(data.map["main-axis-size"],
                  defaultValue: MainAxisSize.max),
              crossAxisAlignment: MCrossAxisAlignment.parse(
                  data.map["cross-axis-alignment"],
                  defaultValue: CrossAxisAlignment.center),
              textDirection: MTextDirection.parse(data.map["text-direction"]),
              verticalDirection: MVerticalDirection.parse(
                  data.map["vertical-direction"],
                  defaultValue: VerticalDirection.down),
              textBaseline: MTextBaseline.parse(data.map["text-baseline"]),
              children: data.children);
        },
        valueListenable: this.data);
  }
}
