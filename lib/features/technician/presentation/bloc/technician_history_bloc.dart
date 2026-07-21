import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/technician_usecases.dart';

/// ================= EVENTS =================

abstract class TechnicianHistoryEvent {}

class FetchTechnicianHistoryRequested extends TechnicianHistoryEvent {
  final String technicianId;

  FetchTechnicianHistoryRequested({
    required this.technicianId,
  });
}

/// ================= STATES =================

abstract class TechnicianHistoryState {}

class TechnicianHistoryInitial extends TechnicianHistoryState {}

class TechnicianHistoryLoading extends TechnicianHistoryState {}

class TechnicianHistoryLoaded extends TechnicianHistoryState {
  final List<dynamic> history;

  TechnicianHistoryLoaded({
    required this.history,
  });
}

class TechnicianHistoryFailure extends TechnicianHistoryState {
  final String error;

  TechnicianHistoryFailure({
    required this.error,
  });
}

/// ================= BLOC =================

class TechnicianHistoryBloc
    extends Bloc<TechnicianHistoryEvent, TechnicianHistoryState> {
  final FetchTechnicianHistoryUsecase
  fetchTechnicianHistoryUsecase;

  TechnicianHistoryBloc({
    required this.fetchTechnicianHistoryUsecase,
  }) : super(TechnicianHistoryInitial()) {
    on<FetchTechnicianHistoryRequested>(
      _onFetchHistoryRequested,
    );
  }

  Future<void> _onFetchHistoryRequested(
      FetchTechnicianHistoryRequested event,
      Emitter<TechnicianHistoryState> emit,
      ) async {
    emit(TechnicianHistoryLoading());

    try {
      final history =
      await fetchTechnicianHistoryUsecase(
        event.technicianId,
      );

      emit(
        TechnicianHistoryLoaded(
          history: history,
        ),
      );
    } catch (e) {
      emit(
        TechnicianHistoryFailure(
          error: e
              .toString()
              .replaceAll("Exception: ", ""),
        ),
      );
    }
  }
}