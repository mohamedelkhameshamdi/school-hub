import 'app_role.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  final String uid;
  final String name;
  final String email;
  final AppRole role;

  bool get isAdmin => role == AppRole.admin;
}
