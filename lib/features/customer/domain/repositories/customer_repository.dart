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
  Future<List<dynamic>> fetchReports(String userId);

  Future<Map<String, dynamic>> fetchReportDetails({
    required String userId,
    required String reportDate,
  });

  //==================================================
// ALERT HISTORY
//==================================================

  Future<List<dynamic>> fetchCustomerAlerts(
      String userId,
      );
  Future<Map<String, dynamic>> updateCustomerProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  });
}
