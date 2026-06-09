import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:water_conditioner/features/customer/domain/repositories/customer_repository.dart';
import 'package:water_conditioner/features/customer/domain/usecases/customer_usecases.dart';
import 'package:water_conditioner/features/customer/presentation/bloc/customer_dashboard_bloc.dart';
import 'package:water_conditioner/features/customer/presentation/screens/customer_dashboard_page.dart';

class FakeCustomerRepository implements CustomerRepository {
  @override
  Future<Map<String, dynamic>> fetchDevice(String userId) async {
    return {
      "_id": "device_123",
      "deviceId": "RO Device Test",
    };
  }

  @override
  Future<Map<String, dynamic>> fetchDashboardData(String deviceId) async {
    final now = DateTime.now();
    return {
      "showResetPopup": false,
      "latest": {
        "channel1": 45.0,
        "channel2": 80.0,
        "flowRate": 15.0,
      },
      "flowHistory": [
        {
          "recordedAt": now.subtract(const Duration(days: 1)).toIso8601String(),
          "flowRate": 15.0,
          "ampere": 1.2,
          "voltage": 220.0,
        },
        {
          "recordedAt": now.toIso8601String(),
          "flowRate": 20.0,
          "ampere": 1.5,
          "voltage": 230.0,
        }
      ],
      "pressureHistory": [
        {
          "recordedAt": now.toIso8601String(),
          "pressure": 0.0,
        }
      ],
    };
  }

  @override
  Future<List> fetchComplaintHistory(String userId) async => [];

  @override
  Future<Map<String, dynamic>> fetchCustomerProfile(String userId) async => {};

  @override
  Future<void> submitComplaint({
    required String userId,
    required String deviceId,
    required String description,
    required String issueType,
    required String imagePath,
  }) async {}

  @override
  Future<Map<String, dynamic>> updateCustomerProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async => {};
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CustomerDashboardPage renders charts and disposes correctly without errors', (WidgetTester tester) async {
    // Set a large viewport to prevent overflow issues in testing
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = FakeCustomerRepository();
    final fetchDevice = FetchDeviceUsecase(repository: repository);
    final fetchDashboard = FetchDashboardDataUsecase(repository: repository);
    final fetchHistory = FetchComplaintHistoryUsecase(repository: repository);
    final bloc = CustomerDashboardBloc(
      fetchDeviceUsecase: fetchDevice,
      fetchDashboardDataUsecase: fetchDashboard,
      fetchComplaintHistoryUsecase: fetchHistory,
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            home: BlocProvider<CustomerDashboardBloc>.value(
              value: bloc,
              child: const Scaffold(
                body: CustomerDashboardPage(
                  deviceId: "device_123",
                  userId: "user_123",
                ),
              ),
            ),
          );
        },
      ),
    );

    // Initial state setup and call load
    bloc.add(LoadDashboard(userId: "user_123"));
    await tester.pump(); // Trigger Bloc state change
    await tester.pumpAndSettle(); // Complete animations

    // Verify widgets are rendered
    expect(find.byType(SfCartesianChart), findsNWidgets(2));
    expect(find.byType(gauges.SfRadialGauge), findsNWidgets(2));

    // Now dispose by navigating or pumping an empty container
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pumpAndSettle();

    // Verify no exception was thrown during disposal
  });

  testWidgets('CustomerDashboardPage shows completed complaint popup and dismisses it', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = FakeCustomerRepositoryWithCompletedComplaint();
    final fetchDevice = FetchDeviceUsecase(repository: repository);
    final fetchDashboard = FetchDashboardDataUsecase(repository: repository);
    final fetchHistory = FetchComplaintHistoryUsecase(repository: repository);
    final bloc = CustomerDashboardBloc(
      fetchDeviceUsecase: fetchDevice,
      fetchDashboardDataUsecase: fetchDashboard,
      fetchComplaintHistoryUsecase: fetchHistory,
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            home: BlocProvider<CustomerDashboardBloc>.value(
              value: bloc,
              child: const Scaffold(
                body: CustomerDashboardPage(
                  deviceId: "device_123",
                  userId: "user_123",
                ),
              ),
            ),
          );
        },
      ),
    );

    bloc.add(LoadDashboard(userId: "user_123"));
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify popup is shown
    expect(find.text("Issue Resolved!"), findsOneWidget);
    expect(find.text("• Type: Low Pressure"), findsOneWidget);
    expect(find.text("Flow: 10 L/hr"), findsOneWidget); // Before flow
    expect(find.text("Flow: 50 L/hr"), findsOneWidget); // After flow

    // Click Dismiss button
    await tester.tap(find.text("Great, Thanks!"));
    await tester.pumpAndSettle();

    // Verify popup is dismissed
    expect(find.text("Issue Resolved!"), findsNothing);
  });

  testWidgets('CustomerDashboardPage shows only the latest completed complaint popup when there are multiple', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = FakeCustomerRepositoryWithMultipleCompletedComplaints();
    final fetchDevice = FetchDeviceUsecase(repository: repository);
    final fetchDashboard = FetchDashboardDataUsecase(repository: repository);
    final fetchHistory = FetchComplaintHistoryUsecase(repository: repository);
    final bloc = CustomerDashboardBloc(
      fetchDeviceUsecase: fetchDevice,
      fetchDashboardDataUsecase: fetchDashboard,
      fetchComplaintHistoryUsecase: fetchHistory,
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            home: BlocProvider<CustomerDashboardBloc>.value(
              value: bloc,
              child: const Scaffold(
                body: CustomerDashboardPage(
                  deviceId: "device_123",
                  userId: "user_123",
                ),
              ),
            ),
          );
        },
      ),
    );

    bloc.add(LoadDashboard(userId: "user_123"));
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify popup is shown for latest complaint ("Leakage") and NOT the older one ("Low Pressure")
    expect(find.text("Issue Resolved!"), findsOneWidget);
    expect(find.text("• Type: Leakage"), findsOneWidget);
    expect(find.text("• Type: Low Pressure"), findsNothing);
    expect(find.text("Flow: 60 L/hr"), findsOneWidget); // Latest flow after

    // Click Dismiss button
    await tester.tap(find.text("Great, Thanks!"));
    await tester.pumpAndSettle();

    // Verify popup is dismissed
    expect(find.text("Issue Resolved!"), findsNothing);
  });
}

class FakeCustomerRepositoryWithCompletedComplaint extends FakeCustomerRepository {
  @override
  Future<List> fetchComplaintHistory(String userId) async {
    return [
      {
        "_id": "complaint_999",
        "status": "Completed",
        "type": "Low Pressure",
        "description": "The flow was very low",
        "beforeReading": {
          "flow": "10",
          "ampere": "1.1",
          "voltage": "220",
        },
        "afterReading": {
          "flow": "50",
          "ampere": "1.5",
          "voltage": "230",
        }
      }
    ];
  }
}

class FakeCustomerRepositoryWithMultipleCompletedComplaints extends FakeCustomerRepository {
  @override
  Future<List> fetchComplaintHistory(String userId) async {
    return [
      {
        "_id": "complaint_latest",
        "status": "Completed",
        "type": "Leakage",
        "description": "Leakage from bottom joint",
        "beforeReading": {
          "flow": "0",
          "ampere": "0.0",
          "voltage": "0",
        },
        "afterReading": {
          "flow": "60",
          "ampere": "1.4",
          "voltage": "225",
        }
      },
      {
        "_id": "complaint_older",
        "status": "Completed",
        "type": "Low Pressure",
        "description": "The flow was very low",
        "beforeReading": {
          "flow": "10",
          "ampere": "1.1",
          "voltage": "220",
        },
        "afterReading": {
          "flow": "50",
          "ampere": "1.5",
          "voltage": "230",
        }
      }
    ];
  }
}
