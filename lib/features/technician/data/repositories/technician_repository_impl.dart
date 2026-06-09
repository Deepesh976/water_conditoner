import '../../domain/repositories/technician_repository.dart';
import '../datasources/technician_remote_data_source.dart';

class TechnicianRepositoryImpl implements TechnicianRepository {
  final TechnicianRemoteDataSource remoteDataSource;

  TechnicianRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<dynamic>> fetchJobs() async {
    return await remoteDataSource.fetchJobs();
  }

  @override
  Future<void> respondToJob({required String jobId, required String action}) async {
    await remoteDataSource.respondToJob(jobId: jobId, action: action);
  }

  @override
  Future<void> submitReadings({
    required String jobId,
    required Map<String, dynamic> before,
    required Map<String, dynamic> after,
    required String summary,
  }) async {
    await remoteDataSource.submitReadings(
      jobId: jobId,
      before: before,
      after: after,
      summary: summary,
    );
  }

  @override
  Future<void> completeJob({
    required String jobId,
    required String deviceImagePath,
    required String selfieImagePath,
  }) async {
    await remoteDataSource.completeJob(
      jobId: jobId,
      deviceImagePath: deviceImagePath,
      selfieImagePath: selfieImagePath,
    );
  }

  @override
  Future<void> postAnalysis({
    required String deviceId,
    required Map<String, dynamic> before,
    required Map<String, dynamic> after,
  }) async {
    await remoteDataSource.postAnalysis(
      deviceId: deviceId,
      before: before,
      after: after,
    );
  }

  @override
  Future<Map<String, dynamic>> fetchProfile(String technicianId) async {
    return await remoteDataSource.fetchProfile(technicianId);
  }

  @override
  Future<void> updateProfile({
    required String technicianId,
    required Map<String, dynamic> profileData,
  }) async {
    await remoteDataSource.updateProfile(
      technicianId: technicianId,
      profileData: profileData,
    );
  }

  @override
  Future<void> updateAvailability({
    required String technicianId,
    required String availability,
  }) async {
    await remoteDataSource.updateAvailability(
      technicianId: technicianId,
      availability: availability,
    );
  }
}
