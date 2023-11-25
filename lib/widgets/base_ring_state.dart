import 'package:flutter/material.dart';

abstract class BaseRing {
  void animateColors();
}

abstract class BaseRingState<T extends StatefulWidget> extends State<T>
    implements BaseRing {
  @override
  void animateColors() {}
}
