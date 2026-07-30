import '../repositories/customer_repository.dart';

class FetchDeviceUsecase {
  final CustomerRepository repository;
  FetchDeviceUsecase({required this.repository});

  Future<Map<String, dynamic>> call(String userId) async {
    return await repository.fetchDevice(userId);
  }
}

class FetchDashboardDataUsecase {
  final CustomerRepository repository;
  FetchDashboardDataUsecase({required this.repository});

  Future<Map<String, dynamic>> call(String deviceId) async {
    return await repository.fetchDashboardData(deviceId);
  }
}

class SubmitComplaintUsecase {
  final CustomerRepository repository;
  SubmitComplaintUsecase({required this.repository});

  Future<void> call({
    required String userId,
    required String deviceId,
    required String description,
    required String issueType,
    required String imagePath,
  }) async {
    await repository.submitComplaint(
      userId: userId,
      deviceId: deviceId,
      description: description,
      issueType: issueType,
      imagePath: imagePath,
    );
  }
}

class FetchComplaintHistoryUsecase {
  final CustomerRepository repository;
  FetchComplaintHistoryUsecase({required this.repository});

  Future<List<dynamic>> call(String userId) async {
    return await repository.fetchComplaintHistory(userId);
  }
}

class FetchCustomerProfileUsecase {
  final CustomerRepository repository;
  FetchCustomerProfileUsecase({required this.repository});

  Future<Map<String, dynamic>> call(String userId) async {
    return await repository.fetchCustomerProfile(userId);
  }
}

class UpdateCustomerProfileUsecase {
  final CustomerRepository repository;
  UpdateCustomerProfileUsecase({required this.repository});

  Future<Map<String, dynamic>> call({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    return await repository.updateCustomerProfile(
      userId: userId,
      profileData: profileData,
    );
  }
}

// ================= REPORTS =================

class FetchReportsUsecase {
  final CustomerRepository repository;

  FetchReportsUsecase({
    required this.repository,
  });

  Future<List<dynamic>> call(
      String userId,
      ) async {
    return await repository.fetchReports(
      userId,
    );
  }
}

//==================================================
// FETCH CUSTOMER ALERTS
//==================================================

class FetchCustomerAlertsUsecase {
  final CustomerRepository repository;

  FetchCustomerAlertsUsecase(this.repository);

  Future<List<dynamic>> call(String userId) {
    return repository.fetchCustomerAlerts(userId);
  }
}

class FetchReportDetailsUsecase {
  final CustomerRepository repository;

  FetchReportDetailsUsecase({
    required this.repository,
  });

  Future<Map<String, dynamic>> call({
    required String userId,
    required String reportDate,
  }) async {
    return await repository.fetchReportDetails(
      userId: userId,
      reportDate: reportDate,
    );
  }
}
