import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/advisor/presentation/cubits/advisor_cubit.dart';
import '../../features/air_quality/domain/interfaces/i_air_quality_repository.dart';
import '../../features/air_quality/infrastructure/repositories/air_quality_repository.dart';
import '../../features/air_quality/presentation/cubits/air_quality_cubit.dart';
import '../../features/home/presentation/cubits/home_dashboard_cubit.dart';
import '../../features/map_pollution/domain/interfaces/i_map_pollution_repository.dart';
import '../../features/map_pollution/infrastructure/repositories/map_pollution_repository.dart';
import '../../features/map_pollution/presentation/cubits/map_pollution_cubit.dart';
import '../../features/weather/domain/interfaces/i_weather_repository.dart';
import '../../features/weather/infrastructure/repositories/weather_repository.dart';
import '../../features/weather/presentation/cubits/weather_cubit.dart';
import '../infrastructure/datasources/local/local_storage.dart';
import '../infrastructure/datasources/network/api/restful_request.dart';
import '../infrastructure/services/location_service.dart';

final sl = GetIt.instance;

Future<void> setupGetIt() async {
  // Reset GetIt on hot restart or re-initialization to avoid duplicate registration errors
  await sl.reset();

  //! 1. External & Local Storage
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<LocalStorage>(
    () => LocalStorage(prefs: sl<SharedPreferences>()),
  );

  final httpClient = http.Client();
  sl.registerLazySingleton<http.Client>(() => httpClient);

  //! 2. Core Network & Services
  sl.registerLazySingleton<RestfulRequest>(
    () => RestfulRequest(client: sl<http.Client>()),
  );

  sl.registerLazySingleton<LocationService>(() => LocationService());

  //! 3. Feature: Weather
  sl.registerLazySingleton<IWeatherRepository>(
    () => WeatherRepository(
      network: sl<RestfulRequest>(),
      storage: sl<LocalStorage>(),
    ),
  );

  sl.registerLazySingleton<WeatherCubit>(
    () => WeatherCubit(repository: sl<IWeatherRepository>()),
  );

  //! 4. Feature: Air Quality
  sl.registerLazySingleton<IAirQualityRepository>(
    () => AirQualityRepository(
      network: sl<RestfulRequest>(),
      storage: sl<LocalStorage>(),
    ),
  );

  sl.registerLazySingleton<AirQualityCubit>(
    () => AirQualityCubit(repository: sl<IAirQualityRepository>()),
  );

  //! 5. Feature: Map Pollution
  sl.registerLazySingleton<IMapPollutionRepository>(
    () => MapPollutionRepository(network: sl<RestfulRequest>()),
  );

  sl.registerFactory<MapPollutionCubit>(
    () => MapPollutionCubit(
      repository: sl<IMapPollutionRepository>(),
      weatherRepository: sl<IWeatherRepository>(),
      locationService: sl<LocationService>(),
    ),
  );

  //! 6. Feature: Home Dashboard
  sl.registerLazySingleton<HomeDashboardCubit>(
    () => HomeDashboardCubit(
      storage: sl<LocalStorage>(),
      locationService: sl<LocationService>(),
      weatherCubit: sl<WeatherCubit>(),
      airQualityCubit: sl<AirQualityCubit>(),
    ),
  );

  //! 7. Feature: Smart Advisor
  sl.registerFactory<AdvisorCubit>(() => AdvisorCubit());
}
