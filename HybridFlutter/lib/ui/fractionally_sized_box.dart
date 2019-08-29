import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/widget_util.dart';

class FractionallySizedBoxStateless extends BaseWidget {
  FractionallySizedBoxStateless(
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
    var widthFactor = dealDoubleDefZero(component.properties['width-factor']);
    var heightFactor = dealDoubleDefZero(component.properties['height-factor']);
    return FractionallySizedBox(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: ValueListenableBuilder(
            builder:
                (BuildContext context, List<BaseWidget> value, Widget child) {
              return value[0];
            },
            valueListenable: children));
  }
}
