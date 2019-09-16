
import 'package:hybrid_flutter/entity/property.dart';

dynamic dealDoubleDefNull(Property property) {
  return null == property ? null : double.parse(removePx(property.getValue()));
}

dynamic dealDoubleDefZero(Property property) {
  return null == property ? 0.0 : double.parse(removePx(property.getValue()));
}

dynamic dealBoolDefNull(Property property) {
  return null == property ? null : 'false' == property.getValue();
}

double dealFontSize(Property property) {
  if (null == property) {
    return 14;
  }
  String str = property.getValue();
  var fontSize;
  if (null == str) {
    fontSize = 14;
  } else {
    fontSize = double.parse(removePx(str));
  }
  return fontSize;
}

String removePx(String pxString) {
  if (pxString == null) {
    return null;
  }
  if (pxString.endsWith('px')) {
    return pxString.replaceAll('px', '');
  }
  return pxString;
}
