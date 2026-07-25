import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> fetchDevice(String userId) async {
    return await remoteDataSource.fetchDevice(userId);
  }

  @override
  Future<Map<String, dynamic>> fetchDashboardData(String deviceId) async {
    return await remoteDataSource.fetchDashboardData(deviceId);
  }

  @override
  Future<void> submitComplaint({
    required String userId,
    required String deviceId,
    required String description,
    required String issueType,
    required String imagePath,
  }) async {
    await remoteDataSource.submitComplaint(
      userId: userId,
      deviceId: deviceId,
      description: description,
      issueType: issueType,
      imagePath: imagePath,
    );
  }

  @override
  Future<List<dynamic>> fetchComplaintHistory(String userId) async {
    return await remoteDataSource.fetchComplaintHistory(userId);
  }

  @override
  Future<Map<String, dynamic>> fetchCustomerProfile(String userId) async {
    return await remoteDataSource.fetchCustomerProfile(userId);
  }

  @override
  Future<List<dynamic>> fetchReports(String userId) async {
    return await remoteDataSource.fetchReports(userId);
  }

  @override
  Future<Map<String, dynamic>> fetchReportDetails({
    required String userId,
    required String reportDate,
  }) async {
    return await remoteDataSource.fetchReportDetails(
      userId: userId,
      reportDate: reportDate,
    );
  }

  @override
  Future<Map<String, dynamic>> updateCustomerProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    return await remoteDataSource.updateCustomerProfile(
      userId: userId,
      profileData: profileData,
    );
  }
}
