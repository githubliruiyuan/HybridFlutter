import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_flutter/entity/component.dart';
import 'package:hybrid_flutter/entity/data.dart';
import 'package:hybrid_flutter/ui/base_widget.dart';
import 'package:hybrid_flutter/util/color_util.dart';
import 'package:hybrid_flutter/util/widget_util.dart';

class TextStateless extends BaseWidget {
  TextStateless(BaseWidget parent, String pageId, MethodChannel methodChannel,
      Component component) {
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
          var inherit = dealBoolDefNull(data.map['inherit']);
          if (null == inherit) {
            inherit = true;
          }

          return Text(data.map['innerHTML'].getValue(),
              key: ObjectKey(component),
              style: TextStyle(
                  inherit: inherit,
                  fontSize: dealFontSize(data.map['font-size']),
                  backgroundColor: dealColor(data.map['background-color']),
                  color: dealFontColor(data.map['color'])));
        },
        valueListenable: this.data);
  }
}
