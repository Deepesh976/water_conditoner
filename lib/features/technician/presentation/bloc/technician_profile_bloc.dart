import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/technician_usecases.dart';

abstract class TechnicianProfileEvent {}

class LoadTechnicianProfileRequested extends TechnicianProfileEvent {
  final String technicianId;
  LoadTechnicianProfileRequested({required this.technicianId});
}

class UpdateTechnicianProfileRequested extends TechnicianProfileEvent {
  final String technicianId;
  final Map<String, dynamic> profileData;
  UpdateTechnicianProfileRequested({required this.technicianId, required this.profileData});
}

class ToggleAvailabilityRequested extends TechnicianProfileEvent {
  final String technicianId;
  final bool availability;
  ToggleAvailabilityRequested({required this.technicianId, required this.availability});
}

abstract class TechnicianProfileState {}

class TechnicianProfileInitial extends TechnicianProfileState {}

class TechnicianProfileLoading extends TechnicianProfileState {}

class TechnicianProfileLoaded extends TechnicianProfileState {
  final Map<String, dynamic> profileData;
  final bool isAvailable;

  TechnicianProfileLoaded({required this.profileData, required this.isAvailable});
}

class TechnicianProfileUpdateSuccess extends TechnicianProfileState {}

class TechnicianProfileFailure extends TechnicianProfileState {
  final String error;
  TechnicianProfileFailure({required this.error});
}

class TechnicianProfileBloc extends Bloc<TechnicianProfileEvent, TechnicianProfileState> {
  final FetchTechnicianProfileUsecase fetchProfileUsecase;
  final UpdateTechnicianProfileUsecase updateProfileUsecase;
  final UpdateAvailabilityUsecase updateAvailabilityUsecase;

  TechnicianProfileBloc({
    required this.fetchProfileUsecase,
    required this.updateProfileUsecase,
    required this.updateAvailabilityUsecase,
  }) : super(TechnicianProfileInitial()) {
    on<LoadTechnicianProfileRequested>(_onLoadProfileRequested);
    on<UpdateTechnicianProfileRequested>(_onUpdateProfileRequested);
    on<ToggleAvailabilityRequested>(_onToggleAvailabilityRequested);
  }

  Future<void> _onLoadProfileRequested(
    LoadTechnicianProfileRequested event,
    Emitter<TechnicianProfileState> emit,
  ) async {
    emit(TechnicianProfileLoading());
    try {
      final profile = await fetchProfileUsecase(event.technicianId);
      final isAvailable = profile["availability"] == "Available";
      emit(TechnicianProfileLoaded(profileData: profile, isAvailable: isAvailable));
    } catch (e) {
      emit(TechnicianProfileFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateTechnicianProfileRequested event,
    Emitter<TechnicianProfileState> emit,
  ) async {
    emit(TechnicianProfileLoading());
    try {
      await updateProfileUsecase(
        technicianId: event.technicianId,
        profileData: event.profileData,
      );
      emit(TechnicianProfileUpdateSuccess());
    } catch (e) {
      emit(TechnicianProfileFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onToggleAvailabilityRequested(
    ToggleAvailabilityRequested event,
    Emitter<TechnicianProfileState> emit,
  ) async {
    try {
      final status = event.availability ? "Available" : "Offline";
      await updateAvailabilityUsecase(technicianId: event.technicianId, availability: status);
      
      if (state is TechnicianProfileLoaded) {
        final currentData = (state as TechnicianProfileLoaded).profileData;
        emit(TechnicianProfileLoaded(profileData: currentData, isAvailable: event.availability));
      }
    } catch (e) {
      emit(TechnicianProfileFailure(error: e.toString().replaceAll("Exception: ", "")));
    }
  }
}
