import 'package:flutter/widgets.dart';
import 'package:flutter_app/entity/property.dart';

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
      case 'spaceBetween':
        result = MainAxisAlignment.spaceBetween;
        break;
      case 'spaceAround':
        result = MainAxisAlignment.spaceAround;
        break;
      case 'spaceEvenly':
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
  static TextBaseline parse(Property value,
      {TextBaseline defaultValue}) {
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
  static TextDirection parse(Property value,
      {TextDirection defaultValue }) {
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