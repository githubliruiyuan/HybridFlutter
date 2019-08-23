import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/expression_util.dart';
import 'package:flutter_app/entity/property.dart';

import 'basic.dart';

class ColumnStateful extends BaseWidgetStateful {
  final String _pageId;
  final Component _component;
  final MethodChannel _methodChannel;
  final List<Widget> _children;

  ColumnStateful(
      this._pageId, this._methodChannel, this._component, this._children);

  @override
  State<StatefulWidget> createStateX() {
    return _ColumnState(_pageId, _methodChannel, _component, _children);
  }
}

class _ColumnState extends BaseState<ColumnStateful> {
  String _pageId;
  Component _component;
  MethodChannel _methodChannel;
  Map<String, Property> _properties;
  List<Widget> _children;

  _ColumnState(this._pageId, this._methodChannel,
      this._component, this._children){
    this._properties = _component.properties;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MMainAxisAlignment.parse(
            _properties["main-axis-alignment"],
            defaultValue: MainAxisAlignment.start),
        mainAxisSize: MMainAxisSize.parse(_properties["main-axis-size"],
            defaultValue: MainAxisSize.max),
        crossAxisAlignment: MCrossAxisAlignment.parse(
            _properties["cross-axis-alignment"],
            defaultValue: CrossAxisAlignment.center),
        textDirection: MTextDirection.parse(_properties["text-direction"]),
        verticalDirection: MVerticalDirection.parse(
            _properties["vertical-direction"],
            defaultValue: VerticalDirection.down),
        textBaseline: MTextBaseline.parse(_properties["text-baseline"]),
        children: _children);
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
