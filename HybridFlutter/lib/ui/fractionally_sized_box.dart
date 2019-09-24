import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';
import 'package:hybrid_flutter/ui/basic.dart';

class FractionallySizedBoxStateless extends BaseWidget {
  FractionallySizedBoxStateless(BaseWidget parent, String pageId,
      MethodChannel methodChannel, Component component) {
    this.parent = parent;
    this.pageId = pageId;
    this.methodChannel = methodChannel;
    this.component = component;
    this.data = ValueNotifier(Data(component.properties));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        builder: (BuildContext context, Data data, Widget child) {
          var widthFactor =
              MDouble.parse(data.map['width-factor'], defaultValue: 0);
          var heightFactor =
              MDouble.parse(data.map['height-factor'], defaultValue: 0);
          return FractionallySizedBox(
              key: ObjectKey(component),
              widthFactor: widthFactor,
              heightFactor: heightFactor,
              child: data.children.isNotEmpty ? data.children[0] : null);
        },
        valueListenable: this.data);
  }
}
