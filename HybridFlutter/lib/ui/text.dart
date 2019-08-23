import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/color_util.dart';
import 'package:flutter_app/util/widget_util.dart';

class TextStateful extends BaseWidgetStateful {

  TextStateful(String pageId, MethodChannel methodChannel, Component component) {
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
  }

  @override
  State<StatefulWidget> createStateX() {
    return _TextState(pageId, methodChannel, component);
  }
}

class _TextState extends BaseState<TextStateful> {
  String _text;

  _TextState(String pageId, MethodChannel methodChannel, Component component) {
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this._text = component.innerHTML.getValue();
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
    return Text(_text,
        style: TextStyle(
            inherit: inherit,
            fontSize: fontSize,
            backgroundColor: backgroundColor,
            color: color));
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void updateChild(BaseWidgetStateful oldChild, BaseWidgetStateful newChild) {
  }

}
