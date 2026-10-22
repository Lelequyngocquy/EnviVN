import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/shared/router/router_key_manager.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_divider.dart';
import '../widgets/utility_card.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFixedHeader(),

            Expanded(
              child: ClipRect(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                      sliver: SliverGrid.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                        children: [
                          UtilityCard(
                            icon: Icons.ios_share_rounded,
                            iconColor: UIColors.primary,
                            title: 'Chia sẻ thẻ Story',
                            subtitle:
                                'Xuất ảnh tóm tắt vị trí chia sẻ mạng xã hội',
                            badgeText: 'MỚI',
                            badgeColor: UIColors.primary,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RouterPath.storyShare,
                              );
                            },
                          ),
                          UtilityCard(
                            icon: Icons.widgets_rounded,
                            iconColor: UIColors.secondary,
                            title: 'Widget Desktop',
                            subtitle:
                                'Tiện ích 2x2 & 4x2 theo dõi AQI trực tiếp ngoài màn hình',
                            badgeText: 'SẮP CÓ',
                            badgeColor: UIColors.textMuted,
                            onTap: () {
                              FutureWorkWidget.push(
                                context,
                                title: 'Widget Màn hình chính',
                                subtitle:
                                    'Tiện ích màn hình chính WidgetKit (iOS) và Glance (Android) đang được hoàn thiện để cập nhật AQI mỗi 30 phút.',
                                badgeText: 'SẮP RA MẮT • COMING SOON',
                                centerIcon: Icons.widgets_rounded,
                              );
                            },
                          ),

                          UtilityCard(
                            icon: Icons.notifications_active_rounded,
                            iconColor: UIColors.warning,
                            title: 'Bản tin 06:30 sáng',
                            subtitle:
                                'Thông báo định kỳ nhắc nhở chỉ số không khí đầu ngày',
                            badgeText: 'SẮP CÓ',
                            badgeColor: UIColors.textMuted,
                            onTap: () {
                              FutureWorkWidget.push(
                                context,
                                title: 'Thông báo Cục bộ 06:30 Sáng',
                                subtitle:
                                    'Lên lịch thông báo không cần Internet, nhắc nhở đeo khẩu trang và tóm tắt chỉ số AQI trước khi đi làm.',
                                badgeText: 'SẮP RA MẮT • COMING SOON',
                                centerIcon: Icons.notifications_active_rounded,
                              );
                            },
                          ),

                          UtilityCard(
                            icon: Icons.picture_as_pdf_rounded,
                            iconColor: UIColors.error,
                            title: 'Báo cáo môi trường',
                            subtitle:
                                'Xuất dữ liệu quan trắc định dạng file PDF và CSV',
                            badgeText: 'SẮP CÓ',
                            badgeColor: UIColors.textMuted,
                            onTap: () {
                              FutureWorkWidget.push(
                                context,
                                title: 'Xuất Báo cáo Môi trường',
                                subtitle:
                                    'Công cụ tổng hợp biểu đồ diễn biến nồng độ và xuất bản báo cáo phân tích chất lượng không khí.',
                                badgeText: 'SẮP RA MẮT • COMING SOON',
                                centerIcon: Icons.picture_as_pdf_rounded,
                              );
                            },
                          ),

                          UtilityCard(
                            icon: Icons.health_and_safety_rounded,
                            iconColor: UIColors.secondary,
                            title: 'Hồ sơ sức khỏe',
                            subtitle:
                                'Cá nhân hóa cảnh báo cho người hen suyễn, trẻ em',
                            badgeText: 'SẮP CÓ',
                            badgeColor: UIColors.textMuted,
                            onTap: () {
                              FutureWorkWidget.push(
                                context,
                                title: 'Hồ sơ Sức khỏe Cá nhân',
                                subtitle:
                                    'Thiết lập cảnh báo chuyên biệt theo tình trạng thể chất và bệnh lý hô hấp của bạn và người thân.',
                                badgeText: 'SẮP RA MẮT • COMING SOON',
                                centerIcon: Icons.health_and_safety_rounded,
                              );
                            },
                          ),

                          UtilityCard(
                            icon: Icons.radar_rounded,
                            iconColor: UIColors.pinPurple,
                            title: 'Radar nhiệt NASA',
                            subtitle:
                                'Phân tích điểm phát xạ nhiệt theo chu kỳ vệ tinh NOAA',
                            badgeText: 'SẮP CÓ',
                            badgeColor: UIColors.textMuted,
                            onTap: () {
                              FutureWorkWidget.push(
                                context,
                                title: 'Radar Dị thường nhiệt NASA',
                                subtitle:
                                    'Hệ thống quét vệ tinh thời gian thực phát hiện các điểm nhiệt độ bề mặt cao trên toàn quốc.',
                                badgeText: 'SẮP RA MẮT • COMING SOON',
                                centerIcon: Icons.radar_rounded,
                              );
                            },
                          ),

                          UtilityCard(
                            icon: Icons.history_rounded,
                            iconColor: UIColors.primaryDark,
                            title: 'Lịch sử quan trắc',
                            subtitle:
                                'Truy xuất biến động chất lượng không khí 30 ngày qua',
                            badgeText: 'SẮP CÓ',
                            badgeColor: UIColors.textMuted,
                            onTap: () {
                              FutureWorkWidget.push(
                                context,
                                title: 'Lịch sử Quan trắc 30 Ngày',
                                subtitle:
                                    'Dữ liệu lưu trữ cục bộ đối chiếu xu hướng ô nhiễm theo tuần và tháng.',
                                badgeText: 'SẮP RA MẮT • COMING SOON',
                                centerIcon: Icons.history_rounded,
                              );
                            },
                          ),

                          UtilityCard(
                            icon: Icons.compare_arrows_rounded,
                            iconColor: UIColors.warning,
                            title: 'So sánh đa điểm',
                            subtitle:
                                'So sánh chỉ số ô nhiễm giữa các thành phố',
                            badgeText: 'SẮP CÓ',
                            badgeColor: UIColors.textMuted,
                            onTap: () {
                              FutureWorkWidget.push(
                                context,
                                title: 'So sánh Chất lượng Không khí',
                                subtitle:
                                    'Công cụ so sánh song song các chỉ số ô nhiễm giữa 2 hoặc nhiều tỉnh thành trên cả nước.',
                                badgeText: 'SẮP RA MẮT • COMING SOON',
                                centerIcon: Icons.compare_arrows_rounded,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Container(
      color: UIColors.bg,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText.bold(
                  'Khám phá',
                  size: 26,
                  color: UIColors.textPrimary,
                ),
              ),
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: AppIcon.large(
                  Icons.auto_awesome_rounded,
                  color: UIColors.primary,
                ),
              ),
            ],
          ),
          AppDivider(title: 'tiện ích & tính năng mở rộng'),
        ],
      ),
    );
  }
}
