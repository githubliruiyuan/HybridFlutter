

class Property {
  String property, _expValue;
  bool containExpression = false;

  Property(this.property) {
    this._expValue = property;
    containExpression = _containExpression(property);
  }

  void setValue(String value) {
    _expValue = value;
  }

  String getValue() {
    return _expValue;
  }

  bool _containExpression(String content) {
    if (null == content) return false;
    var trim = content.trim();
    if (trim.isEmpty) return false;
    return trim.contains("{{") && trim.contains("}}");
  }

  @override
  String toString() {
    return 'Property{property: $property, _expValue: $_expValue}';
  }
}
