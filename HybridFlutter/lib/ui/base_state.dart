

import 'package:flutter/cupertino.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  void update();
}