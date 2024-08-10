import 'package:flutter/material.dart';

class SnackbarUtil {
  static void showSnackbar(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onAction,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
