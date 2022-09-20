import 'dart:convert';
import 'dart:ffi';
import 'quickjs_dart.dart';
import 'allocation.dart';

import 'ffi_value.dart' as ffiValue;

/// JSValueTypes for type reference
enum JSValueType {
  NUMBER,
  STRING,
  BOOLEAN,
  UNDEFINED,
  NULL,
  OBJECT,
  FUNCTION,
  PROMISE,
  ARRAY,
  UNKNOWN
}

/// JSValue has complex definitions(struct) in C, when defining the JSValue in dart,
/// We are interested in it's type and transformation, like `toDart` or `toJSVal`
/// Each `JSValue` has it's own value, which is Pointer of C, here we simplifying the process of Pointer converting
/// We just use `JSValue` to hold the pointer, until it is released in C
/// To see if the pointer is released, simply use `JSValue.isFreed`
/// In practical, we use `JSEngine` to create JSValue or receive `JSValue` instead of using this class directly
/// Because in `JSEngine` we have `JSContext` complete life-time management,
/// and we don't want to pass `JSContext` and `Pointer` of `JSValue` as parameter everytime.

class JSValue {
  Pointer _ptr;
  Pointer _ctx;
  bool _isFreed = false;
  JSEngine engine;

  bool get isFreed => _isFreed;

  Pointer get context => _ctx;

  int get address => _ptr.address;

  Pointer get value => _ptr;

  int get valueTag => ffiValue.getValueTag(_ptr);

  JSValueType get valueType => _getValueType();

  JSValue get console => JSValue(_ctx, getGlobalObject(_ctx))
      .getProperty("console")
      .getProperty("log");

  JSValue(this._ctx, this._ptr, {this.engine});

  JSValue getProperty(String propertyName) {
    var valPtr = getPropertyStr(_ctx, _ptr, Utf8Fix.toUtf8(propertyName));
    var result = JSValue(_ctx, valPtr);
    if (engine != null) {
      result.engine = engine;
    }
    return result;
  }

  void setPropertyString(String propertyName, JSValue property) {
    setPropertyStr(_ctx, _ptr, Utf8Fix.toUtf8(propertyName), property.value);
  }

  /// set property of js object, eg we have a js_obj,
  ///
  /// ```dart
  /// // say we have a js_obj existed
  /// js_obj.setPropertyValue("someProp",JSValue.newInt32(js_obj.context,1),JS_Flags.JS_PROP_C_W_E);
  /// ```
  /// then we have the object with
  /// ```javascript
  /// {someProp:1}
  /// ```
  void setPropertyValue(String propertyName, JSValue value, int flags) {
    setPropertyInternal(
        _ctx,
        _ptr,
        ffiValue.newAtom(_ctx, Utf8Fix.toUtf8(propertyName)),
        value.value,
        flags);
  }

  void setProperty(dynamic propName, JSValue value, {int flags}) {
    JSValue _propName;
    if (propName is int) {
      _propName = JSValue.newInt32(_ctx, propName);
    } else {
      _propName = JSValue.newString(_ctx, propName.toString());
    }
    setProp(_ctx, _ptr, _propName.value, value.value,
        flags ?? JSFlags.JS_PROP_THROW);
  }

  JSValueType _getValueType() {
    var typeString = toDartStringVal(
        _ctx, ffiValue.atomToString(_ctx, operTypeof(_ctx, _ptr)));
    switch (typeString) {
      case 'number':
        return JSValueType.NUMBER;
      case 'string':
        return JSValueType.STRING;
      case 'undefined':
        return JSValueType.UNDEFINED;
      case 'null':
        return JSValueType.NULL;
      case 'boolean':
        return JSValueType.BOOLEAN;
      case 'object':
        return JSValueType.OBJECT;
      case 'array':
        return JSValueType.ARRAY;
      case 'unknown':
        return JSValueType.UNKNOWN;
      case 'function':
        return JSValueType.FUNCTION;
      default:
        return JSValueType.UNKNOWN;
    }
  }

  void addCallback(DartCallbackClass cb, [JSEngine jsEngine]) {
    if (this.engine == null && jsEngine == null) {
      throw "Have to attach a JSEngine first";
    }
    var _engine = this.engine ?? jsEngine;
    _engine?.createNewFunction(cb.name, cb.callbackWrapper, toVal: this);
  }

  JSValue invokeObject(String propName, [List<JSValue> params]) {
    try {
      if (!getProperty(propName).isFunction()) {
        throw Error();
      }
      Map<String, dynamic> _paramsExecuted = paramsExecutor(params);
      return JSValue(
          _ctx,
          invoke(
              _ctx, // context
              _ptr, // thisval
              JSValue.newAtom(_ctx, propName).value, // atom
              (_paramsExecuted["length"] as int), // argc
              (_paramsExecuted["data"] as Pointer<Pointer>) // argv
              ));
    } catch (e) {
      throw QuickJSError.typeError("not Function").throwError();
    }
  }

  JSValue callJS([List<JSValue> params]) {
    try {
      if (!isFunction()) {
        throw Error();
      }
      Map<String, dynamic> _paramsExecuted = paramsExecutor(params);
      return JSValue(
          _ctx,
          dartCallJS(
              _ctx, // context
              _ptr, //  this_val
              ffiValue.newNull(_ctx), // null
              (_paramsExecuted["length"] as int), // argc
              (_paramsExecuted["data"] as Pointer<Pointer>) // atgv
              ));
    } catch (e) {
      throw QuickJSError.typeError("not Function").throwError();
    }
  }

  List<JSValue> _toUint8ArrayParams(List<Object> paramsToEncode) {
    try {
      if (!isFunction()) {
        throw Error();
      }
      List<JSValue> argvs = List(paramsToEncode.length);
      for (int i = 0; i < paramsToEncode.length; ++i) {
        var params = paramsToEncode[i];
        List<int> paramsIntList = toArray(jsonEncode(params));

        // allocate with json string
        final Pointer<Uint8> pointer = calloc<Uint8>(paramsIntList.length);

        // set pointer value to array value
        for (int j = 0; j < paramsIntList.length; ++j) {
          pointer[j] = paramsIntList[j];
        }
        var jsArrayBuf =
            newArrayBufferCopy(_ctx, pointer, paramsIntList.length);
        // call js object with params
        JSValue argv = JSValue(_ctx, jsArrayBuf);
        argvs[i] = argv;
      }
      return argvs;
    } catch (e) {
      throw QuickJSError.typeError("not Function").throwError();
    }
  }

  JSValue callJSEncode(List<Object> params) {
    try {
      if (!isFunction()) {
        throw Error();
      }
      List<JSValue> argvs = _toUint8ArrayParams(params);

      JSValue callResult = callJS(argvs);
      // pointer is unsafe allocate in dart heap, have to free manually.
      return callResult;
    } catch (e) {
      throw QuickJSError.typeError("not Function").throwError();
    }
  }

  /// make a new js_bool
  JSValue.newBool(this._ctx, bool b, [this.engine]) {
    this._ptr = ffiValue.newBool(_ctx, b == true ? 1 : 0);
  }

  /// make a new js_null
  JSValue.newNull(this._ctx, [this.engine]) {
    this._ptr = ffiValue.newNull(_ctx);
  }

  /// make a new js_null
  JSValue.newUndefined(this._ctx, [this.engine]) {
    this._ptr = ffiValue.newUndefined(_ctx);
  }

  /// make a new js_error
  JSValue.newError(this._ctx, [this.engine]) {
    this._ptr = ffiValue.newError(_ctx);
  }

  /// make a new js_int32
  JSValue.newInt32(this._ctx, int val, [this.engine]) {
    this._ptr = ffiValue.newInt32(_ctx, val);
  }

  /// make a new js_uint32
  JSValue.newUint32(this._ctx, int val, [this.engine]) {
    this._ptr = ffiValue.newUint32(_ctx, val);
  }

  /// make a new js_int64
  JSValue.newInt64(this._ctx, int val, [this.engine]) {
    this._ptr = ffiValue.newInt64(_ctx, val);
  }

  /// make a new js_bigInt64
  JSValue.newBigInt64(this._ctx, int val, [this.engine]) {
    this._ptr = ffiValue.newBigInt64(_ctx, val);
  }

  /// make a new js_bigUint64
  JSValue.newBigUint64(this._ctx, int val, [this.engine]) {
    this._ptr = ffiValue.newBigUint64(_ctx, val);
  }

  JSValue.newFloat64(this._ctx, double val, [this.engine]) {
    this._ptr = ffiValue.newFloat64(_ctx, val);
  }

  JSValue.newString(this._ctx, String val, [this.engine]) {
    this._ptr = ffiValue.newString(_ctx, Utf8Fix.toUtf8(val));
  }

  JSValue.newAtom(this._ctx, String val, [this.engine]) {
    this._ptr = ffiValue.newAtom(_ctx, Utf8Fix.toUtf8(val));
  }

  JSValue.newAtomString(this._ctx, String val, [this.engine]) {
    this._ptr = ffiValue.newAtomString(_ctx, Utf8Fix.toUtf8(val));
  }

  JSValue.newObject(this._ctx, [this.engine]) {
    this._ptr = ffiValue.newObject(_ctx);
  }

  JSValue.newArray(this._ctx, [this.engine]) {
    this._ptr = ffiValue.newArray(_ctx);
  }

  static bool isValNan(Pointer val) {
    return ffiValue.isNan(val) == 0 ? false : true;
  }

  static bool isValString(Pointer val) {
    return ffiValue.isString(val) == 0 ? false : true;
  }

  static bool isValNumber(Pointer val) {
    return ffiValue.isNumber(val) == 0 ? false : true;
  }

  static bool isValNull(Pointer val) {
    return ffiValue.isNull(val) == 0 ? false : true;
  }

  static bool isValBool(Pointer val) {
    return ffiValue.isBool(val) == 0 ? false : true;
  }

  static bool isValObject(Pointer val) {
    return ffiValue.isObject(val) == 0 ? false : true;
  }

  static bool isValSymbol(Pointer val) {
    return ffiValue.isSymbol(val) == 0 ? false : true;
  }

  static bool isValError(Pointer<JSContext> ctx, Pointer val) {
    return ffiValue.isError(ctx, val) == 0 ? false : true;
  }

  static bool isValFunction(Pointer<JSContext> ctx, Pointer val) {
    return ffiValue.isFunction(ctx, val) == 0 ? false : true;
  }

  static bool isValConstructor(Pointer<JSContext> ctx, Pointer val) {
    return ffiValue.isConstructor(ctx, val) == 0 ? false : true;
  }

  static bool isValUndefined(Pointer val) {
    return ffiValue.isUndefined(val) == 0 ? false : true;
  }

  static bool isValUninitialized(Pointer val) {
    return ffiValue.isUninitialized(val) == 0 ? false : true;
  }

  static bool isValBigInt(Pointer<JSContext> ctx, Pointer val) {
    return ffiValue.isBigInt(ctx, val) == 0 ? false : true;
  }

  static bool isValBigFloat(Pointer val) {
    return ffiValue.isBigFloat(val) == 0 ? false : true;
  }

  static bool isValBigDecimal(Pointer val) {
    return ffiValue.isBigDecimal(val) == 0 ? false : true;
  }

  static bool isValArray(Pointer<JSContext> ctx, Pointer val) {
    return ffiValue.isArray(ctx, val) == 0 ? false : true;
  }

  static bool isValExtensible(Pointer<JSContext> ctx, Pointer val) {
    return ffiValue.isExtensible(ctx, val) == 0 ? false : true;
  }

  static bool isValPromise(Pointer<JSContext> ctx, Pointer val) {
    return JSValue(ctx, val).getProperty("then").isFunction();
  }

  static Pointer toJSStringVal(Pointer<JSContext> ctx, Pointer val) {
    try {
      if (JSValue(ctx, val).valueType == JSValueType.UNKNOWN) {
        throw Error();
      }
      return ffiValue.toString(ctx, val);
    } catch (e) {
      throw QuickJSError.typeError("unknown").throwError();
    }
  }

  static String toDartStringVal(Pointer<JSContext> ctx, Pointer val) {
    try {
      return Utf8Fix.fromUtf8(ffiValue.toCString(ctx, val));
    } catch (e) {
      throw e;
    }
  }

  static String toJSONStringVal(Pointer<JSContext> ctx, Pointer val) {
    try {
      if (JSValue(ctx, val).valueType == JSValueType.UNKNOWN) {
        throw Error();
      }
      return JSValue.toDartStringVal(ctx, ffiValue.jsonStringify(ctx, val));
    } catch (e) {
      throw QuickJSError.typeError("unknown").throwError();
    }
  }

  /// determine if value is `NaN`
  bool isNan() {
    return isValNan(_ptr);
  }

  /// determine if value is `string`
  bool isString() {
    return isValString(_ptr);
  }

  /// determine if value is `number`
  bool isNumber() {
    return isValNumber(_ptr);
  }

  /// determine if value is `null`
  bool isNull() {
    return isValNull(_ptr);
  }

  bool isObject() {
    return isValObject(_ptr);
  }

  /// determine if value is `undefined`
  bool isUndefined() {
    return isValUndefined(_ptr);
  }

  /// determine if value is `bool`
  bool isBool() {
    return isValBool(_ptr);
  }

  bool isError() {
    return isValError(_ctx, _ptr);
  }

  bool isConstructor() {
    return isValConstructor(_ctx, _ptr);
  }

  bool isFunction() {
    return isValFunction(_ctx, _ptr);
  }

  /// determine if value is `bool`
  bool isSymbol() {
    return isValSymbol(_ptr);
  }

  /// determine if value is `uninitialized`
  bool isUninitialized() {
    return isValUninitialized(_ptr);
  }

  /// determine if value is `bigInt`
  bool isBigInt() {
    return isValBigInt(_ctx, _ptr);
  }

  /// determine if value is `bigFloat`
  bool isBigFloat() {
    return isValBigFloat(_ptr);
  }

  /// determine if value is `bigDecimal`
  bool isBigDecimal() {
    return isValBigDecimal(_ptr);
  }

  bool isArray() {
    return isValArray(_ctx, _ptr);
  }

  bool isExtensible() {
    return isValExtensible(_ctx, _ptr);
  }

  bool isPromise() {
    return isValPromise(_ctx, _ptr);
  }

  bool isValid() {
    return valueType != JSValueType.UNKNOWN ? true : false;
  }

  Pointer toJSString() {
    try {
      return toJSStringVal(_ctx, _ptr);
    } catch (e) {
      throw e;
    }
  }

  String toDartString() {
    try {
      return toDartStringVal(_ctx, _ptr);
    } catch (e) {
      throw e;
    }
  }

  void free() {
    freeValue(_ctx, _ptr);
    _isFreed = true;
  }

  Pointer copy() {
    return ffiValue.dupValue(_ctx, _ptr);
  }

  String toJSONString() {
    try {
      return toJSONStringVal(_ctx, _ptr);
    } catch (e) {
      throw e;
    }
  }

  JSValue jsPrint({String prependMessage, JSValue value}) {
    var prependString = prependMessage ?? null;
    if (prependString == null) {
      return console.callJS([value ?? this]);
    }
    return console
        .callJS([JSValue.newString(_ctx, prependMessage), value ?? this]);
  }

  void dispose() {
    free();
  }
}
