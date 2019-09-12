import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';

import 'base_widget.dart';

class VisibilityStateless extends BaseWidget {
  VisibilityStateless(BaseWidget parent, String pageId,
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
          var visiblePro = data.map['visible'];
          var visible = (null != visiblePro && "false" == visiblePro.getValue())
              ? false
              : true;
          return Visibility(
              key: ObjectKey(component),
              visible: visible,
              child: data.children.length > 0 ? data.children[0] : null,
              replacement: data.children.length > 1 ? data.children[1] : const SizedBox.shrink());
        },
        valueListenable: this.data);
  }
}
