import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';

abstract class TechnicianRemoteDataSource {
  Future<List<dynamic>> fetchJobs();
  Future<void> respondToJob({required String jobId, required String action});
  Future<void> submitReadings({
    required String jobId,
    required Map<String, dynamic> before,
    required Map<String, dynamic> after,
    required String summary,
  });
  Future<void> completeJob({
    required String jobId,
    required String deviceImagePath,
    required String selfieImagePath,
  });
  Future<void> postAnalysis({
    required String deviceId,
    required Map<String, dynamic> before,
    required Map<String, dynamic> after,
  });
  Future<Map<String, dynamic>> fetchProfile(String technicianId);
  Future<void> updateProfile({
    required String technicianId,
    required Map<String, dynamic> profileData,
  });
  Future<void> updateAvailability({
    required String technicianId,
    required String availability,
  });
}

class TechnicianRemoteDataSourceImpl implements TechnicianRemoteDataSource {
  final ApiClient apiClient;

  TechnicianRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<dynamic>> fetchJobs() async {
    final response = await apiClient.get(ApiEndpoints.complaints);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load jobs");
    }
  }

  @override
  Future<void> respondToJob({required String jobId, required String action}) async {
    final response = await apiClient.put(
      ApiEndpoints.respondComplaint(jobId),
      body: {"action": action},
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to respond to job");
    }
  }

  @override
  Future<void> submitReadings({
    required String jobId,
    required Map<String, dynamic> before,
    required Map<String, dynamic> after,
    required String summary,
  }) async {
    final response = await apiClient.put(
      ApiEndpoints.completeComplaint(jobId),
      body: {
        "before": before,
        "after": after,
        "summary": summary,
      },
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to save readings");
    }
  }

  @override
  Future<void> completeJob({
    required String jobId,
    required String deviceImagePath,
    required String selfieImagePath,
  }) async {
    final fileDevice = await http.MultipartFile.fromPath("deviceImage", deviceImagePath);
    final fileSelfie = await http.MultipartFile.fromPath("technicianSelfie", selfieImagePath);

    final streamedResponse = await apiClient.multipartRequest(
      method: "PUT",
      url: ApiEndpoints.completeComplaint(jobId),
      fields: {},
      files: [fileDevice, fileSelfie],
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception("Failed to upload proofs");
    }
  }

  @override
  Future<void> postAnalysis({
    required String deviceId,
    required Map<String, dynamic> before,
    required Map<String, dynamic> after,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.analysis,
      body: {
        "device": deviceId,
        "serviceCompleted": true,
        "beforeServiceReadings": before,
        "afterServiceReadings": after,
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to post analysis");
    }
  }

  @override
  Future<Map<String, dynamic>> fetchProfile(String technicianId) async {
    final response = await apiClient.get(ApiEndpoints.technicianProfile(technicianId));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch technician profile");
    }
  }

  @override
  Future<void> updateProfile({
    required String technicianId,
    required Map<String, dynamic> profileData,
  }) async {
    final response = await apiClient.put(
      ApiEndpoints.technicianProfile(technicianId),
      body: profileData,
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update technician profile");
    }
  }

  @override
  Future<void> updateAvailability({
    required String technicianId,
    required String availability,
  }) async {
    final response = await apiClient.patch(
      ApiEndpoints.technicianAvailability(technicianId),
      body: {"availability": availability},
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update availability");
    }
  }
}
