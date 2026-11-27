enum AppRole {
  student,
  admin;

  /// Anything that is not exactly "admin" is treated as a student.
  static AppRole fromString(String? value) =>
      value == 'admin' ? AppRole.admin : AppRole.student;
}
