import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_widget.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ValueListenableBuilder(
            builder:
                (BuildContext context, List<BaseWidget> value, Widget child) {
              return value[0];
            },
            valueListenable: children));
  }
}
