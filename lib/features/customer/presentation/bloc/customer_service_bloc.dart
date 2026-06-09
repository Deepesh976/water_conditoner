import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/customer_usecases.dart';

abstract class CustomerServiceEvent {}

class SubmitComplaintRequested extends CustomerServiceEvent {
  final String userId;
  final String deviceId;
  final String description;
  final String issueType;
  final String imagePath;

  SubmitComplaintRequested({
    required this.userId,
    required this.deviceId,
    required this.description,
    required this.issueType,
    required this.imagePath,
  });
}

abstract class CustomerServiceState {}

class CustomerServiceInitial extends CustomerServiceState {}

class CustomerServiceLoading extends CustomerServiceState {}

class CustomerServiceSuccess extends CustomerServiceState {}

class CustomerServiceFailure extends CustomerServiceState {
  final String error;
  CustomerServiceFailure({required this.error});
}

class CustomerServiceBloc extends Bloc<CustomerServiceEvent, CustomerServiceState> {
  final SubmitComplaintUsecase submitComplaintUsecase;

  CustomerServiceBloc({required this.submitComplaintUsecase}) : super(CustomerServiceInitial()) {
    on<SubmitComplaintRequested>(_onSubmitComplaintRequested);
  }

  Future<void> _onSubmitComplaintRequested(
    SubmitComplaintRequested event,
    Emitter<CustomerServiceState> emit,
  ) async {
    emit(CustomerServiceLoading());
    try {
      await submitComplaintUsecase(
        userId: event.userId,
        deviceId: event.deviceId,
        description: event.description,
        issueType: event.issueType,
        imagePath: event.imagePath,
      );
      emit(CustomerServiceSuccess());
    } catch (e) {
      emit(CustomerServiceFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }
}
