import 'dart:convert';
import 'dart:ffi';
import 'dart:io' show Platform;
import 'allocation.dart';

final androidLibName = "libquickjs.so";
final iosLibName = "quickjs.framework/quickjs";

final dylib = Platform.isAndroid
    ? DynamicLibrary.open(androidLibName)
    : Platform.isIOS
        ? DynamicLibrary.process()
        : Platform.isMacOS
            ? DynamicLibrary.open("vm/libquickjs.dylib")
            : Platform.isLinux
                ? DynamicLibrary.open("vm/libquickjs.so")
                : Platform.isWindows
                    ? DynamicLibrary.open("vm/libquickjs.dll")
                    : DynamicLibrary.open("vm/libquickjs.dylib");

// Must Fix Utf8 because QuickJS need end with terminator '\0'
class Utf8Fix extends Struct {
  @Uint8()
  int char;

  static String fromUtf8(Pointer<Utf8Fix> ptr) {
    final units = List<int>();
    var len = 0;
    while (true) {
      final char = ptr.elementAt(len++).ref.char;
      if (char == 0) break;
      units.add(char);
    }
    return Utf8Decoder().convert(units);
  }

  static Pointer<Utf8Fix> toUtf8(String s) {
    final units = Utf8Encoder().convert(s);
    final ptr = calloc<Utf8Fix>(units.length + 1);
    for (var i = 0; i < units.length; i++) {
      ptr.elementAt(i).ref.char = units[i];
    }
    // Add the C string null terminator '\0'
    ptr.elementAt(units.length).ref.char = 0;

    return ptr;
  }
}
