

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/entity/component.dart';

import 'base_widget.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {

  String pageId;
  Component component;
  MethodChannel methodChannel;
  BaseWidgetStateful parent;
  List<BaseWidgetStateful> children;

  void updateChild(BaseWidgetStateful oldChild, BaseWidgetStateful newChild);

}