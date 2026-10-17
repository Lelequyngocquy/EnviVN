import 'package:flutter/material.dart';

class GlobalKeyManager {
  static final instance = GlobalKeyManager();
  final GlobalKey<NavigatorState> root = GlobalKey<NavigatorState>(debugLabel: 'root_key');
}

class RouterPath {
  static const splash = '/';
  static const permission = '/permission';
  static const home = '/home';
  static const pollutionMap = '/pollution_map';
  static const twentyFourHours = '/twenty_four_hours';
}
