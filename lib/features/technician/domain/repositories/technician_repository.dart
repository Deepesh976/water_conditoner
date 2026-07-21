abstract class TechnicianRepository {

  // ================= COMPLAINT JOBS =================

  Future<List<dynamic>> fetchJobs();

  // ================= INSTALLATION JOBS =================

  Future<List<dynamic>> fetchInstallationJobs(
      String technicianId,
      );

  // ================= HISTORY =================

  Future<List<dynamic>> fetchTechnicianHistory(
      String technicianId,
      );

  // ================= INSTALLATION ACTIONS =================

  Future<void> acceptInstallation(
      String deviceId,
      );

  Future<void> rejectInstallation(
      String deviceId,
      );

  Future<void> completeInstallation({
    required String deviceId,
    required String imagePath,
    required String ampere,
    required String voltage,
    required String flowRate,
    required String comment,
  });

  Future<void> respondToJob({
    required String jobId,
    required String action,
  });

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

  Future<Map<String, dynamic>> fetchProfile(
      String technicianId,
      );

  Future<void> updateProfile({
    required String technicianId,
    required Map<String, dynamic> profileData,
  });

  Future<void> updateAvailability({
    required String technicianId,
    required String availability,
  });
}