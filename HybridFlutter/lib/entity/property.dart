

class Property {
  String property, _expressionValue;

  Property(this.property) {
    this._expressionValue = property;
  }

  void setValue(String value) {
    _expressionValue = value;
  }

  String getValue() {
    return _expressionValue;
  }

  @override
  String toString() {
    return 'Property{property: $property, expressionValue: $_expressionValue}';
  }
}
