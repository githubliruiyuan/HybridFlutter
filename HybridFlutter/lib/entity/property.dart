

class Property {
  String property, _expressionValue;
  bool containExpression = false;

  Property(this.property) {
    this._expressionValue = property;
    containExpression = _containExpression(property);
  }

  void setValue(String value) {
    _expressionValue = value;
  }

  String getValue() {
    return _expressionValue;
  }

  bool _containExpression(String content) {
    if (null == content) return false;
    var trim = content.trim();
    if (trim.isEmpty) return false;
    return trim.contains("{{") && trim.contains("}}");
  }

  @override
  String toString() {
    return 'Property{property: $property, expressionValue: $_expressionValue}';
  }
}
