abstract class AuthEvent {
  const AuthEvent();
}

class LoginRequested extends AuthEvent {
  final String phone;
  final String password;
  final String role;

  const LoginRequested({
    required this.phone,
    required this.password,
    required this.role,
  });
}

class ChangePasswordRequested extends AuthEvent {
  final String userId;
  final String newPassword;
  final String confirmPassword;
  final String role;

  const ChangePasswordRequested({
    required this.userId,
    required this.newPassword,
    required this.confirmPassword,
    required this.role,
  });
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class CheckSessionRequested extends AuthEvent {
  const CheckSessionRequested();
}
