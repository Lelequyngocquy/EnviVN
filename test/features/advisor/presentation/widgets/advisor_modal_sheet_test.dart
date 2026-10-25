import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:envivn/src/core/domain/entities/app_location_entity.dart';
import 'package:envivn/src/core/infrastructure/datasources/local/local_storage.dart';
import 'package:envivn/src/core/infrastructure/services/edge_ai_inference_service.dart';
import 'package:envivn/src/core/infrastructure/services/model_download_service.dart';
import 'package:envivn/src/features/advisor/presentation/cubits/advisor_chat_cubit.dart';
import 'package:envivn/src/features/advisor/presentation/cubits/advisor_cubit.dart';
import 'package:envivn/src/features/advisor/presentation/widgets/advisor_modal_sheet.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';
import 'package:envivn/src/shared/widgets/app_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late LocalStorage localStorage;
  late ModelDownloadService downloadService;
  late EdgeAiInferenceService inferenceService;
  late SimulatedGemmaBridge bridge;
  late AdvisorChatCubit chatCubit;
  late AdvisorCubit advisorCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    localStorage = LocalStorage(prefs: prefs);

    tempDir = Directory.systemTemp.createTempSync('advisor_sheet_test_');

    downloadService = ModelDownloadService(
      localStorage: localStorage,
      customDirectoryProvider: () async => tempDir,
    );

    bridge = SimulatedGemmaBridge();

    inferenceService = EdgeAiInferenceService(
      downloadService: downloadService,
      bridge: bridge,
      customRamProvider: () async => 3 * 1024 * 1024 * 1024,
    );

    chatCubit = AdvisorChatCubit(
      downloadService: downloadService,
      inferenceService: inferenceService,
      localStorage: localStorage,
    );

    advisorCubit = AdvisorCubit();
  });

  tearDown(() async {
    await chatCubit.close();
    await advisorCubit.close();
    await inferenceService.dispose();
    downloadService.dispose();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: advisorCubit),
            BlocProvider.value(value: chatCubit),
          ],
          child: AdvisorModalSheet(
            location: AppLocationEntity.city(
              name: 'Hà Nội',
              province: 'Hà Nội',
              latitude: 21.0285,
              longitude: 105.8542,
            ),
            weather: const DetailsEntity(
              currentTemp: 28.0,
              relativeHumidity: 65,
              precipitation: 0.0,
            ),
            airQuality: const AirQualityEntity(usAqi: 75, pm25: 25.0),
          ),
        ),
      ),
    );
  }

  group('AdvisorModalSheet Dual Mode Widget Tests', () {
    testWidgets(
      'renders toggle switch and rule-based cards by default when AI is OFF',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Trợ lý AI Gemma 2B'), findsOneWidget);
        expect(find.text('Quy tắc cố định WHO/EPA (0ms)'), findsOneWidget);

        expect(find.byType(Switch), findsOneWidget);
        final switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, isFalse);

        expect(find.text('Chạy bộ ngoài trời'), findsOneWidget);
      },
    );

    testWidgets(
      'toggling switch switches to AI mode and displays download card when model not downloaded',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        expect(chatCubit.state.isAiEnabled, isTrue);
        expect(
          find.text('Suy luận on-device • Phản hồi thông minh'),
          findsOneWidget,
        );
        expect(find.text('Gói trí tuệ nhân tạo Gemma 2B'), findsOneWidget);
        expect(find.text('Tải gói AI On-Device (~1.3 GB)'), findsOneWidget);
        expect(find.byType(AppButton), findsOneWidget);
      },
    );

    testWidgets(
      'displays AppTwoButtons when download is paused with existing partial file',
      (tester) async {
        final tempFile = await downloadService.getTempDownloadFile();
        tempFile.writeAsBytesSync(List.filled(4096, 2));
        await downloadService.init();

        chatCubit.toggleAi(true);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(AppTwoButtons), findsOneWidget);
        expect(find.text('Tiếp tục'), findsOneWidget);
        expect(find.text('Hủy bỏ'), findsOneWidget);
      },
    );

    testWidgets(
      'displays conversation chat view when model is downloaded and ready in AI mode',
      (tester) async {
        final modelFile = await downloadService.getModelFile();
        modelFile.writeAsBytesSync(List.filled(1024, 1));
        await downloadService.init();

        await chatCubit.initChat(
          location: AppLocationEntity.city(
            name: 'Hà Nội',
            province: 'Hà Nội',
            latitude: 21.0,
            longitude: 105.0,
          ),
          weather: const DetailsEntity(),
          airQuality: const AirQualityEntity(),
        );

        chatCubit.toggleAi(true);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Cố vấn AI Gemma'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(
          find.text('Hỏi về không khí, chạy bộ, ngập úng...'),
          findsOneWidget,
        );
      },
    );
  });
}
