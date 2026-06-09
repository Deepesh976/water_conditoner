import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final ChangePasswordUsecase changePasswordUsecase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUsecase,
    required this.changePasswordUsecase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckSessionRequested>(_onCheckSessionRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final responseData = await loginUsecase(
        phone: event.phone,
        password: event.password,
        role: event.role,
      );

      // Verify device assignment for Customer
      final deviceId = responseData["device"] != null ? responseData["device"]["_id"] : "";
      if (event.role == "Customer" && (deviceId == null || deviceId.toString().isEmpty)) {
        emit(const AuthFailure(error: "No device assigned. Contact admin."));
        return;
      }

      if (responseData["message"] != "Login successful") {
        emit(AuthFailure(error: responseData["message"] ?? "Login failed"));
        return;
      }

      await authRepository.cacheSession(
        responseData: responseData,
        role: event.role,
      );

      emit(Authenticated(responseData: responseData, role: event.role));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onChangePasswordRequested(ChangePasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await changePasswordUsecase(
        userId: event.userId,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
        role: event.role,
      );

      emit(AuthPasswordChangedSuccess());
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(Unauthenticated());
  }

  Future<void> _onCheckSessionRequested(CheckSessionRequested event, Emitter<AuthState> emit) async {
    final isLoggedIn = await authRepository.isLoggedIn();
    if (isLoggedIn) {
      final session = await authRepository.getCachedUserSession();
      emit(Authenticated(
        responseData: {
          "user": {"_id": session["userId"], "name": session["name"]},
          "technician": {"_id": session["technicianId"], "name": session["name"]},
          "device": {"_id": session["deviceId"]},
          "message": "Login successful",
        },
        role: session["role"] ?? "",
      ));
    } else {
      emit(Unauthenticated());
    }
  }
}
