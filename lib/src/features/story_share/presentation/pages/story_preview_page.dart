import 'dart:io';
import 'dart:ui' as ui;

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_cubit.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_state.dart';
import 'package:envivn/src/features/details/presentation/cubits/details_cubit.dart';
import 'package:envivn/src/features/details/presentation/cubits/details_state.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/story_card_view.dart';
import '../widgets/story_options_bottom_sheet.dart';

class StoryPreviewPage extends StatefulWidget {
  const StoryPreviewPage({super.key});

  @override
  State<StoryPreviewPage> createState() => _StoryPreviewPageState();
}

class _StoryPreviewPageState extends State<StoryPreviewPage> {
  final GlobalKey _cardKey = GlobalKey();
  StoryRatio _ratio = StoryRatio.story;
  List<StoryCardType> _selectedCards = [
    StoryCardType.airQuality,
    StoryCardType.weather,
    StoryCardType.floodRisk,
    StoryCardType.advisorHealth,
  ];
  int? _selectedCardIndex;
  bool _isSharing = false;

  void _handleSwapCards(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= _selectedCards.length) return;
    if (toIndex < 0 || toIndex >= _selectedCards.length) return;
    setState(() {
      final temp = _selectedCards[fromIndex];
      _selectedCards[fromIndex] = _selectedCards[toIndex];
      _selectedCards[toIndex] = temp;
      _selectedCardIndex = toIndex;
    });
  }

  Future<void> _handleShare(String cityName) async {
    if (_isSharing) return;

    final ratio = MediaQuery.of(context).devicePixelRatio.clamp(1.5, 2.2);

    setState(() {
      _isSharing = true;
      _selectedCardIndex = null;
    });

    await Future.delayed(const Duration(milliseconds: 60));

    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Không tìm thấy vùng hiển thị thẻ ảnh');
      }

      final image = await boundary.toImage(pixelRatio: ratio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Không thể chuyển đổi dữ liệu ảnh');
      }

      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/envivn_story_$timestamp.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'Chất lượng không khí tại $cityName hôm nay • Ứng dụng EnviVN',
        subject: 'EnviVN - $cityName',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: UIColors.error,
            content: AppText.semiBold(
              'Không thể chia sẻ ảnh: $e',
              size: 13,
              color: UIColors.white,
              maxLines: 3,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.bg,
      body: SafeArea(
        child: BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
          builder: (context, homeState) {
            return BlocBuilder<AirQualityCubit, AirQualityState>(
              builder: (context, aqiState) {
                return BlocBuilder<DetailsCubit, DetailsState>(
                  builder: (context, detailsState) {
                    final city = homeState.currentCity;
                    final aqi = aqiState.airQuality;
                    final weather = detailsState.details;
                    final now = DateTime.now();

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const AppBackButton(),
                              const Gap(12),
                              const Expanded(
                                child: AppText.bold(
                                  'Xem trước thẻ chia sẻ',
                                  size: 17,
                                  color: UIColors.textPrimary,
                                  maxLines: 3,
                                ),
                              ),
                              AppCircleButton(
                                icon: Icons.tune_rounded,
                                iconColor: UIColors.primary,
                                iconSize: 22,
                                tooltip: 'Tùy chọn hiển thị',
                                onTap: () {
                                  StoryOptionsBottomSheet.show(
                                    context,
                                    currentRatio: _ratio,
                                    currentCards: _selectedCards,
                                    city: city,
                                    airQuality: aqi,
                                    weather: weather,
                                    onApply: (newRatio, newCards) {
                                      setState(() {
                                        _ratio = newRatio;
                                        _selectedCards = newCards;
                                        _selectedCardIndex = null;
                                      });
                                    },
                                  );
                                },
                              ),
                            ],
                          ),

                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: _ratio == StoryRatio.story
                                            ? 320
                                            : (_ratio == StoryRatio.square
                                                  ? 360
                                                  : 340),
                                      ),
                                      child: RepaintBoundary(
                                        key: _cardKey,
                                        child: StoryCardView(
                                          city: city,
                                          airQuality: aqi,
                                          weather: weather,
                                          updateTime: now,
                                          ratio: _ratio,
                                          cards: _selectedCards,
                                          selectedIndex: _selectedCardIndex,
                                          onCardSelected: (idx) {
                                            setState(() {
                                              _selectedCardIndex = idx;
                                            });
                                          },
                                          onSwapCards: _handleSwapCards,
                                          isInteractive: !_isSharing,
                                        ),
                                      ),
                                    ),
                                    const Gap(10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        AppIcon(
                                          Icons.touch_app_rounded,
                                          size: 13,
                                          color: UIColors.textMuted,
                                        ),
                                        Gap(4),
                                        AppText.regular(
                                          'Chạm vào thẻ để đổi vị trí',
                                          size: 11,
                                          color: UIColors.textMuted,
                                          maxLines: 3,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          AppButton(
                            title: 'Chia sẻ thẻ Story',
                            icon: Icons.ios_share_rounded,
                            isLoading: _isSharing,
                            onTap: () => _handleShare(city.name),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
