import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/customer_usecases.dart';

abstract class CustomerProfileEvent {}

class LoadProfileRequested extends CustomerProfileEvent {
  final String userId;
  LoadProfileRequested({required this.userId});
}

class UpdateProfileRequested extends CustomerProfileEvent {
  final String userId;
  final Map<String, dynamic> profileData;
  UpdateProfileRequested({required this.userId, required this.profileData});
}

abstract class CustomerProfileState {}

class CustomerProfileInitial extends CustomerProfileState {}

class CustomerProfileLoading extends CustomerProfileState {}

class CustomerProfileLoaded extends CustomerProfileState {
  final Map<String, dynamic> profileData;
  CustomerProfileLoaded({required this.profileData});
}

class CustomerProfileUpdateSuccess extends CustomerProfileState {
  final Map<String, dynamic> updatedProfile;
  CustomerProfileUpdateSuccess({required this.updatedProfile});
}

class CustomerProfileFailure extends CustomerProfileState {
  final String error;
  CustomerProfileFailure({required this.error});
}

class CustomerProfileBloc extends Bloc<CustomerProfileEvent, CustomerProfileState> {
  final FetchCustomerProfileUsecase fetchProfileUsecase;
  final UpdateCustomerProfileUsecase updateProfileUsecase;

  CustomerProfileBloc({
    required this.fetchProfileUsecase,
    required this.updateProfileUsecase,
  }) : super(CustomerProfileInitial()) {
    on<LoadProfileRequested>(_onLoadProfileRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onLoadProfileRequested(
    LoadProfileRequested event,
    Emitter<CustomerProfileState> emit,
  ) async {
    emit(CustomerProfileLoading());
    try {
      final profile = await fetchProfileUsecase(event.userId);
      emit(CustomerProfileLoaded(profileData: profile));
    } catch (e) {
      emit(CustomerProfileFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<CustomerProfileState> emit,
  ) async {
    emit(CustomerProfileLoading());
    try {
      final response = await updateProfileUsecase(
        userId: event.userId,
        profileData: event.profileData,
      );
      emit(CustomerProfileUpdateSuccess(updatedProfile: response));
    } catch (e) {
      emit(CustomerProfileFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }
}
