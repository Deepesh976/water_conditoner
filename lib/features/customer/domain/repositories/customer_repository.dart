abstract class CustomerRepository {
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
  Future<Map<String, dynamic>> updateCustomerProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  });
}
