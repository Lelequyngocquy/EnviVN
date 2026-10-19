import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/presentation/widgets/app_bottom_sheet.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/features/advisor/domain/entities/quick_prompt_type.dart';
import 'package:envivn/src/features/advisor/presentation/cubits/advisor_cubit.dart';
import 'package:envivn/src/features/advisor/presentation/cubits/advisor_state.dart';
import 'package:envivn/src/features/advisor/presentation/widgets/advisor_result_card.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/advisor/presentation/widgets/outdoor_activity_advice_card.dart';
import 'package:envivn/src/features/weather/domain/entities/weather_entity.dart';

class AdvisorModalSheet extends StatelessWidget {
  final AirQualityEntity airQuality;
  final WeatherEntity weather;
  final String? cityName;
  final bool hasRespiratoryCondition;

  const AdvisorModalSheet({
    super.key,
    this.airQuality = const AirQualityEntity(),
    this.weather = const WeatherEntity(),
    this.cityName,
    this.hasRespiratoryCondition = false,
  });

  static Future<void> show(
    BuildContext context, {
    required AirQualityEntity airQuality,
    required WeatherEntity weather,
    String? cityName,
    bool hasRespiratoryCondition = false,
  }) {
    return AppBottomSheet.show(
      context,
      title: 'Cố vấn Môi trường',
      subtitle: cityName != null && cityName.isNotEmpty
          ? 'Điều kiện thực tế tại $cityName chuẩn WHO & EPA (Thời điểm hiện tại)'
          : 'Phân tích điều kiện tức thì theo chuẩn WHO & EPA',
      leading: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [UIColors.primary, UIColors.secondary],
          ),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: AppIcon(Icons.lightbulb, color: Colors.white, size: 22),
        ),
      ),
      child: BlocProvider(
        create: (_) => AdvisorCubit(),
        child: AdvisorModalSheet(
          airQuality: airQuality,
          weather: weather,
          cityName: cityName,
          hasRespiratoryCondition: hasRespiratoryCondition,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Scrollable content area: Compact Activity Advice (Default) + Advisor Result Card (if selected)
        Flexible(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A. Compact Activity Advice Card (Displayed by default)
                OutdoorActivityAdviceCard(
                  airQuality: airQuality,
                  weather: weather,
                  isCompact: true,
                ),

                // B. Detailed Advisor Response (when user selects a prompt chip)
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
                          hasRespiratoryCondition: hasRespiratoryCondition,
                          isRaining: isRaining,
                          rainProbability: rainProbability,
                          precipitation: precipitation,
                          weatherCode: weatherCode,
                        ),
                      );
                    }

                    // Gentle guide banner when no prompt selected
                    return Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Row(
                        children: const [
                          AppIcon(
                            Icons.lightbulb_outline_rounded,
                            size: 14,
                            color: UIColors.primary,
                          ),
                          SizedBox(width: 6),
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
        const SizedBox(height: 12),

        // 2. Quick Prompt Chips - ALWAYS PINNED AT THE BOTTOM
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
                separatorBuilder: (_, index) => const SizedBox(width: 8),
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
                          hasRespiratoryCondition: hasRespiratoryCondition,
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
          color: isSelected ? UIColors.primary : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? UIColors.primary
                : Colors.white.withOpacity(0.18),
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
              color: isSelected ? const Color(0xFF0B1220) : Colors.white,
            ),
            const SizedBox(width: 8),
            AppText.bold(
              prompt.label,
              size: 12.5,
              color: isSelected ? const Color(0xFF0B1220) : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
