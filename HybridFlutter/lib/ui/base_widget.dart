

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';

abstract class BaseWidget extends StatelessWidget {

  String pageId;
  Component component;
  MethodChannel methodChannel;
  BaseWidget parent;
  ValueNotifier<List<BaseWidget>> children;


  void setChildren(ValueNotifier<List<BaseWidget>> children) {
    this.children = children;
  }

  void updateChildrenOfParent(ValueNotifier<List<BaseWidget>> newChildren) {
    if (null != parent && parent.children.value != newChildren.value) {
      newChildren.value.forEach((it) {
        it.parent = parent;
      });
      parent.children.value = newChildren.value;
    }
  }
}