import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/customer_usecases.dart';

abstract class CustomerDashboardEvent {}

class LoadDashboard extends CustomerDashboardEvent {
  final String userId;
  LoadDashboard({required this.userId});
}

class RefreshDashboard extends CustomerDashboardEvent {
  final String deviceId;
  final String userId;
  RefreshDashboard({required this.deviceId, required this.userId});
}

abstract class CustomerDashboardState {}

class CustomerDashboardInitial extends CustomerDashboardState {}

class CustomerDashboardLoading extends CustomerDashboardState {}

class CustomerDashboardLoaded extends CustomerDashboardState {
  final String deviceId;
  final String deviceName;
  final Map<String, dynamic> analysisData;
  final List<dynamic> complaints;

  CustomerDashboardLoaded({
    required this.deviceId,
    required this.deviceName,
    required this.analysisData,
    required this.complaints,
  });
}

class CustomerDashboardFailure extends CustomerDashboardState {
  final String message;
  CustomerDashboardFailure({required this.message});
}

class CustomerDashboardBloc
    extends Bloc<CustomerDashboardEvent, CustomerDashboardState> {
  final FetchDeviceUsecase fetchDeviceUsecase;
  final FetchDashboardDataUsecase fetchDashboardDataUsecase;
  final FetchComplaintHistoryUsecase fetchComplaintHistoryUsecase;

  CustomerDashboardBloc({
    required this.fetchDeviceUsecase,
    required this.fetchDashboardDataUsecase,
    required this.fetchComplaintHistoryUsecase,
  }) : super(CustomerDashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  // ================= LOAD DASHBOARD =================
  Future<void> _onLoadDashboard(
      LoadDashboard event, Emitter<CustomerDashboardState> emit) async {
    emit(CustomerDashboardLoading());

    try {
      print("🔥 LOAD DASHBOARD for userId: ${event.userId}");

      final deviceData = await fetchDeviceUsecase(event.userId);

      print("🔥 DEVICE DATA FROM API: $deviceData");

      final deviceId = deviceData["_id"] ?? "";
      final deviceName = deviceData["deviceId"] ?? "RO Device";

      print("🔥 DEVICE ID FROM BACKEND: $deviceId");

      if (deviceId.isEmpty) {
        print("❌ No device assigned");
        emit(CustomerDashboardFailure(message: "No device assigned."));
        return;
      }

      final analysisData =
      await fetchDashboardDataUsecase(deviceId);

      print("🔥 INITIAL API RESPONSE: $analysisData");

      final complaints =
      await fetchComplaintHistoryUsecase(event.userId);

      emit(CustomerDashboardLoaded(
        deviceId: deviceId,
        deviceName: deviceName,
        analysisData: analysisData,
        complaints: complaints,
      ));
    } catch (e) {
      print("❌ LOAD ERROR: $e");
      emit(CustomerDashboardFailure(
          message: e.toString().replaceAll("Exception: ", "")));
    }
  }

  // ================= REFRESH DASHBOARD =================
  Future<void> _onRefreshDashboard(
      RefreshDashboard event, Emitter<CustomerDashboardState> emit) async {
    try {
      print("🔥 REFRESH CALLED with deviceId: ${event.deviceId}");

      final analysisData =
      await fetchDashboardDataUsecase(event.deviceId);

      print("🔥 REFRESH API RESPONSE: $analysisData");

      final complaints =
      await fetchComplaintHistoryUsecase(event.userId);

      String prevDeviceName = "RO Device";

      if (state is CustomerDashboardLoaded) {
        prevDeviceName =
            (state as CustomerDashboardLoaded).deviceName;
      }

      emit(CustomerDashboardLoaded(
        deviceId: event.deviceId,
        deviceName: prevDeviceName,
        analysisData: analysisData,
        complaints: complaints,
      ));
    } catch (e) {
      print("❌ REFRESH ERROR: $e");
      emit(CustomerDashboardFailure(
          message: e.toString().replaceAll("Exception: ", "")));
    }
  }
}