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

class SingleChildScrollViewStateful extends BaseWidgetStateful {
  final String _pageId;
  final Component _component;
  final MethodChannel _methodChannel;
  final Widget _child;

  SingleChildScrollViewStateful(
      this._pageId, this._methodChannel, this._component, this._child);

  @override
  State<StatefulWidget> createStateX() {
    return _SingleChildScrollViewState(
        _pageId, _methodChannel, _component, _child);
  }
}

class _SingleChildScrollViewState
    extends BaseState<SingleChildScrollViewStateful> {
  String _pageId;
  Component _component;
  MethodChannel _methodChannel;
  Map<String, Property> _properties;
  Widget _child;

  _SingleChildScrollViewState(
      this._pageId, this._methodChannel, this._component, this._child){
    this._properties = _component.properties;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: MAxis.parse(_properties["scrollDirection"],
            defaultValue: Axis.vertical),
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
