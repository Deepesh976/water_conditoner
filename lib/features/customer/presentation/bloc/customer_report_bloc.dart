import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/customer_usecases.dart';

//==================================================
// EVENTS
//==================================================

abstract class CustomerReportEvent {}

class FetchReportsRequested extends CustomerReportEvent {
  final String userId;

  FetchReportsRequested({
    required this.userId,
  });
}

class FetchReportDetailsRequested extends CustomerReportEvent {
  final String userId;
  final String reportDate;

  FetchReportDetailsRequested({
    required this.userId,
    required this.reportDate,
  });
}

//==================================================
// STATES
//==================================================

abstract class CustomerReportState {}

class CustomerReportInitial extends CustomerReportState {}

class CustomerReportLoading extends CustomerReportState {}

class CustomerReportsLoaded extends CustomerReportState {
  final List<dynamic> reports;

  CustomerReportsLoaded({
    required this.reports,
  });
}

class CustomerReportDetailsLoaded extends CustomerReportState {
  final Map<String, dynamic> report;

  CustomerReportDetailsLoaded({
    required this.report,
  });
}

class CustomerReportFailure extends CustomerReportState {
  final String message;

  CustomerReportFailure({
    required this.message,
  });
}//==================================================
// BLOC
//==================================================

class CustomerReportBloc
    extends Bloc<CustomerReportEvent, CustomerReportState> {
  final FetchReportsUsecase fetchReportsUsecase;
  final FetchReportDetailsUsecase fetchReportDetailsUsecase;

  CustomerReportBloc({
    required this.fetchReportsUsecase,
    required this.fetchReportDetailsUsecase,
  }) : super(CustomerReportInitial()) {
    on<FetchReportsRequested>(_fetchReports);

    on<FetchReportDetailsRequested>(
      _fetchReportDetails,
    );
  }

  //==================================================
  // FETCH REPORTS
  //==================================================

  Future<void> _fetchReports(
      FetchReportsRequested event,
      Emitter<CustomerReportState> emit,
      ) async {
    emit(CustomerReportLoading());

    try {
      final reports =
      await fetchReportsUsecase(
        event.userId,
      );

      emit(
        CustomerReportsLoaded(
          reports: reports,
        ),
      );
    } catch (e) {
      emit(
        CustomerReportFailure(
          message: e.toString(),
        ),
      );
    }
  }

  //==================================================
  // FETCH REPORT DETAILS
  //==================================================

  Future<void> _fetchReportDetails(
      FetchReportDetailsRequested event,
      Emitter<CustomerReportState> emit,
      ) async {
    emit(CustomerReportLoading());

    try {
      final report =
      await fetchReportDetailsUsecase(
        userId: event.userId,
        reportDate: event.reportDate,
      );

      emit(
        CustomerReportDetailsLoaded(
          report: report,
        ),
      );
    } catch (e) {
      emit(
        CustomerReportFailure(
          message: e.toString(),
        ),
      );
    }
  }
}