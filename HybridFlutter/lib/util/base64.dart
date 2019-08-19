import 'dart:convert';

String decodeBase64(String data) {
  if (null == data) return null;
  Utf8Decoder utf8decoder = new Utf8Decoder();
  return utf8decoder
      .convert(String.fromCharCodes(base64Decode(data)).codeUnits);
}