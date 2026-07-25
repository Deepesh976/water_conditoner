import '../repositories/technician_repository.dart';

/// ================= COMPLAINT JOBS =================

class FetchJobsUsecase {
  final TechnicianRepository repository;

  FetchJobsUsecase({required this.repository});

  Future<List<dynamic>> call() async {
    return await repository.fetchJobs();
  }
}

/// ================= INSTALLATION JOBS =================

class FetchInstallationJobsUsecase {
  final TechnicianRepository repository;

  FetchInstallationJobsUsecase({
    required this.repository,
  });

  Future<List<dynamic>> call(
      String technicianId,
      ) async {
    return await repository.fetchInstallationJobs(
      technicianId,
    );
  }
}

/// ================= TECHNICIAN HISTORY =================

class FetchTechnicianHistoryUsecase {
  final TechnicianRepository repository;

  FetchTechnicianHistoryUsecase({
    required this.repository,
  });

  Future<List<dynamic>> call(
      String technicianId,
      ) async {
    return await repository.fetchTechnicianHistory(
      technicianId,
    );
  }
}

/// ================= INSTALLATION ACTIONS =================

class AcceptInstallationUsecase {
  final TechnicianRepository repository;

  AcceptInstallationUsecase({
    required this.repository,
  });

  Future<void> call(
      String deviceId,
      ) async {
    await repository.acceptInstallation(
      deviceId,
    );
  }
}

class RejectInstallationUsecase {
  final TechnicianRepository repository;

  RejectInstallationUsecase({
    required this.repository,
  });

  Future<void> call(
      String deviceId,
      ) async {
    await repository.rejectInstallation(
      deviceId,
    );
  }
}

class CompleteInstallationUsecase {
  final TechnicianRepository repository;

  CompleteInstallationUsecase({
    required this.repository,
  });

  Future<void> call({
    required String deviceId,
    required String imagePath,
    required String ampere,
    required String voltage,
    required String flowRate,
    required String comment,
  }) async {
    await repository.completeInstallation(
      deviceId: deviceId,
      imagePath: imagePath,
      ampere: ampere,
      voltage: voltage,
      flowRate: flowRate,
      comment: comment,
    );
  }
}

/// ================= SAVE CONDITIONER SETTINGS =================

class SaveConditionerSettingsUsecase {
  final TechnicianRepository repository;

  SaveConditionerSettingsUsecase({
    required this.repository,
  });

  Future<void> call({
    required String deviceId,
    required double channel1Min,
    required double channel1Max,
    required double channel2Min,
    required double channel2Max,
  }) async {
    await repository.saveConditionerSettings(
      deviceId: deviceId,
      channel1Min: channel1Min,
      channel1Max: channel1Max,
      channel2Min: channel2Min,
      channel2Max: channel2Max,
    );
  }
}

/// ================= RESPOND TO JOB =================

class RespondToJobUsecase {
  final TechnicianRepository repository;

  RespondToJobUsecase({
    required this.repository,
  });

  Future<void> call({
    required String jobId,
    required String action,
  }) async {
    await repository.respondToJob(
      jobId: jobId,
      action: action,
    );
  }
}

/// ================= SUBMIT READINGS =================

class SubmitReadingsUsecase {
  final TechnicianRepository repository;

  SubmitReadingsUsecase({
    required this.repository,
  });

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

/// ================= COMPLETE JOB =================

class CompleteJobUsecase {
  final TechnicianRepository repository;

  CompleteJobUsecase({
    required this.repository,
  });

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

/// ================= POST ANALYSIS =================

class PostAnalysisUsecase {
  final TechnicianRepository repository;

  PostAnalysisUsecase({
    required this.repository,
  });

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

/// ================= FETCH PROFILE =================

class FetchTechnicianProfileUsecase {
  final TechnicianRepository repository;

  FetchTechnicianProfileUsecase({
    required this.repository,
  });

  Future<Map<String, dynamic>> call(
      String technicianId,
      ) async {
    return await repository.fetchProfile(
      technicianId,
    );
  }
}

/// ================= UPDATE PROFILE =================

class UpdateTechnicianProfileUsecase {
  final TechnicianRepository repository;

  UpdateTechnicianProfileUsecase({
    required this.repository,
  });

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

/// ================= UPDATE AVAILABILITY =================

class UpdateAvailabilityUsecase {
  final TechnicianRepository repository;

  UpdateAvailabilityUsecase({
    required this.repository,
  });

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