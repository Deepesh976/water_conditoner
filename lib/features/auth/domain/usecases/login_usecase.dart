import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase({required this.repository});

  Future<Map<String, dynamic>> call({
    required String phone,
    required String password,
    required String role,
  }) async {
    return await repository.login(phone: phone, password: password, role: role);
  }
}
