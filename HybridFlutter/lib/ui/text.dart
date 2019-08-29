import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/color_util.dart';
import 'package:flutter_app/util/widget_util.dart';

class TextStateless extends BaseWidget {
  TextStateless(BaseWidget parent, String pageId,
      MethodChannel methodChannel, Component component) {
    this.parent = parent;
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
  }

  @override
  Widget build(BuildContext context) {
    var fontSize = dealFontSize(component.properties['font-size']);
    Color color = dealFontColor(component.properties['color']);
    Color backgroundColor = dealColor(component.properties['background-color']);
    var inherit = dealBoolDefNull(component.properties['inherit']);
    if (null == inherit) {
      inherit = true;
    }
    return Text(component.innerHTML.getValue(),
        style: TextStyle(
            inherit: inherit,
            fontSize: fontSize,
            backgroundColor: backgroundColor,
            color: color));
  }

}
