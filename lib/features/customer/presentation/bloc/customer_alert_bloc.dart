import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/customer_usecases.dart';

//==================================================
// EVENTS
//==================================================

abstract class CustomerAlertEvent {}

class FetchCustomerAlertsRequested extends CustomerAlertEvent {
  final String userId;

  FetchCustomerAlertsRequested({
    required this.userId,
  });
}

//==================================================
// STATES
//==================================================

abstract class CustomerAlertState {}

class CustomerAlertInitial extends CustomerAlertState {}

class CustomerAlertLoading extends CustomerAlertState {}

class CustomerAlertLoaded extends CustomerAlertState {
  final List<dynamic> alerts;

  CustomerAlertLoaded({
    required this.alerts,
  });
}

class CustomerAlertFailure extends CustomerAlertState {
  final String message;

  CustomerAlertFailure({
    required this.message,
  });
}

//==================================================
// BLOC
//==================================================

class CustomerAlertBloc
    extends Bloc<CustomerAlertEvent, CustomerAlertState> {

  final FetchCustomerAlertsUsecase
  fetchCustomerAlertsUsecase;

  CustomerAlertBloc({
    required this.fetchCustomerAlertsUsecase,
  }) : super(CustomerAlertInitial()) {

    on<FetchCustomerAlertsRequested>(
      _fetchAlerts,
    );
  }

  //==================================================
  // FETCH ALERTS
  //==================================================

  Future<void> _fetchAlerts(
      FetchCustomerAlertsRequested event,
      Emitter<CustomerAlertState> emit,
      ) async {

    emit(CustomerAlertLoading());

    try {

      final alerts =
      await fetchCustomerAlertsUsecase.call(
        event.userId,
      );

      emit(
        CustomerAlertLoaded(
          alerts: alerts,
        ),
      );

    } catch (e) {

      emit(
        CustomerAlertFailure(
          message: e.toString(),
        ),
      );

    }
  }
}