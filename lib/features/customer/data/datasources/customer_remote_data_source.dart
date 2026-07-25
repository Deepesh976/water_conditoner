import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';

abstract class CustomerRemoteDataSource {
  Future<Map<String, dynamic>> fetchDevice(String userId);
  Future<Map<String, dynamic>> fetchDashboardData(String deviceId);
  Future<void> submitComplaint({
    required String userId,
    required String deviceId,
    required String description,
    required String issueType,
    required String imagePath,
  });
  Future<List<dynamic>> fetchComplaintHistory(String userId);
  Future<Map<String, dynamic>> fetchCustomerProfile(String userId);
  Future<List<dynamic>> fetchReports(String userId);

  Future<Map<String, dynamic>> fetchReportDetails({
    required String userId,
    required String reportDate,
  });
  Future<Map<String, dynamic>> updateCustomerProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  });
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final ApiClient apiClient;

  CustomerRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> fetchDevice(String userId) async {
    final response = await apiClient.get(ApiEndpoints.customerDevice(userId));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Device not found");
    }
  }

  @override
  Future<Map<String, dynamic>> fetchDashboardData(String deviceId) async {
    final response = await apiClient.get(ApiEndpoints.customerDashboard(deviceId));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load dashboard data");
    }
  }

  @override
  Future<void> submitComplaint({
    required String userId,
    required String deviceId,
    required String description,
    required String issueType,
    required String imagePath,
  }) async {
    final fields = {
      "user": userId,
      "device": deviceId,
      "description": description,
      "type": issueType,
    };

    final file = await http.MultipartFile.fromPath("image", imagePath);

    final streamedResponse = await apiClient.multipartRequest(
      method: "POST",
      url: ApiEndpoints.complaints,
      fields: fields,
      files: [file],
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw Exception("Failed to submit complaint: ${response.statusCode}");
    }
  }

  @override
  Future<List<dynamic>> fetchComplaintHistory(String userId) async {
    final url = "${ApiEndpoints.complaints}/user/$userId";
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load complaint history");
    }
  }

  @override
  Future<Map<String, dynamic>> fetchCustomerProfile(String userId) async {
    final response = await apiClient.get(ApiEndpoints.userProfile(userId));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load user profile");
    }
  }

  @override
  Future<List<dynamic>> fetchReports(String userId) async {
    final response = await apiClient.get(
      "${ApiEndpoints.baseUrl}/api/reports/$userId",
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["reports"] ?? [];
    } else {
      throw Exception("Failed to load reports");
    }
  }

  @override
  Future<Map<String, dynamic>> fetchReportDetails({
    required String userId,
    required String reportDate,
  }) async {
    final response = await apiClient.get(
      "${ApiEndpoints.baseUrl}/api/reports/$userId/$reportDate",
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["report"];
    } else {
      throw Exception("Failed to load report details");
    }
  }

  @override
  Future<Map<String, dynamic>> updateCustomerProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    final response = await apiClient.put(
      ApiEndpoints.userProfile(userId),
      body: profileData,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update profile");
    }
  }
}
