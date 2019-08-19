import 'package:flutter_app/util/expression_util.dart';

class Property {
  String property, expressionValue;

  Property(String property) {
    this.property = property;
  }

  void setValue(String value) {
    expressionValue = value;
  }

  String getValue() {
    if (!containExpressionSimple(property)) {
      return property;
    } else {
      return expressionValue;
    }
  }

  @override
  String toString() {
    return 'Property{property: $property, expressionValue: $expressionValue}';
  }


}
