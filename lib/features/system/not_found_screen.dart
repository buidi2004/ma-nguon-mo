import 'package:flutter/material.dart';

import 'system_status_screen.dart';

class NotFoundScreen extends StatelessWidget {
  final String? path;
  final String? attemptedPath;

  const NotFoundScreen({super.key, this.path, this.attemptedPath});

  @override
  Widget build(BuildContext context) {
    return SystemStatusScreen.notFound(attemptedPath: path ?? attemptedPath);
  }
}
