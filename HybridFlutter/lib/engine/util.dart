import 'dart:ffi';

import 'allocation.dart';
import 'package:logger/logger.dart';

import 'value.dart';

List<int> toArray(String msg, [String enc]) {
  if (enc == 'hex') {
    List<int> hexRes = List();
    msg = msg.replaceAll(RegExp("[^a-z0-9]"), '');
    if (msg.length % 2 != 0) msg = '0' + msg;
    for (var i = 0; i < msg.length; i += 2) {
      var cul = msg[i] + msg[i + 1];
      var result = int.parse(cul, radix: 16);
      hexRes.add(result);
    }
    return hexRes;
  } else {
    List<int> noHexRes = List();
    for (var i = 0; i < msg.length; i++) {
      var c = msg.codeUnitAt(i);
      var hi = c >> 8;
      var lo = c & 0xff;
      if (hi > 0) {
        noHexRes.add(hi);
        noHexRes.add(lo);
      } else {
        noHexRes.add(lo);
      }
    }

    return noHexRes;
  }
}

Map<String, dynamic> paramsExecutor([List<JSValue> params]) {
  if (params != null) {
    List<int> addressArray = params.map<int>((element) {
      return element.address;
    }).toList();

    final _data = calloc<Pointer<Pointer>>(addressArray.length);

    for (int i = 0; i < addressArray.length; ++i) {
      _data[i] = Pointer.fromAddress(addressArray[i]);
    }
    return {"length": addressArray.length, "data": _data};
  } else {
    final _data2 = calloc<Pointer<Pointer>>(0);
    return {"length": 0, "data": _data2};
  }
}

class PrefixPrinter extends LogPrinter {
  final LogPrinter _realPrinter;
  Map<Level, String> _prefixMap;

  PrefixPrinter(this._realPrinter,
      {debug, verbose, wtf, info, warning, error, nothing})
      : super() {
    _prefixMap = {
      Level.debug: debug ?? '  DEBUG ',
      Level.verbose: verbose ?? 'VERBOSE ',
      Level.wtf: wtf ?? '    WTF ',
      Level.info: info ?? '   INFO ',
      Level.warning: warning ?? 'WARNING ',
      Level.error: error ?? '  ERROR ',
      Level.nothing: nothing ?? 'NOTHING',
    };
  }

  @override
  List<String> log(LogEvent event) {
    return _realPrinter
        .log(event)
        .map((s) => '${_prefixMap[event.level]}$s')
        .toList();
  }
}

Logger logger = Logger(
  printer: PrefixPrinter(HybridPrinter(
      PrettyPrinter(
          methodCount: 0, colors: false, printTime: true, printEmojis: true),
      debug: SimplePrinter())), //OneLinePrinter(),
);

String trimQuote(String fdId) {
  if (fdId.indexOf("\"") == 0) {
    fdId = fdId.substring(1, fdId.length); //去掉第一个 "
  }
  if (fdId.lastIndexOf("\"") == (fdId.length - 1)) {
    fdId = fdId.substring(0, fdId.length - 1);
  }
  //去掉最后一个 "

  return fdId;
}
