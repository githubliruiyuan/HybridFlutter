import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';

class ExpandedStateless extends BaseWidget {
  ExpandedStateless(
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
          return Expanded(
              key: ObjectKey(component),
              child: data.children.isNotEmpty ? data.children[0] : null);
        },
        valueListenable: this.data);
  }
}
