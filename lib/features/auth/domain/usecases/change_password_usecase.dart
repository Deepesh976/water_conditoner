import '../repositories/auth_repository.dart';

class ChangePasswordUsecase {
  final AuthRepository repository;

  ChangePasswordUsecase({required this.repository});

  Future<Map<String, dynamic>> call({
    required String userId,
    required String newPassword,
    required String confirmPassword,
    required String role,
  }) async {
    return await repository.changePassword(
      userId: userId,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
      role: role,
    );
  }
}
