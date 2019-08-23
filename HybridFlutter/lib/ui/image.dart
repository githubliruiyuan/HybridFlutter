import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';
import 'package:flutter_app/ui/base_widget.dart';
import 'package:flutter_app/util/expression_util.dart';
import 'package:flutter_app/entity/property.dart';
import 'package:flutter_app/util/widget_util.dart';

class ImageStateful extends BaseWidgetStateful {
  final String _pageId;
  final Component _component;
  final MethodChannel _methodChannel;

  ImageStateful(this._pageId, this._methodChannel, this._component);

  @override
  State<StatefulWidget> createStateX() {
    return _ImageState(_pageId, _methodChannel, _component);
  }
}

class _ImageState extends BaseState<ImageStateful> {
  String _pageId;
  Component _component;
  MethodChannel _methodChannel;
  Map<String, Property> _properties;

  _ImageState(this._pageId, this._methodChannel, this._component){
    this._properties = _component.properties;
  }

  @override
  Widget build(BuildContext context) {
    var width = dealDoubleDefNull(_properties['width']);
    var height = dealDoubleDefNull(_properties['height']);
    var src = _properties['src'].getValue();
    return Image.network(null == src ? '' : src, width: width, height: height);
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
