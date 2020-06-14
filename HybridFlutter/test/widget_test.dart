// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';


abstract class A {
  String a;
}

class B extends A {
  B(a){
    this.a = a;
  }
}

void main() {

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {

//    var b = B("qwer");
//    print(b.a);
//    var url = "home?a=1&b=2";
//    var uri = Uri.parse(url);
//    print("uri = ${uri.toString()}");

    var list = [0,1,2,3,4,5];
    print(list.getRange(0, 3));
    print(list.getRange(3, 5));
    list.removeRange(3, 5);
    print(list);


//    double v;
//    print(v);
//    print(v ?? 1);

  });
}
