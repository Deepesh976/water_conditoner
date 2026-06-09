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
  final RespondToJobUsecase respondToJobUsecase;

  TechnicianDashboardBloc({
    required this.fetchJobsUsecase,
    required this.respondToJobUsecase,
  }) : super(TechnicianDashboardInitial()) {
    on<FetchJobsRequested>(_onFetchJobsRequested);
    on<RespondJobRequested>(_onRespondJobRequested);
  }

  Future<void> _onFetchJobsRequested(
    FetchJobsRequested event,
    Emitter<TechnicianDashboardState> emit,
  ) async {
    emit(TechnicianDashboardLoading());
    try {
      final all = await fetchJobsUsecase();

      final List<dynamic> allData = all
          .where(
            (c) =>
                c["technician"] != null &&
                c["technician"]["_id"] == event.technicianId,
          )
          .toList();

      final List<dynamic> activeJobs = allData
          .where(
            (c) => c["status"] != "Rejected" && c["status"] != "Completed",
          )
          .toList();

      int pendingCount = 0;
      int completedCount = 0;
      int todayCount = 0;

      final nowIST = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));

      for (var job in allData) {
        final status = job["status"];
        if (status == "Completed") {
          completedCount++;
        }
        if (status == "Assigned" || status == "Accepted") {
          pendingCount++;
        }
        if (job["createdAt"] != null) {
          try {
            final jobDateUtc = DateTime.parse(job["createdAt"]);
            final jobDateIST = jobDateUtc.add(const Duration(hours: 5, minutes: 30));
            final isSameDay = jobDateIST.year == nowIST.year &&
                jobDateIST.month == nowIST.month &&
                jobDateIST.day == nowIST.day;
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
}
