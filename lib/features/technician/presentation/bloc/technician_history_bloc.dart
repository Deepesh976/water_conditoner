import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/technician_usecases.dart';

abstract class TechnicianHistoryEvent {}

class FetchTechnicianHistoryRequested extends TechnicianHistoryEvent {
  final String technicianId;
  FetchTechnicianHistoryRequested({required this.technicianId});
}

abstract class TechnicianHistoryState {}

class TechnicianHistoryInitial extends TechnicianHistoryState {}

class TechnicianHistoryLoading extends TechnicianHistoryState {}

class TechnicianHistoryLoaded extends TechnicianHistoryState {
  final List<dynamic> history;
  TechnicianHistoryLoaded({required this.history});
}

class TechnicianHistoryFailure extends TechnicianHistoryState {
  final String error;
  TechnicianHistoryFailure({required this.error});
}

class TechnicianHistoryBloc extends Bloc<TechnicianHistoryEvent, TechnicianHistoryState> {
  final FetchJobsUsecase fetchJobsUsecase;

  TechnicianHistoryBloc({required this.fetchJobsUsecase}) : super(TechnicianHistoryInitial()) {
    on<FetchTechnicianHistoryRequested>(_onFetchHistoryRequested);
  }

  Future<void> _onFetchHistoryRequested(
    FetchTechnicianHistoryRequested event,
    Emitter<TechnicianHistoryState> emit,
  ) async {
    emit(TechnicianHistoryLoading());
    try {
      final all = await fetchJobsUsecase();

      final data = all
          .where(
            (c) =>
                (c["status"] == "Completed" || c["status"] == "Rejected") &&
                ((c["technician"] != null &&
                        c["technician"]["_id"] == event.technicianId) ||
                    c["status"] == "Rejected"),
          )
          .toList();

      emit(TechnicianHistoryLoaded(history: data));
    } catch (e) {
      emit(TechnicianHistoryFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }
}
