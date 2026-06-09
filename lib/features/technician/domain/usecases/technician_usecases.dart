import '../repositories/technician_repository.dart';

class FetchJobsUsecase {
  final TechnicianRepository repository;
  FetchJobsUsecase({required this.repository});

  Future<List<dynamic>> call() async {
    return await repository.fetchJobs();
  }
}

class RespondToJobUsecase {
  final TechnicianRepository repository;
  RespondToJobUsecase({required this.repository});

  Future<void> call({required String jobId, required String action}) async {
    await repository.respondToJob(jobId: jobId, action: action);
  }
}

class SubmitReadingsUsecase {
  final TechnicianRepository repository;
  SubmitReadingsUsecase({required this.repository});

  Future<void> call({
    required String jobId,
    required Map<String, dynamic> before,
    required Map<String, dynamic> after,
    required String summary,
  }) async {
    await repository.submitReadings(
      jobId: jobId,
      before: before,
      after: after,
      summary: summary,
    );
  }
}

class CompleteJobUsecase {
  final TechnicianRepository repository;
  CompleteJobUsecase({required this.repository});

  Future<void> call({
    required String jobId,
    required String deviceImagePath,
    required String selfieImagePath,
  }) async {
    await repository.completeJob(
      jobId: jobId,
      deviceImagePath: deviceImagePath,
      selfieImagePath: selfieImagePath,
    );
  }
}

class PostAnalysisUsecase {
  final TechnicianRepository repository;
  PostAnalysisUsecase({required this.repository});

  Future<void> call({
    required String deviceId,
    required Map<String, dynamic> before,
    required Map<String, dynamic> after,
  }) async {
    await repository.postAnalysis(
      deviceId: deviceId,
      before: before,
      after: after,
    );
  }
}

class FetchTechnicianProfileUsecase {
  final TechnicianRepository repository;
  FetchTechnicianProfileUsecase({required this.repository});

  Future<Map<String, dynamic>> call(String technicianId) async {
    return await repository.fetchProfile(technicianId);
  }
}

class UpdateTechnicianProfileUsecase {
  final TechnicianRepository repository;
  UpdateTechnicianProfileUsecase({required this.repository});

  Future<void> call({
    required String technicianId,
    required Map<String, dynamic> profileData,
  }) async {
    await repository.updateProfile(
      technicianId: technicianId,
      profileData: profileData,
    );
  }
}

class UpdateAvailabilityUsecase {
  final TechnicianRepository repository;
  UpdateAvailabilityUsecase({required this.repository});

  Future<void> call({
    required String technicianId,
    required String availability,
  }) async {
    await repository.updateAvailability(
      technicianId: technicianId,
      availability: availability,
    );
  }
}
