import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';
import 'package:hybrid_flutter/util/widget_util.dart';

class ImageStateless extends BaseWidget {
  ImageStateless(BaseWidget parent, String pageId,
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

          var width = dealDoubleDefNull(data.map['width']);
          var height = dealDoubleDefNull(data.map['height']);
          var src = data.map['src'].getValue();

          return Image.network(
              null == src ? '' : src,
              key: ObjectKey(component),
              width: width,
              height: height);
        },
        valueListenable: this.data);
  }
}
