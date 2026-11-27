import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'presentation/screens/auth_gate.dart';

class SchoolHubApp extends StatelessWidget {
  const SchoolHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}
