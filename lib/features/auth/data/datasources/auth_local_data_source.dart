import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<bool> isLoggedIn();
  Future<String> getUserId();
  Future<String> getTechnicianId();
  Future<String> getDeviceId();
  Future<String> getName();
  Future<String> getRole();
  Future<void> cacheSession({
    required String userId,
    required String technicianId,
    required String deviceId,
    required String name,
    required String role,
    required String phone,
    required String email,
  });
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<bool> isLoggedIn() async {
    return sharedPreferences.getBool("isLoggedIn") ?? false;
  }

  @override
  Future<String> getUserId() async {
    return sharedPreferences.getString("userId") ?? "";
  }

  @override
  Future<String> getTechnicianId() async {
    return sharedPreferences.getString("technicianId") ?? "";
  }

  @override
  Future<String> getDeviceId() async {
    return sharedPreferences.getString("deviceId") ?? "";
  }

  @override
  Future<String> getName() async {
    return sharedPreferences.getString("name") ?? "";
  }

  @override
  Future<String> getRole() async {
    return sharedPreferences.getString("role") ?? "";
  }

  @override
  Future<void> cacheSession({
    required String userId,
    required String technicianId,
    required String deviceId,
    required String name,
    required String role,
    required String phone,
    required String email,
  }) async {
    await sharedPreferences.setBool("isLoggedIn", true);
    await sharedPreferences.setString("userId", userId);
    await sharedPreferences.setString("technicianId", technicianId);
    await sharedPreferences.setString("deviceId", deviceId);
    await sharedPreferences.setString("name", name);
    await sharedPreferences.setString("role", role);
    await sharedPreferences.setString("phone", phone);
    await sharedPreferences.setString("email", email);
  }

  @override
  Future<void> clearSession() async {
    await sharedPreferences.remove("isLoggedIn");
    await sharedPreferences.remove("userId");
    await sharedPreferences.remove("technicianId");
    await sharedPreferences.remove("deviceId");
    await sharedPreferences.remove("name");
    await sharedPreferences.remove("role");
    await sharedPreferences.remove("phone");
    await sharedPreferences.remove("email");
  }
}
