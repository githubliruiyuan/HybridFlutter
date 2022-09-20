import 'dart:ffi';
import 'package:meta/meta.dart';
import 'quickjs_dart.dart';

typedef DartCHandler = Function(
    {Pointer<JSContext> context, JSValue thisVal, List<JSValue> args});

typedef DartFunctionHandler = Function(
    List<JSValue> args, JSEngine engine, JSValue thisVal);

// ignore: camel_case_types
abstract class DartCallbackClass {
  final JSEngine engine;
  final String name;
  final DartFunctionHandler handler;
  get callbackName;
  get callbackHandler;
  get callbackWrapper;

  DartCallbackClass(this.engine, this.name, this.handler);

  wrapperFunc(
      {Pointer<JSContext> context, JSValue thisVal, List<JSValue> args});
}

class DartCallback implements DartCallbackClass {
  DartCallback(
      {@required this.engine, @required this.name, @required this.handler});

  Pointer wrapperFunc(
      {Pointer<JSContext> context, JSValue thisVal, List<JSValue> args}) {
    try {
      // List _dartArgs =
      //     args != null ? args.map((element) => engine.fromJSVal(element)).toList() : null;
      var handlerResult = handler(args, engine, thisVal);

      // print("handler result is $handlerResult");
      if (handlerResult == null) {
        return engine.newUndefined().value;
      } else {
        if (!(handlerResult is Future)) {
          if (handlerResult is JSValue) {
            return dupValue(engine.context, handlerResult.value);
          } else {
            return engine.toJSVal(handlerResult).value;
          }
        }
        var newPromise = engine.globalPromise.callJS(null);
        handlerResult.then((value) {
          newPromise.getProperty("resolve").callJS([
            (value is JSValue)
                ? dupValue(engine.context, value.value)
                : engine.toJSVal(value)
          ]);
          newPromise.free();
          JSEngine.loop(engine);
        }).catchError((e) {
          newPromise
              .getProperty("reject")
              .callJS([engine.newString(e.toString())]);
          newPromise.free();
          JSEngine.loop(engine);
        });
        return newPromise.getProperty("promise").value;
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  JSEngine engine;

  @override
  DartFunctionHandler handler;

  @override
  String name;

  @override
  get callbackName => name;

  @override
  get callbackHandler => handler;

  @override
  get callbackWrapper => wrapperFunc;
}
