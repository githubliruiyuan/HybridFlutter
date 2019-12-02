import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
import 'package:hybrid_flutter/ui/basic.dart';

import 'base_widget.dart';

class CircularProgressIndicatorStateless extends BaseWidget {
  CircularProgressIndicatorStateless(BaseWidget parent, String pageId,
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
          return CircularProgressIndicator(
            key: ObjectKey(component),
            value: MDouble.parse(data.map['value']),
            backgroundColor: MColor.parse(data.map['background-color']),
//            valueColor: ,
            strokeWidth:
                MDouble.parse(data.map["stroke-width"], defaultValue: 4.0),
            semanticsLabel: data.map["semantics-label"]?.getValue(),
            semanticsValue: data.map["semantics-value"]?.getValue(),
          );
        },
        valueListenable: this.data);
  }
}
