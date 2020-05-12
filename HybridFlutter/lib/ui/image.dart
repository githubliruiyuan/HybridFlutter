import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';
import 'package:hybrid_flutter/ui/basic.dart';

class ImageStateless extends BaseWidget {
  ImageStateless(BaseWidget parent, String pageId, MethodChannel methodChannel,
      Component component)
      : super(
            parent: parent,
            pageId: pageId,
            methodChannel: methodChannel,
            component: component,
            data: ValueNotifier(Data(component.properties)));

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        builder: (BuildContext context, Data data, Widget child) {
          var src = data.map['src'].getValue();
          return Image.network(null == src ? '' : src,
              key: ObjectKey(component),
              width: MDouble.parse(data.map['width']),
              height: MDouble.parse(data.map['height']));
        },
        valueListenable: this.data);
  }
}
