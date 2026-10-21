import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/features/advisor/domain/entities/advisor_decision.dart';
import 'package:envivn/src/features/advisor/domain/entities/advisor_evidence.dart';
import 'package:envivn/src/features/advisor/domain/entities/quick_prompt_type.dart';
import 'package:envivn/src/shared/widgets/glass.dart';



class AdvisorResultCard extends StatelessWidget {
  final AdvisorDecision decision;
  final QuickPromptType? prompt;
  final int? aqi;
  final double? pm25;
  final double? temperature;
  final double? uvIndex;
  final bool hasRespiratoryCondition;
  final bool isRaining;
  final int rainProbability;
  final double precipitation;
  final int? weatherCode;
  final List<AdvisorEvidence>? customEvidences;

  const AdvisorResultCard({
    super.key,
    required this.decision,
    this.prompt,
    this.aqi,
    this.pm25,
    this.temperature,
    this.uvIndex,
    this.hasRespiratoryCondition = false,
    this.isRaining = false,
    this.rainProbability = 0,
    this.precipitation = 0.0,
    this.weatherCode,
    this.customEvidences,
  });

  @override
  Widget build(BuildContext context) {
    final level = decision.level;
    final effectiveEvidences =
        customEvidences ??
        (aqi != null && pm25 != null && temperature != null
            ? AdvisorEvidence.evaluate(
                prompt: prompt ?? QuickPromptType.running,
                aqi: aqi!,
                pm25: pm25!,
                temperature: temperature!,
                uvIndex: uvIndex,
                hasRespiratoryCondition: hasRespiratoryCondition,
                isRaining: isRaining,
                rainProbability: rainProbability,
                precipitation: precipitation,
                weatherCode: weatherCode,
              )
            : const <AdvisorEvidence>[]);

    return AppGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: level.color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: level.color.withOpacity(0.4), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(level.icon, size: 16, color: level.color),
                const SizedBox(width: 6),
                AppText.bold(level.label, size: 12, color: level.color),
              ],
            ),
          ),
          const SizedBox(height: 14),

          
          AppText.bold(
            decision.headline,
            size: 18,
            color: UIColors.textPrimary,
            height: 1.35,
          ),
          const SizedBox(height: 10),

          
          AppText.regular(
            decision.explanation,
            size: 13.5,
            color: UIColors.textSecondary,
            height: 1.5,
          ),
          const SizedBox(height: 16),

          
          if (effectiveEvidences.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: UIColors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: UIColors.white.withOpacity(0.08),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      AppIcon(
                        Icons.fact_check_outlined,
                        size: 16,
                        color: UIColors.secondary,
                      ),
                      SizedBox(width: 8),
                      AppText.semibold(
                        'Dữ liệu tính toán & Dẫn chứng đối chiếu',
                        size: 13,
                        color: UIColors.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...effectiveEvidences.map((evidence) {
                    final Color badgeColor = evidence.isDanger
                        ? UIColors.error
                        : (evidence.isExceeded
                              ? UIColors.warning
                              : UIColors.aqiGood);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: badgeColor.withOpacity(0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center, 
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: badgeColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      
                                      Expanded(
                                        child: AppText.bold(
                                          '${evidence.metricName}: ${evidence.formattedValue}',
                                          size: 12.5,
                                          color: UIColors.textPrimary,
                                          maxLines: 3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: UIColors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: AppText.medium(
                                    evidence.standardBenchmark,
                                    size: 10.5,
                                    color: UIColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            AppText.regular(
                              '• ${evidence.detailComparison}',
                              size: 11.5,
                              color: badgeColor.withOpacity(0.95),
                              height: 1.35,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: UIColors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: UIColors.white.withOpacity(0.08),
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    AppIcon(
                      Icons.task_alt_rounded,
                      size: 16,
                      color: UIColors.primary,
                    ),
                    SizedBox(width: 8),
                    AppText.semibold(
                      'Khuyến nghị hành động thực tế',
                      size: 13,
                      color: UIColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...decision.tips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6, right: 8),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: level.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: AppText.regular(
                            tip,
                            size: 12.5,
                            color: UIColors.white.withOpacity(0.9),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          
          if (decision.alternativeHour != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: UIColors.warning.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: UIColors.warning.withOpacity(0.35),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const AppIcon(
                    Icons.access_time_filled_rounded,
                    size: 18,
                    color: UIColors.warning,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText.bold(
                          'Khung giờ vàng thay thế:',
                          size: 11.5,
                          color: UIColors.warning,
                        ),
                        const SizedBox(height: 2),
                        AppText.medium(
                          decision.alternativeHour!,
                          size: 13,
                          color: UIColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
