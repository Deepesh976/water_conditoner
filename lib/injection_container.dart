import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/network/api_client.dart';

// Auth Feature
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/change_password_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Customer Feature
import 'features/customer/data/datasources/customer_remote_data_source.dart';
import 'features/customer/data/repositories/customer_repository_impl.dart';
import 'features/customer/domain/repositories/customer_repository.dart';
import 'features/customer/domain/usecases/customer_usecases.dart';
import 'features/customer/presentation/bloc/customer_dashboard_bloc.dart';
import 'features/customer/presentation/bloc/customer_history_bloc.dart';
import 'features/customer/presentation/bloc/customer_profile_bloc.dart';
import 'features/customer/presentation/bloc/customer_service_bloc.dart';

// Technician Feature
import 'features/technician/data/datasources/technician_remote_data_source.dart';
import 'features/technician/data/repositories/technician_repository_impl.dart';
import 'features/technician/domain/repositories/technician_repository.dart';
import 'features/technician/domain/usecases/technician_usecases.dart';
import 'features/technician/presentation/bloc/technician_dashboard_bloc.dart';
import 'features/technician/presentation/bloc/technician_history_bloc.dart';
import 'features/technician/presentation/bloc/technician_profile_bloc.dart';
import 'features/technician/presentation/bloc/technician_service_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Core Network
  sl.registerLazySingleton<ApiClient>(() => ApiClient(client: sl()));

  // Auth Feature
  // Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sharedPreferences: sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(apiClient: sl()));
  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()));
  // Usecases
  sl.registerLazySingleton(() => LoginUsecase(repository: sl()));
  sl.registerLazySingleton(() => ChangePasswordUsecase(repository: sl()));
  // Bloc
  sl.registerFactory(() => AuthBloc(loginUsecase: sl(), changePasswordUsecase: sl(), authRepository: sl()));

  // Customer Feature
  // Data Sources
  sl.registerLazySingleton<CustomerRemoteDataSource>(() => CustomerRemoteDataSourceImpl(apiClient: sl()));
  // Repository
  sl.registerLazySingleton<CustomerRepository>(() => CustomerRepositoryImpl(remoteDataSource: sl()));
  // Usecases
  sl.registerLazySingleton(() => FetchDeviceUsecase(repository: sl()));
  sl.registerLazySingleton(() => FetchDashboardDataUsecase(repository: sl()));
  sl.registerLazySingleton(() => SubmitComplaintUsecase(repository: sl()));
  sl.registerLazySingleton(() => FetchComplaintHistoryUsecase(repository: sl()));
  sl.registerLazySingleton(() => FetchCustomerProfileUsecase(repository: sl()));
  sl.registerLazySingleton(() => UpdateCustomerProfileUsecase(repository: sl()));
  // Blocs
  sl.registerFactory(() => CustomerDashboardBloc(
        fetchDeviceUsecase: sl(),
        fetchDashboardDataUsecase: sl(),
        fetchComplaintHistoryUsecase: sl(),
      ));
  sl.registerFactory(() => CustomerServiceBloc(submitComplaintUsecase: sl()));
  sl.registerFactory(() => CustomerHistoryBloc(fetchHistoryUsecase: sl()));
  sl.registerFactory(() => CustomerProfileBloc(fetchProfileUsecase: sl(), updateProfileUsecase: sl()));

  // Technician Feature
  // Data Sources
  sl.registerLazySingleton<TechnicianRemoteDataSource>(() => TechnicianRemoteDataSourceImpl(apiClient: sl()));
  // Repository
  sl.registerLazySingleton<TechnicianRepository>(() => TechnicianRepositoryImpl(remoteDataSource: sl()));
  // Usecases
  sl.registerLazySingleton(() => FetchJobsUsecase(repository: sl()));
  sl.registerLazySingleton(() => RespondToJobUsecase(repository: sl()));
  sl.registerLazySingleton(() => SubmitReadingsUsecase(repository: sl()));
  sl.registerLazySingleton(() => CompleteJobUsecase(repository: sl()));
  sl.registerLazySingleton(() => PostAnalysisUsecase(repository: sl()));
  sl.registerLazySingleton(() => FetchTechnicianProfileUsecase(repository: sl()));
  sl.registerLazySingleton(() => UpdateTechnicianProfileUsecase(repository: sl()));
  sl.registerLazySingleton(() => UpdateAvailabilityUsecase(repository: sl()));
  // Blocs
  sl.registerFactory(() => TechnicianDashboardBloc(fetchJobsUsecase: sl(), respondToJobUsecase: sl()));
  sl.registerFactory(() => TechnicianHistoryBloc(fetchJobsUsecase: sl()));
  sl.registerFactory(() => TechnicianProfileBloc(
        fetchProfileUsecase: sl(),
        updateProfileUsecase: sl(),
        updateAvailabilityUsecase: sl(),
      ));
  sl.registerFactory(() => TechnicianServiceBloc(
        submitReadingsUsecase: sl(),
        completeJobUsecase: sl(),
        postAnalysisUsecase: sl(),
      ));
}
