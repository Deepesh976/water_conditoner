import 'dart:convert';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';

abstract class AuthRemoteDataSource {
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
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    required String role,
  }) async {
    final url = role == "Technician" ? ApiEndpoints.technicianLogin : ApiEndpoints.userLogin;
    final response = await apiClient.post(
      url,
      body: {
        "phone": phone.trim(),
        "password": password.trim(),
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      Map<String, dynamic> errorData = {};
      try {
        errorData = jsonDecode(response.body);
      } catch (_) {}
      throw Exception(errorData["message"] ?? "Login failed");
    }
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String newPassword,
    required String confirmPassword,
    required String role,
  }) async {
    final url = role == "Technician" ? ApiEndpoints.technicianChangePassword : ApiEndpoints.userChangePassword;
    final body = role == "Technician"
        ? {
            "technicianId": userId,
            "newPassword": newPassword.trim(),
            "confirmPassword": confirmPassword.trim(),
          }
        : {
            "userId": userId,
            "newPassword": newPassword.trim(),
            "confirmPassword": confirmPassword.trim(),
          };

    final response = await apiClient.post(url, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      Map<String, dynamic> errorData = {};
      try {
        errorData = jsonDecode(response.body);
      } catch (_) {}
      throw Exception(errorData["message"] ?? "Password update failed");
    }
  }
}
