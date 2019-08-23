

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/ui/base_state.dart';

abstract class BaseWidgetStateful extends StatefulWidget {

  BaseState<StatefulWidget> _state;

  State<StatefulWidget> createStateX();

  @override
  State<StatefulWidget> createState() {
    _state = createStateX();
    return _state;
  }

  void update() {
    if (null != _state) {
      _state.update();
    }
  }

}