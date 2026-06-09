abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final Map<String, dynamic> responseData;
  final String role;

  const Authenticated({required this.responseData, required this.role});
}

class Unauthenticated extends AuthState {}

class AuthPasswordChangedSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});
}
