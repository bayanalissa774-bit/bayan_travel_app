import 'package:flutter/material.dart';

void openPage(
  BuildContext context,
  Widget page, {
  bool replace = false,
}) {
  final route = MaterialPageRoute<void>(
    builder: (_) => page,
  );

  if (replace) {
    Navigator.of(context).pushReplacement(route);
  } else {
    Navigator.of(context).push(route);
  }
}
