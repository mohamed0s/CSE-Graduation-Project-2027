import 'package:flutter/material.dart';

abstract class AppSnackBar {
  /// Simple title+message snack bar
  static void showSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    //todo:: implement a custom snack bar with title and message
  }

  /// Custom‐styled bottom snack bar
  static void showCustomSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    //todo:: implement a custom snack bar with title and message
  }
}
