abstract class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    required String role,
  });

  Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String newPassword,
    required String confirmPassword,
    required String role,
  });

  Future<void> cacheSession({
    required Map<String, dynamic> responseData,
    required String role,
  });

  Future<void> logout();

  Future<bool> isLoggedIn();

  Future<Map<String, String>> getCachedUserSession();
}
