import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';
import 'package:hybrid_flutter/util/widget_util.dart';

class CenterStateless extends BaseWidget {
  CenterStateless(BaseWidget parent, String pageId, MethodChannel methodChannel,
      Component component) {
    this.parent = parent;
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
  }

  @override
  Widget build(BuildContext context) {
    var widthFactor = dealDoubleDefZero(component.properties['width-factor']);
    var heightFactor = dealDoubleDefZero(component.properties['height-factor']);
    return Center(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: ValueListenableBuilder(
            builder:
                (BuildContext context, List<BaseWidget> value, Widget child) {
              return value.length > 0 ? value[0] : null;
            },
            valueListenable: children));
  }
}
