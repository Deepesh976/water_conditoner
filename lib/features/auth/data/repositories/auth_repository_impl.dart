import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    required String role,
  }) async {
    return await remoteDataSource.login(
      phone: phone,
      password: password,
      role: role,
    );
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String newPassword,
    required String confirmPassword,
    required String role,
  }) async {
    return await remoteDataSource.changePassword(
      userId: userId,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
      role: role,
    );
  }

  @override
  Future<void> cacheSession({
    required Map<String, dynamic> responseData,
    required String role,
  }) async {
    final deviceId = responseData["device"] != null
        ? responseData["device"]["_id"]
        : "";

    String userId = "";
    String technicianId = "";
    String name = "";
    String phone = "";
    String email = "";

    if (role == "Technician") {
      technicianId = responseData["technician"]?["_id"] ?? "";
      name = responseData["technician"]?["name"] ?? "";
      phone = responseData["technician"]?["phone"] ?? "";
      email = responseData["technician"]?["email"] ?? "";
    } else {
      userId = responseData["user"]?["_id"] ?? "";
      name = responseData["user"]?["name"] ?? "";
      phone = responseData["user"]?["phone"] ?? "";
      email = responseData["user"]?["email"] ?? "";

      // 🔔 Save FCM Token for customer
      try {
        final fcmToken =
        await FirebaseMessaging.instance.getToken();

        if (fcmToken != null && fcmToken.isNotEmpty) {
          final response = await http.post(
            Uri.parse(
              "${ApiEndpoints.baseUrl}/api/users/save-fcm-token",
            ),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "userId": userId,
              "fcmToken": fcmToken,
            }),
          );

          print(
            "FCM Token Save Response: ${response.body}",
          );
        }
      } catch (e) {
        print(
          "Failed to save FCM Token: $e",
        );
      }
    }

    await localDataSource.cacheSession(
      userId: userId,
      technicianId: technicianId,
      deviceId: deviceId,
      name: name,
      role: role,
      phone: phone,
      email: email,
    );
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearSession();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }

  @override
  Future<Map<String, String>> getCachedUserSession() async {
    final userId = await localDataSource.getUserId();
    final technicianId =
    await localDataSource.getTechnicianId();
    final deviceId = await localDataSource.getDeviceId();
    final name = await localDataSource.getName();
    final role = await localDataSource.getRole();

    return {
      "userId": userId,
      "technicianId": technicianId,
      "deviceId": deviceId,
      "name": name,
      "role": role,
    };
  }
}