import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
import 'package:hybrid_flutter/entity/property.dart';

abstract class BaseWidget extends StatelessWidget {
  String pageId;
  Component component;
  MethodChannel methodChannel;
  BaseWidget parent;
  ValueNotifier<Data> data;

  void setChildren(List<BaseWidget> children) {
    data.value.children = children;
  }

  void updateProperties(Map<String, Property> properties) {
    var newData = Data(properties);
    newData.children = data.value.children;
    data.value = newData;
  }

  void updateProperty(dynamic it) {
    var property = component.properties[it['key']];
    if (null != property) {
      property.setValue(it['value'].toString());
    }
    var newData = Data(component.properties);
    newData.children = data.value.children;
    data.value = newData;
  }

  void updateChildren(List<BaseWidget> children) {
    var newData = Data(data.value.map);
    newData.children = children;
    data.value = newData;
  }

  void addChildren(List<BaseWidget> children) {
    var newData = Data(data.value.map);
    newData.children = data.value.children;
    newData.children.addAll(children);
    data.value = newData;
  }
}
