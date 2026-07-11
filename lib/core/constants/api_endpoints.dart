class ApiEndpoints {
  static const String baseUrl = "http://10.230.124.204:5000";

  // Auth
  static const String userLogin = "$baseUrl/api/users/login";
  static const String technicianLogin = "$baseUrl/api/technicians/login";
  static const String userChangePassword = "$baseUrl/api/users/change-password";
  static const String technicianChangePassword = "$baseUrl/api/technicians/change-password";

// Customer
  static const String complaints =
      "$baseUrl/api/complaints";

// 🔔 Save Customer FCM Token
  static const String saveFcmToken =
      "$baseUrl/api/users/save-fcm-token";

// Customer Device Details
  static String customerDevice(String userId) =>
      "$baseUrl/api/devices/user/$userId";

// Customer Dashboard Data
  static String customerDashboard(String deviceId) =>
      "$baseUrl/api/analysis/device/$deviceId";

// Customer Profile
  static String userProfile(String userId) =>
      "$baseUrl/api/users/$userId";

  // Technician
  static String completeComplaint(String complaintId) =>
      "$baseUrl/api/complaints/$complaintId/complete";
  static const String analysis = "$baseUrl/api/analysis";
  static String technicianProfile(String technicianId) =>
      "$baseUrl/api/technicians/$technicianId";
  static String technicianAvailability(String technicianId) =>
      "$baseUrl/api/technicians/$technicianId/availability";
  static String respondComplaint(String complaintId) =>
      "$baseUrl/api/complaints/$complaintId/respond";
}
