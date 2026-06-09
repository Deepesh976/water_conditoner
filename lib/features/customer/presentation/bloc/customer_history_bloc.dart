import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/customer_usecases.dart';

abstract class CustomerHistoryEvent {}

class FetchHistoryRequested extends CustomerHistoryEvent {
  final String userId;
  FetchHistoryRequested({required this.userId});
}

abstract class CustomerHistoryState {}

class CustomerHistoryInitial extends CustomerHistoryState {}

class CustomerHistoryLoading extends CustomerHistoryState {}

class CustomerHistoryLoaded extends CustomerHistoryState {
  final List<dynamic> complaints;
  CustomerHistoryLoaded({required this.complaints});
}

class CustomerHistoryFailure extends CustomerHistoryState {
  final String error;
  CustomerHistoryFailure({required this.error});
}

class CustomerHistoryBloc extends Bloc<CustomerHistoryEvent, CustomerHistoryState> {
  final FetchComplaintHistoryUsecase fetchHistoryUsecase;

  CustomerHistoryBloc({required this.fetchHistoryUsecase}) : super(CustomerHistoryInitial()) {
    on<FetchHistoryRequested>(_onFetchHistoryRequested);
  }

  Future<void> _onFetchHistoryRequested(
    FetchHistoryRequested event,
    Emitter<CustomerHistoryState> emit,
  ) async {
    emit(CustomerHistoryLoading());
    try {
      final complaints = await fetchHistoryUsecase(event.userId);
      emit(CustomerHistoryLoaded(complaints: complaints));
    } catch (e) {
      emit(CustomerHistoryFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }
}
