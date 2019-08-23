

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';
import 'package:flutter_app/ui/base_state.dart';

abstract class BaseWidgetStateful extends StatefulWidget {

  String pageId;
  Component component;
  MethodChannel methodChannel;
  BaseWidgetStateful parent;
  List<BaseWidgetStateful> children;

  BaseState<StatefulWidget> _state;

  State<StatefulWidget> createStateX();

  @override
  State<StatefulWidget> createState() {
    _state = createStateX();
    return _state;
  }

  void updateChild(BaseWidgetStateful oldChild, BaseWidgetStateful newChild) {
    if (null != _state) {
      _state.updateChild(oldChild, newChild);
    }
  }



}