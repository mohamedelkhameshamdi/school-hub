import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/firestore_school_repository.dart';
import '../../data/repositories/school_repository.dart';
import '../../data/services/auth_service.dart';
import 'home_shell.dart';
import 'login_screen.dart';

/// Decides what to show: login screen, or the app for the signed-in role.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _auth = AuthService();
  final SchoolRepository _repository = FirestoreSchoolRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }
        final user = snapshot.data;
        if (user == null) return LoginScreen(authService: _auth);
        return _UserLoader(
          key: ValueKey(user.uid),
          user: user,
          authService: _auth,
          repository: _repository,
        );
      },
    );
  }
}

class _UserLoader extends StatefulWidget {
  const _UserLoader({
    super.key,
    required this.user,
    required this.authService,
    required this.repository,
  });

  final User user;
  final AuthService authService;
  final SchoolRepository repository;

  @override
  State<_UserLoader> createState() => _UserLoaderState();
}

class _UserLoaderState extends State<_UserLoader> {
  late final Stream<AppUser> _stream =
      widget.authService.watchUser(widget.user);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser>(
      stream: _stream,
      builder: (context, snapshot) {
        final appUser = snapshot.data;
        if (appUser == null) return const _Splash();
        return HomeShell(
          user: appUser,
          authService: widget.authService,
          repository: widget.repository,
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
