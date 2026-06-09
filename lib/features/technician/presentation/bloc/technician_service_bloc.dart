import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/technician_usecases.dart';

abstract class TechnicianServiceEvent {}

class SubmitReadingsRequested extends TechnicianServiceEvent {
  final String jobId;
  final Map<String, dynamic> before;
  final Map<String, dynamic> after;
  final String summary;

  SubmitReadingsRequested({
    required this.jobId,
    required this.before,
    required this.after,
    required this.summary,
  });
}

class UploadProofRequested extends TechnicianServiceEvent {
  final String jobId;
  final String deviceImagePath;
  final String selfieImagePath;
  final String deviceId;
  final Map<String, dynamic> before;
  final Map<String, dynamic> after;

  UploadProofRequested({
    required this.jobId,
    required this.deviceImagePath,
    required this.selfieImagePath,
    required this.deviceId,
    required this.before,
    required this.after,
  });
}

abstract class TechnicianServiceState {}

class TechnicianServiceInitial extends TechnicianServiceState {}

class TechnicianServiceLoading extends TechnicianServiceState {}

class TechnicianServiceReadingsSaved extends TechnicianServiceState {}

class TechnicianServiceProofUploaded extends TechnicianServiceState {}

class TechnicianServiceFailure extends TechnicianServiceState {
  final String error;
  TechnicianServiceFailure({required this.error});
}

class TechnicianServiceBloc extends Bloc<TechnicianServiceEvent, TechnicianServiceState> {
  final SubmitReadingsUsecase submitReadingsUsecase;
  final CompleteJobUsecase completeJobUsecase;
  final PostAnalysisUsecase postAnalysisUsecase;

  TechnicianServiceBloc({
    required this.submitReadingsUsecase,
    required this.completeJobUsecase,
    required this.postAnalysisUsecase,
  }) : super(TechnicianServiceInitial()) {
    on<SubmitReadingsRequested>(_onSubmitReadingsRequested);
    on<UploadProofRequested>(_onUploadProofRequested);
  }

  Future<void> _onSubmitReadingsRequested(
    SubmitReadingsRequested event,
    Emitter<TechnicianServiceState> emit,
  ) async {
    emit(TechnicianServiceLoading());
    try {
      await submitReadingsUsecase(
        jobId: event.jobId,
        before: event.before,
        after: event.after,
        summary: event.summary,
      );
      emit(TechnicianServiceReadingsSaved());
    } catch (e) {
      emit(TechnicianServiceFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onUploadProofRequested(
    UploadProofRequested event,
    Emitter<TechnicianServiceState> emit,
  ) async {
    emit(TechnicianServiceLoading());
    try {
      // 1. Upload images proof to complete complaint
      await completeJobUsecase(
        jobId: event.jobId,
        deviceImagePath: event.deviceImagePath,
        selfieImagePath: event.selfieImagePath,
      );

      // 2. Post readings data for analysis
      await postAnalysisUsecase(
        deviceId: event.deviceId,
        before: event.before,
        after: event.after,
      );

      emit(TechnicianServiceProofUploaded());
    } catch (e) {
      emit(TechnicianServiceFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }
}
