import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/entity/property.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/color_util.dart';
import 'package:flutter_app/util/event_util.dart';
import 'package:flutter_app/util/expression_util.dart';

class RaisedButtonStateful extends BaseWidgetStateful {
  final String _pageId;
  final Component _component;
  final MethodChannel _methodChannel;
  final Widget _child;

  RaisedButtonStateful(
      this._pageId, this._methodChannel,
      this._component, this._child);

  @override
  State<StatefulWidget> createStateX() {
    return _RaisedButtonState(
        _pageId, _methodChannel, _component, _child);
  }
}

class _RaisedButtonState extends BaseState<RaisedButtonStateful> {
  String _pageId;
  Component _component;
  MethodChannel _methodChannel;
  Map<String, Property> _properties;
  Map<String, dynamic> _events;
  Widget _child;

  _RaisedButtonState(
      this._pageId, this._methodChannel,
      this._component, this._child){
    this._properties = _component.properties;
    this._events = _component.events;
  }

  @override
  Widget build(BuildContext context) {
    //处理背景
    Color color = dealColor(_properties['color']);
    Color textColor = dealColor(_properties['text-color']);
    Color disabledTextColor = dealColor(_properties['disabled-text-color']);
    Color disabledColor = dealColor(_properties['disabled-color']);
    Color focusColor = dealColor(_properties['focus-color']);
    Color hoverColor = dealColor(_properties['hover-color']);
    Color highlightColor = dealColor(_properties['highlight-color']);
    Color splashColor = dealColor(_properties['splash-color']);
    return RaisedButton(
      onPressed: () {
        if (null != _events['onclick']) {
          onclickEvent(_methodChannel, _pageId, this.hashCode.toString(),
              _properties, _events);
        }
      },
      textColor: textColor,
      disabledTextColor: disabledTextColor,
      color: color,
      disabledColor: disabledColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      child: _child,
    );
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
        });
      }
    }
  }
}
