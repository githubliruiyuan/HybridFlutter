import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';

import 'basic.dart';

class StackStateless extends BaseWidget {
  StackStateless(BaseWidget parent, String pageId, MethodChannel methodChannel,
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
          var alignment = MAlignmentDirectional.parse(data.map['alignment'],
              defaultValue: AlignmentDirectional.topStart);
          return Stack(
              key: ObjectKey(component),
              alignment: alignment,
              textDirection: MTextDirection.parse(data.map['text-direction']),
              fit: MStackFit.parse(data.map['fit'],
                  defaultValue: StackFit.loose),
              // overflow: MOverflow.parse(data.map['overflow'],
              //     defaultValue: Overflow.clip),
              children: data.children);
        },
        valueListenable: this.data);
  }
}
