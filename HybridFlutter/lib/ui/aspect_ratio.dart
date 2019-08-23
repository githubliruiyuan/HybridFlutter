import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/expression_util.dart';
import 'package:flutter_app/entity/property.dart';
import 'package:flutter_app/util/widget_util.dart';

class AspectRatioStateful extends BaseWidgetStateful {
  final String _pageId;
  final Component _component;
  final MethodChannel _methodChannel;
  final Widget _child;

  AspectRatioStateful(this._pageId, this._methodChannel,
      this._component, this._child);

  @override
  State<StatefulWidget> createStateX() {
    return _AspectRatioState(_pageId, _methodChannel, _component, _child);
  }
}

class _AspectRatioState extends BaseState<AspectRatioStateful> {
  String _pageId;
  MethodChannel _methodChannel;
  Map<String, Property> _properties;
  Component _component;
  Widget _child;

  _AspectRatioState(this._pageId, this._methodChannel,
      this._component, this._child){
    this._properties = _component.properties;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: dealDoubleDefZero(_properties['aspect-ratio']),
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
