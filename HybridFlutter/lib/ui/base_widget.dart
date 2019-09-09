import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';

abstract class BaseWidget extends StatelessWidget {
  String pageId;
  Component component;
  MethodChannel methodChannel;
  BaseWidget parent;
  ValueNotifier<Data> data;

  void setChildren(List<BaseWidget> children) {
    data.value.children = children;
  }

  void updateProperty(List<dynamic> list) {
    list.forEach((it) {
      var property = component.properties[it['key']];
      if (null != property) {
        property.setValue(it['value']);
      }
    });
    var newData = Data(component.properties);
    newData.children = data.value.children;
    data.value = newData;
  }

  void updateChildren(List<BaseWidget> children) {
    var newData = Data(data.value.map);
    newData.children = children;
    data.value = newData;
  }
}
