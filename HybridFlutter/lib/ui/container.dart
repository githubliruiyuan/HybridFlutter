import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/color_util.dart';
import 'package:flutter_app/util/expression_util.dart';
import 'package:flutter_app/entity/property.dart';
import 'package:flutter_app/util/widget_util.dart';

import 'basic.dart';

class ContainerStateful extends BaseWidgetStateful {
  final String _pageId;
  final MethodChannel _methodChannel;
  final Component _component;
  final Widget _child;

  ContainerStateful(this._pageId, this._methodChannel, this._component, this._child);

  @override
  State<StatefulWidget> createStateX() {
    return _ContainerState(_pageId, _methodChannel, _component, _child);
  }
}

class _ContainerState extends BaseState<ContainerStateful> {
  String _pageId;
  MethodChannel _methodChannel;
  Component _component;
  Map<String, Property> _properties;
  Widget _child;

  _ContainerState(this._pageId, this._methodChannel, this._component, this._child){
    this._properties = _component.properties;
  }

  @override
  Widget build(BuildContext context) {
    var width = dealDoubleDefNull(_properties['width']);
    var height = dealDoubleDefNull(_properties['height']);

    //处理背景
    Color color = dealColor(_properties['color']);
    var alignment = MAlignment.parse(_properties['alignment'],
        defaultValue: Alignment.topLeft);

    return Container(
        alignment: alignment,
        color: color,
        width: width,
        height: height,
        margin: MMargin.parse(_properties),
        padding: MPadding.parse(_properties),
        child: _child);
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
