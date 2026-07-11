import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/customer/presentation/bloc/customer_dashboard_bloc.dart';
import 'features/customer/presentation/bloc/customer_history_bloc.dart';
import 'features/customer/presentation/bloc/customer_profile_bloc.dart';
import 'features/customer/presentation/bloc/customer_service_bloc.dart';
import 'features/customer/presentation/screens/customer_main.dart';
import 'features/technician/presentation/bloc/technician_dashboard_bloc.dart';
import 'features/technician/presentation/bloc/technician_history_bloc.dart';
import 'features/technician/presentation/bloc/technician_profile_bloc.dart';
import 'features/technician/presentation/bloc/technician_service_bloc.dart';
import 'features/technician/presentation/screens/technician_main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await NotificationService.initialize();

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  String? token = await FirebaseMessaging.instance.getToken();

  print("=================================");
  print("FCM TOKEN: $token");
  print("=================================");


  // Initialize Dependency Injection
  await di.init();

  final prefs = di.sl<SharedPreferences>();

  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  String userId = prefs.getString("userId") ?? "";
  String technicianId = prefs.getString("technicianId") ?? "";
  String deviceId = prefs.getString("deviceId") ?? "";
  String name = prefs.getString("name") ?? "";
  String role = prefs.getString("role") ?? "";

  // 🔥 SAFETY CHECK
  if (role.isEmpty) {
    isLoggedIn = false;
  }

  runApp(
    MyApp(
      isLoggedIn: isLoggedIn,
      userId: userId,
      technicianId: technicianId,
      deviceId: deviceId,
      name: name,
      role: role,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String userId;
  final String technicianId;
  final String deviceId;
  final String name;
  final String role;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.userId,
    required this.technicianId,
    required this.deviceId,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<CustomerDashboardBloc>(create: (_) => di.sl<CustomerDashboardBloc>()),
        BlocProvider<CustomerServiceBloc>(create: (_) => di.sl<CustomerServiceBloc>()),
        BlocProvider<CustomerHistoryBloc>(create: (_) => di.sl<CustomerHistoryBloc>()),
        BlocProvider<CustomerProfileBloc>(create: (_) => di.sl<CustomerProfileBloc>()),
        BlocProvider<TechnicianDashboardBloc>(create: (_) => di.sl<TechnicianDashboardBloc>()),
        BlocProvider<TechnicianHistoryBloc>(create: (_) => di.sl<TechnicianHistoryBloc>()),
        BlocProvider<TechnicianProfileBloc>(create: (_) => di.sl<TechnicianProfileBloc>()),
        BlocProvider<TechnicianServiceBloc>(create: (_) => di.sl<TechnicianServiceBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // standard mobile layout size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
          home: (isLoggedIn && role.isNotEmpty)
              ? (role == "Technician"
                  ? TechnicianMain(
                      technicianId: technicianId,
                    )
                  : CustomerMain(
                      userName: name,
                      userId: userId,
                      deviceId: deviceId,
                    ))
              : const LoginScreen(),
        );
      },
    ),
   );
  }
}