import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/entity/property.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/color_util.dart';
import 'package:flutter_app/util/expression_util.dart';
import 'package:flutter_app/util/widget_util.dart';

class TextStateful extends BaseWidgetStateful {
  final String _pageId;
  final Component _component;
  final MethodChannel _methodChannel;

  TextStateful(this._pageId, this._methodChannel,
      this._component);

  @override
  State<StatefulWidget> createStateX() {
    return _TextState(_pageId, _methodChannel, _component);
  }
}

class _TextState extends BaseState<TextStateful> {
  String _pageId;
  MethodChannel _methodChannel;
  Map<String, Property> _properties;
  Component _component;
  String _sourceText;
  String _text;

  _TextState(this._pageId, this._methodChannel,
      this._component) {
    this._properties = _component.properties;
    this._sourceText = _component.innerHTML.property;
    this._text = _component.innerHTML.getValue();
  }

  @override
  Widget build(BuildContext context) {
    var fontSize = dealFontSize(_properties['font-size']);
    Color color = dealFontColor(_properties['color']);
    Color backgroundColor = dealColor(_properties['background-color']);
    var inherit = dealBoolDefNull(_properties['inherit']);
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
    //_initProp();
  }

  Future _initProp() async {
    await handleProperty(_methodChannel, _pageId, _component);
    _properties = _component.properties;
  }

  bool _dispose = false;

  @override
  void dispose() {
    super.dispose();
    _dispose = true;
  }

  @override
  Future update() async {
    if (!_dispose) {
      bool needUpdate = await checkProperty(_methodChannel, _pageId, _component);
      if (needUpdate) {
        setState(() {
          _properties =_component.properties;
          _text = _component.innerHTML.getValue();
        });
      }
    }
  }
}
