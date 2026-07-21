import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/technician_usecases.dart';

abstract class TechnicianDashboardEvent {}

class FetchJobsRequested extends TechnicianDashboardEvent {
  final String technicianId;
  FetchJobsRequested({required this.technicianId});
}

class RespondJobRequested extends TechnicianDashboardEvent {
  final String jobId;
  final String action;
  final String technicianId;

  RespondJobRequested({
    required this.jobId,
    required this.action,
    required this.technicianId,
  });
}

class AcceptInstallationRequested extends TechnicianDashboardEvent {
  final String deviceId;
  final String technicianId;

  AcceptInstallationRequested({
    required this.deviceId,
    required this.technicianId,
  });
}

class RejectInstallationRequested extends TechnicianDashboardEvent {
  final String deviceId;
  final String technicianId;

  RejectInstallationRequested({
    required this.deviceId,
    required this.technicianId,
  });
}

abstract class TechnicianDashboardState {}

class TechnicianDashboardInitial extends TechnicianDashboardState {}

class TechnicianDashboardLoading extends TechnicianDashboardState {}

class TechnicianDashboardLoaded extends TechnicianDashboardState {
  final List<dynamic> allJobs;
  final List<dynamic> activeJobs;
  final int todayCount;
  final int pendingCount;
  final int completedCount;

  TechnicianDashboardLoaded({
    required this.allJobs,
    required this.activeJobs,
    required this.todayCount,
    required this.pendingCount,
    required this.completedCount,
  });
}

class TechnicianDashboardActionSuccess extends TechnicianDashboardState {}

class TechnicianDashboardFailure extends TechnicianDashboardState {
  final String error;
  TechnicianDashboardFailure({required this.error});
}

class TechnicianDashboardBloc extends Bloc<TechnicianDashboardEvent, TechnicianDashboardState> {
  final FetchJobsUsecase fetchJobsUsecase;
  final FetchInstallationJobsUsecase fetchInstallationJobsUsecase;
  final RespondToJobUsecase respondToJobUsecase;
  final AcceptInstallationUsecase acceptInstallationUsecase;
  final RejectInstallationUsecase rejectInstallationUsecase;

  TechnicianDashboardBloc({
    required this.fetchJobsUsecase,
    required this.fetchInstallationJobsUsecase,
    required this.respondToJobUsecase,
    required this.acceptInstallationUsecase,
    required this.rejectInstallationUsecase,
  }) : super(TechnicianDashboardInitial()) {

    on<FetchJobsRequested>(_onFetchJobsRequested);

    on<RespondJobRequested>(
        _onRespondJobRequested);

    on<AcceptInstallationRequested>(
        _onAcceptInstallation);

    on<RejectInstallationRequested>(
        _onRejectInstallation);
  }

  Future<void> _onFetchJobsRequested(
    FetchJobsRequested event,
    Emitter<TechnicianDashboardState> emit,
  ) async {

    print("========== EVENT RECEIVED ==========");
    print("Technician ID = ${event.technicianId}");

    emit(TechnicianDashboardLoading());
    try {
// Complaint jobs
      final complaints = await fetchJobsUsecase();

// Installation jobs
      final installations = await fetchInstallationJobsUsecase(
        event.technicianId,
      );

      print("===============");
      print("Complaints: ${complaints.length}");
      print("Installations: ${installations.length}");
      print("Complaints Data:");
      print(complaints);
      print("Installation Data:");
      print(installations);
      print("===============");

// Merge both lists
      final List<dynamic> allData = [
        ...complaints,
        ...installations,
      ];

      final List<dynamic> activeJobs = allData.where((job) {
        if (job["type"] == "Installation") {
          return job["technicianStatus"] != "Rejected" &&
              job["technicianStatus"] != "Installed";
        }

        return job["status"] != "Rejected" &&
            job["status"] != "Completed";
      }).toList();

      int pendingCount = 0;
      int completedCount = 0;
      int todayCount = 0;

      final nowIST = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));

      for (var job in allData) {

        final bool isInstallation =
            job["type"] == "Installation";

        final status = isInstallation
            ? job["technicianStatus"]
            : job["status"];

        // Completed Count
        if (!isInstallation &&
            status == "Completed") {
          completedCount++;
        }

        if (isInstallation &&
            status == "Installed") {
          completedCount++;
        }

        // Pending Count
        if (!isInstallation &&
            (status == "Assigned" ||
                status == "Accepted")) {
          pendingCount++;
        }

        if (isInstallation &&
            (status == "Pending" ||
                status == "Accepted")) {
          pendingCount++;
        }

        // Today's Count
        if (job["createdAt"] != null) {
          try {
            final jobDateUtc =
            DateTime.parse(job["createdAt"]);

            final jobDateIST =
            jobDateUtc.add(
              const Duration(
                hours: 5,
                minutes: 30,
              ),
            );

            final isSameDay =
                jobDateIST.year == nowIST.year &&
                    jobDateIST.month ==
                        nowIST.month &&
                    jobDateIST.day ==
                        nowIST.day;

            if (isSameDay) {
              todayCount++;
            }
          } catch (_) {}
        }
      }
      emit(TechnicianDashboardLoaded(
        allJobs: allData,
        activeJobs: activeJobs,
        todayCount: todayCount,
        pendingCount: pendingCount,
        completedCount: completedCount,
      ));
    } catch (e) {
      emit(TechnicianDashboardFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onRespondJobRequested(
    RespondJobRequested event,
    Emitter<TechnicianDashboardState> emit,
  ) async {
    emit(TechnicianDashboardLoading());
    try {
      await respondToJobUsecase(jobId: event.jobId, action: event.action);
      emit(TechnicianDashboardActionSuccess());
      // Re-trigger jobs fetch
      add(FetchJobsRequested(technicianId: event.technicianId));
    } catch (e) {
      emit(TechnicianDashboardFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }
  Future<void> _onAcceptInstallation(
      AcceptInstallationRequested event,
      Emitter<TechnicianDashboardState> emit,
      ) async {

    emit(TechnicianDashboardLoading());

    try {

      await acceptInstallationUsecase(
        event.deviceId,
      );

      add(
        FetchJobsRequested(
          technicianId: event.technicianId,
        ),
      );

    } catch (e) {

      emit(
        TechnicianDashboardFailure(
          error: e.toString(),
        ),
      );

    }

  }
  Future<void> _onRejectInstallation(
      RejectInstallationRequested event,
      Emitter<TechnicianDashboardState> emit,
      ) async {

    emit(TechnicianDashboardLoading());

    try {

      await rejectInstallationUsecase(
        event.deviceId,
      );

      add(
        FetchJobsRequested(
          technicianId: event.technicianId,
        ),
      );

    } catch (e) {

      emit(
        TechnicianDashboardFailure(
          error: e.toString(),
        ),
      );

    }

  }
}
