import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/entity/property.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/expression_util.dart';

class ExpandedStateful extends BaseWidgetStateful {
  final String _pageId;
  final Component _component;
  final MethodChannel _methodChannel;
  final Widget _child;

  ExpandedStateful(this._pageId, this._methodChannel,
      this._component, this._child);

  @override
  State<StatefulWidget> createStateX() {
    return _ExpandedState(_pageId, _methodChannel, _component, _child);
  }
}

class _ExpandedState extends BaseState<ExpandedStateful> {
  String _pageId;
  Component _component;
  MethodChannel _methodChannel;
  Map<String, Property> _properties;
  Widget _child;

  _ExpandedState(this._pageId, this._methodChannel,
      this._component, this._child) {
    this._properties = _component.properties;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: _child);
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
