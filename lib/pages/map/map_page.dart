import 'package:flutter/material.dart';

abstract class MapPage extends StatelessWidget {
  const MapPage(this.leading, this.title, {super.key});

  final Widget leading;
  final String title;
}
