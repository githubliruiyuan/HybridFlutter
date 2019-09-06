import 'package:hybrid_flutter/entity/component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'base_widget.dart';

class VisibilityStateless extends BaseWidget {

  VisibilityStateless(
      BaseWidget parent,
      String pageId,
      MethodChannel methodChannel,
      Component component) {
    this.parent = parent;
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
  }

  @override
  Widget build(BuildContext context) {
    var visiblePro = component.properties['visible'];
    var visible =
        (null != visiblePro && "false" == visiblePro.getValue()) ? false : true;
    return Visibility(
        key: ObjectKey(component),
        visible: visible,
        child: ValueListenableBuilder(
            builder:
                (BuildContext context, List<BaseWidget> value, Widget child) {
              return value.length > 0 ? value[0] : null;
            },
            valueListenable: children),
        replacement: ValueListenableBuilder(
            builder:
                (BuildContext context, List<BaseWidget> value, Widget child) {
              return value.length > 1 ? value[1] : null;
            },
            valueListenable: children));
  }
}
