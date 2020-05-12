import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';

import 'basic.dart';

class SingleChildScrollViewStateless extends BaseWidget {
  SingleChildScrollViewStateless(BaseWidget parent, String pageId,
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
          return SingleChildScrollView(
              key: ObjectKey(component),
              scrollDirection: MAxis.parse(data.map["scroll-direction"],
                  defaultValue: Axis.vertical),
              child: data.children.isNotEmpty ? data.children[0] : null);
        },
        valueListenable: this.data);
  }
}
