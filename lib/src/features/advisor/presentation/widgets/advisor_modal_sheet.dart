import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/utils/weather_code_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/domain/entities/app_location_entity.dart';
import '../../../../core/infrastructure/datasources/local/local_storage.dart';
import '../../../../core/infrastructure/services/edge_ai_inference_service.dart';
import '../../../../core/infrastructure/services/model_download_service.dart';
import '../../../../core/presentation/widgets/app_bottom_sheet.dart';
import '../../../../core/presentation/widgets/app_icon.dart';
import '../../../../core/presentation/widgets/app_text.dart';
import '../../../air_quality/domain/entities/air_quality_entity.dart';
import '../../../details/domain/entities/details_entity.dart';
import '../../domain/entities/quick_prompt_type.dart';
import '../cubits/advisor_chat_cubit.dart';
import '../cubits/advisor_chat_state.dart';
import '../cubits/advisor_cubit.dart';
import '../cubits/advisor_state.dart';
import 'advisor_result_card.dart';
import 'ai_chat_conversation_view.dart';
import 'outdoor_activity_advice_card.dart';

class AdvisorModalSheet extends StatelessWidget {
  final AirQualityEntity airQuality;
  final DetailsEntity weather;
  final String? cityName;
  final AppLocationEntity? location;
  final bool hasRespiratoryCondition;

  const AdvisorModalSheet({
    super.key,
    this.airQuality = const AirQualityEntity(),
    this.weather = const DetailsEntity(),
    this.cityName,
    this.location,
    this.hasRespiratoryCondition = false,
  });

  static Future<void> show(
    BuildContext context, {
    required AirQualityEntity airQuality,
    required DetailsEntity weather,
    String? cityName,
    AppLocationEntity? location,
    bool hasRespiratoryCondition = false,
  }) {
    final resolvedLocation =
        location ??
        AppLocationEntity.city(
          name: cityName ?? 'Vị trí hiện tại',
          province: cityName ?? 'Việt Nam',
          latitude: weather.hourlyForecast.isNotEmpty ? 10.7769 : 0.0,
          longitude: weather.hourlyForecast.isNotEmpty ? 106.7009 : 0.0,
        );

    return AppBottomSheet.show(
      context,
      title: 'Cố vấn Môi trường',
      subtitle: cityName != null && cityName.isNotEmpty
          ? 'Điều kiện thực tế tại $cityName chuẩn WHO & EPA'
          : 'Phân tích điều kiện tức thì theo chuẩn WHO & EPA',
      icon: Icons.wechat_sharp,
      maxHeightFactor: 0.92,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AdvisorCubit()),
          BlocProvider(
            create: (_) {
              final cubit = AdvisorChatCubit(
                downloadService: sl<ModelDownloadService>(),
                inferenceService: sl<EdgeAiInferenceService>(),
                localStorage: sl<LocalStorage>(),
              );
              cubit.initChat(
                location: resolvedLocation,
                weather: weather,
                airQuality: airQuality,
              );
              return cubit;
            },
          ),
        ],
        child: AdvisorModalSheet(
          airQuality: airQuality,
          weather: weather,
          location: resolvedLocation,
          cityName: cityName,
          hasRespiratoryCondition: hasRespiratoryCondition,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedLocation =
        location ??
        AppLocationEntity.city(
          name: cityName ?? 'Vị trí hiện tại',
          province: cityName ?? 'Việt Nam',
          latitude: weather.hourlyForecast.isNotEmpty ? 10.7769 : 0.0,
          longitude: weather.hourlyForecast.isNotEmpty ? 106.7009 : 0.0,
        );

    final aqi = airQuality.usAqi > 0 ? airQuality.usAqi : 50;
    final pm25 = airQuality.pm25;
    final temperature = weather.currentTemp;
    final uvIndex = weather.uvIndex;
    final weatherCode = weather.weatherCode;
    final precipitation = weather.precipitation;
    final weatherInfo = WeatherCodeHelper.getInfo(weatherCode);
    final isRaining = precipitation > 0.1 || weatherInfo.isRain;
    final rainProbability = weather.hourlyForecast.isNotEmpty
        ? weather.hourlyForecast.first.precipitationProbability
        : 0;

    return BlocBuilder<AdvisorChatCubit, AdvisorChatState>(
      builder: (context, chatState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ModeToggleBar(
              isAiEnabled: chatState.isAiEnabled,
              onToggle: (enabled) =>
                  context.read<AdvisorChatCubit>().toggleAi(enabled),
            ),
            const Gap(12),
            if (chatState.isAiEnabled) ...[
              Flexible(
                child: AiChatConversationView(
                  location: resolvedLocation,
                  weather: weather,
                  airQuality: airQuality,
                ),
              ),
            ] else ...[
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutdoorActivityAdviceCard(
                        airQuality: airQuality,
                        weather: weather,
                        isCompact: true,
                      ),
                      BlocBuilder<AdvisorCubit, AdvisorState>(
                        builder: (context, state) {
                          if (state.status == AdvisorStatus.loading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: UIColors.primary,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            );
                          }

                          if (state.status == AdvisorStatus.success &&
                              state.decision != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: AdvisorResultCard(
                                decision: state.decision!,
                                prompt: state.selectedPrompt,
                                aqi: aqi,
                                pm25: pm25,
                                temperature: temperature,
                                uvIndex: uvIndex,
                                hasRespiratoryCondition:
                                    hasRespiratoryCondition,
                                isRaining: isRaining,
                                rainProbability: rainProbability,
                                precipitation: precipitation,
                                weatherCode: weatherCode,
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                            child: Row(
                              children: const [
                                AppIcon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 14,
                                  color: UIColors.primary,
                                ),
                                Gap(6),
                                Expanded(
                                  child: AppText.regular(
                                    'Chạm vào câu hỏi gợi ý bên dưới để nhận phân tích chuyên sâu tức thì',
                                    size: 11.5,
                                    color: UIColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              BlocBuilder<AdvisorCubit, AdvisorState>(
                buildWhen: (prev, curr) =>
                    prev.selectedPrompt != curr.selectedPrompt ||
                    prev.availablePrompts != curr.availablePrompts,
                builder: (context, state) {
                  return SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.availablePrompts.length,
                      separatorBuilder: (_, index) => const Gap(8),
                      itemBuilder: (context, index) {
                        final prompt = state.availablePrompts[index];
                        final isSelected = state.selectedPrompt == prompt;

                        return _PromptChip(
                          prompt: prompt,
                          isSelected: isSelected,
                          onTap: () {
                            if (isSelected) {
                              context.read<AdvisorCubit>().reset();
                            } else {
                              context.read<AdvisorCubit>().selectPrompt(
                                prompt,
                                aqi: aqi,
                                pm25: pm25,
                                temperature: temperature,
                                uvIndex: uvIndex,
                                hasRespiratoryCondition:
                                    hasRespiratoryCondition,
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ModeToggleBar extends StatelessWidget {
  final bool isAiEnabled;
  final ValueChanged<bool> onToggle;

  const _ModeToggleBar({required this.isAiEnabled, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: UIColors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAiEnabled
              ? UIColors.primary.withOpacity(0.4)
              : UIColors.white.withOpacity(0.12),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: (isAiEnabled ? UIColors.primary : UIColors.textSecondary)
                  .withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: isAiEnabled ? UIColors.primary : UIColors.textSecondary,
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.bold(
                  'Trợ lý AI Gemma 2B',
                  size: 13,
                  color: isAiEnabled
                      ? UIColors.textPrimary
                      : UIColors.textSecondary,
                ),
                const Gap(1),
                AppText.regular(
                  isAiEnabled
                      ? 'Suy luận on-device • Phản hồi thông minh'
                      : 'Quy tắc cố định WHO/EPA (0ms)',
                  size: 10.5,
                  color: UIColors.textSecondary,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isAiEnabled,
            onChanged: onToggle,
            activeColor: UIColors.primary,
            activeTrackColor: UIColors.primary.withOpacity(0.35),
          ),
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  final QuickPromptType prompt;
  final bool isSelected;
  final VoidCallback onTap;

  const _PromptChip({
    required this.prompt,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? UIColors.primary
              : UIColors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? UIColors.primary
                : UIColors.white.withOpacity(0.18),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: UIColors.primary.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              prompt.icon,
              size: 16,
              color: isSelected ? UIColors.bg : UIColors.textPrimary,
            ),
            const Gap(8),
            AppText.bold(
              prompt.label,
              size: 12.5,
              color: isSelected ? UIColors.bg : UIColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
