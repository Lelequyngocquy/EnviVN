import 'package:flutter/material.dart';
import 'package:envivn/src/shared/widgets/app_top_toast.dart';

extension ContextX on BuildContext {
  double get screenHeight => MediaQuery.sizeOf(this).height;
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get keyboardHeight => MediaQuery.viewInsetsOf(this).bottom;
  double get topPadding => MediaQuery.paddingOf(this).top;
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Shows an iOS-style top floating toast notification that will not cover the bottom bar
  void showSnackBar(String message, {bool isError = false}) {
    AppTopToast.show(this, message, isError: isError);
  }
}
