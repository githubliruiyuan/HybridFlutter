import 'package:flutter/widgets.dart';
import 'package:hybrid_flutter/entity/property.dart';
import 'package:hybrid_flutter/util/widget_util.dart';

class MAxis {
  static Axis parse(Property value, {Axis defaultValue = Axis.horizontal}) {
    Axis result = defaultValue;
    if (null == value) return result;
    switch (value.getValue()) {
      case 'horizontal':
        result = Axis.horizontal;
        break;
      case 'vertical':
        result = Axis.vertical;
        break;
      default:
        result = defaultValue;
    }
    return result;
  }
}

class MMainAxisAlignment {
  static MainAxisAlignment parse(Property value,
      {MainAxisAlignment defaultValue = MainAxisAlignment.start}) {
    MainAxisAlignment result = defaultValue;
    if (null == value) return result;
    switch (value.getValue()) {
      case 'start':
        result = MainAxisAlignment.start;
        break;
      case 'end':
        result = MainAxisAlignment.end;
        break;
      case 'center':
        result = MainAxisAlignment.center;
        break;
      case 'space-between':
        result = MainAxisAlignment.spaceBetween;
        break;
      case 'space-around':
        result = MainAxisAlignment.spaceAround;
        break;
      case 'space-evenly':
        result = MainAxisAlignment.spaceEvenly;
        break;
      default:
        result = defaultValue;
    }
    return result;
  }
}

class MMainAxisSize {
  static MainAxisSize parse(Property value,
      {MainAxisSize defaultValue = MainAxisSize.min}) {
    MainAxisSize result = defaultValue;
    if (null == value) return result;
    switch (value.getValue()) {
      case 'min':
        result = MainAxisSize.min;
        break;
      case 'max':
        result = MainAxisSize.max;
        break;
      default:
        result = defaultValue;
    }
    return result;
  }
}

class MCrossAxisAlignment {
  static CrossAxisAlignment parse(Property value,
      {CrossAxisAlignment defaultValue = CrossAxisAlignment.start}) {
    CrossAxisAlignment result = defaultValue;
    if (null == value) return result;
    switch (value.getValue()) {
      case 'start':
        result = CrossAxisAlignment.start;
        break;
      case 'end':
        result = CrossAxisAlignment.end;
        break;
      case 'center':
        result = CrossAxisAlignment.center;
        break;
      case 'stretch':
        result = CrossAxisAlignment.stretch;
        break;
      case 'baseline':
        result = CrossAxisAlignment.baseline;
        break;
      default:
        result = defaultValue;
    }
    return result;
  }
}

class MTextBaseline {
  static TextBaseline parse(Property value, {TextBaseline defaultValue}) {
    TextBaseline result = defaultValue;
    if (null == value) return result;
    switch (value.getValue()) {
      case 'alphabetic':
        result = TextBaseline.alphabetic;
        break;
      case 'ideographic':
        result = TextBaseline.ideographic;
        break;
      default:
        result = defaultValue;
    }
    return result;
  }
}

class MVerticalDirection {
  static VerticalDirection parse(Property value,
      {VerticalDirection defaultValue = VerticalDirection.up}) {
    VerticalDirection result = defaultValue;
    if (null == value) return result;
    switch (value.getValue()) {
      case 'up':
        result = VerticalDirection.up;
        break;
      case 'down':
        result = VerticalDirection.down;
        break;
      default:
        result = defaultValue;
    }
    return result;
  }
}

class MTextDirection {
  static TextDirection parse(Property value, {TextDirection defaultValue}) {
    TextDirection result = defaultValue;
    if (null == value) return result;
    switch (value.getValue()) {
      case 'rtl':
        result = TextDirection.rtl;
        break;
      case 'ltr':
        result = TextDirection.ltr;
        break;
      default:
        result = defaultValue;
    }
    return result;
  }
}

class MMargin {
  static EdgeInsets parse(Map<String, Property> properties) {
    var marginLeft = properties['margin-left'];
    var marginTop = properties['margin-top'];
    var marginRight = properties['margin-right'];
    var marginBottom = properties['margin-bottom'];
    EdgeInsets margin;
    if (marginLeft != null ||
        marginTop != null ||
        marginRight != null ||
        marginBottom != null) {
      margin = EdgeInsets.fromLTRB(
          dealDoubleDefZero(marginLeft),
          dealDoubleDefZero(marginTop),
          dealDoubleDefZero(marginRight),
          dealDoubleDefZero(marginBottom));
    }

    if (null != properties['margin']) {
      margin = EdgeInsets.all(dealDoubleDefZero(properties['margin']));
    }
    return margin;
  }
}

class MPadding {
  static EdgeInsets parse(Map<String, Property> properties) {
    var paddingLeft = properties['padding-left'];
    var paddingTop = properties['padding-top'];
    var paddingRight = properties['padding-right'];
    var paddingBottom = properties['padding-bottom'];
    EdgeInsets padding;
    if (paddingLeft != null ||
        paddingTop != null ||
        paddingRight != null ||
        paddingBottom != null) {
      padding = EdgeInsets.fromLTRB(
          dealDoubleDefZero(paddingLeft),
          dealDoubleDefZero(paddingTop),
          dealDoubleDefZero(paddingRight),
          dealDoubleDefZero(paddingBottom));
    }
    if (null != properties['padding']) {
      padding = EdgeInsets.all(dealDoubleDefZero(properties['padding']));
    }
    return padding;
  }
}

class MAlignment {
  static Alignment parse(Property value,
      {Alignment defaultValue = Alignment.topLeft}) {
    Alignment result = defaultValue;
    if (null == value) return result;
    switch (value.getValue()) {
      case 'top-left':
        result = Alignment.topLeft;
        break;
      case 'top-center':
        result = Alignment.topCenter;
        break;
      case 'top-right':
        result = Alignment.topRight;
        break;
      case 'center-left':
        result = Alignment.centerLeft;
        break;
      case 'center':
        result = Alignment.center;
        break;
      case 'center-right':
        result = Alignment.centerRight;
        break;
      case 'bottom-left':
        result = Alignment.bottomLeft;
        break;
      case 'bottom-center':
        result = Alignment.bottomCenter;
        break;
      case 'bottom-right':
        result = Alignment.bottomRight;
        break;
      default:
        // TODO (x,y)
        result = defaultValue;
        break;
    }
    return result;
  }
}

class MBool {
  static bool parse(Property value, {bool defaultValue}) {
    bool result = defaultValue;
    if (null != value) {
      result = 'false' == value.getValue();
    }
    return result;
  }
}

class MInt {
  static int parse(Property value, {int defaultValue}) {
    int result = defaultValue;
    if (null != value) {
      result = int.parse(value.getValue());
    }
    return result;
  }
}

class MDouble {
  static double parse(Property value, {double defaultValue}) {
    double result = defaultValue;
    if (null != value) {
      result = double.parse(value.getValue());
    }
    return result;
  }
}
