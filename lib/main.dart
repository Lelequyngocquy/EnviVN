import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'src/common/constants/colors.dart';
import 'src/common/constants/strings.dart';
import 'src/core/di/injection_container.dart' as di;
import 'src/core/presentation/widgets/fade_trans_nav.dart';
import 'src/features/air_quality/presentation/cubits/air_quality_cubit.dart';
import 'src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'src/features/home/presentation/pages/home_page.dart';
import 'src/features/home/presentation/pages/location_permission_page.dart';
import 'src/features/home/presentation/pages/splash_page.dart';
import 'src/features/map_pollution/presentation/cubits/map_pollution_cubit.dart';
import 'src/features/weather/presentation/cubits/weather_cubit.dart';
import 'src/shared/router/router_key_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  UIColors.setSystemUIOverlay();

  // Initialize Vietnamese locale data for intl DateFormat
  await initializeDateFormatting('vi_VN', null);
  await initializeDateFormatting('vi', null);
  Intl.defaultLocale = 'vi_VN';

  await di.setupGetIt();

  runApp(const EnviVNApp());
}

class EnviVNApp extends StatelessWidget {
  const EnviVNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WeatherCubit>.value(value: di.sl<WeatherCubit>()),
        BlocProvider<AirQualityCubit>.value(value: di.sl<AirQualityCubit>()),
        BlocProvider<HomeDashboardCubit>.value(value: di.sl<HomeDashboardCubit>()),
        BlocProvider<MapPollutionCubit>(create: (_) => di.sl<MapPollutionCubit>()),
      ],
      child: MaterialApp(
        navigatorKey: GlobalKeyManager.instance.root,
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('vi', 'VN'),
          Locale('vi'),
          Locale('en', 'US'),
        ],
        locale: const Locale('vi', 'VN'),
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: UIColors.primary,
            secondary: UIColors.secondary,
            surface: UIColors.cardBg,
          ),
          scaffoldBackgroundColor: UIColors.bg,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: UIColors.bg,
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: RouterPath.splash,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case RouterPath.splash:
              return FadeRoute(page: const SplashPage());

            case RouterPath.permission:
              return FadeRoute(page: const LocationPermissionPage());

            case RouterPath.home:
              return FadeRoute(page: const HomePage());

            case RouterPath.pollutionMap:
              return FadeRoute(page: const HomePage(initialTab: 1));

            case RouterPath.twentyFourHours:
              return FadeRoute(page: const HomePage(initialTab: 2));

            default:
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Lỗi')),
                  body: const Center(child: Text('Trang không tồn tại')),
                ),
              );
          }
        },
      ),
    );
  }
}
