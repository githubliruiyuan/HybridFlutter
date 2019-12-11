import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';

import 'base_widget.dart';
import 'basic.dart';

class VisibilityStateless extends BaseWidget {
  VisibilityStateless(BaseWidget parent, String pageId,
      MethodChannel methodChannel, Component component)
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
          return Visibility(
              key: ObjectKey(component),
              visible: MBool.parse(data.map['visible'], defaultValue: true),
              child: data.children.length > 0 ? data.children[0] : null,
              replacement: data.children.length > 1
                  ? data.children[1]
                  : const SizedBox.shrink());
        },
        valueListenable: this.data);
  }
}
