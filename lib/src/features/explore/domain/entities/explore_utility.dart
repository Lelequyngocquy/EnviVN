import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/future_work_widget.dart';
import 'package:envivn/src/shared/router/router_key_manager.dart';
import 'package:flutter/material.dart';

/// Enum định nghĩa metadata và hành vi của các tiện ích trong trang Khám phá
enum ExploreUtility {
  storyShare(
    icon: Icons.ios_share_rounded,
    iconColor: UIColors.primary,
    title: 'Chia sẻ thẻ Story',
    subtitle: 'Xuất ảnh tóm tắt vị trí chia sẻ mạng xã hội',
    badgeText: 'MỚI',
    badgeColor: UIColors.primary,
  ),
  desktopWidget(
    icon: Icons.widgets_rounded,
    iconColor: UIColors.secondary,
    title: 'Widget Desktop',
    subtitle: 'Tiện ích 2x2 & 4x2 theo dõi AQI trực tiếp ngoài màn hình',
    badgeText: 'SẮP CÓ',
    badgeColor: UIColors.textMuted,
    futureTitle: 'Widget Màn hình chính',
    futureSubtitle:
        'Tiện ích màn hình chính WidgetKit (iOS) và Glance (Android) đang được hoàn thiện để cập nhật AQI mỗi 30 phút.',
  ),
  morningReport(
    icon: Icons.notifications_active_rounded,
    iconColor: UIColors.warning,
    title: 'Bản tin 06:30 sáng',
    subtitle: 'Thông báo định kỳ nhắc nhở chỉ số không khí đầu ngày',
    badgeText: 'SẮP CÓ',
    badgeColor: UIColors.textMuted,
    futureTitle: 'Thông báo Cục bộ 06:30 Sáng',
    futureSubtitle:
        'Lên lịch thông báo không cần Internet, nhắc nhở đeo khẩu trang và tóm tắt chỉ số AQI trước khi đi làm.',
  ),
  environmentalReport(
    icon: Icons.picture_as_pdf_rounded,
    iconColor: UIColors.error,
    title: 'Báo cáo môi trường',
    subtitle: 'Xuất dữ liệu quan trắc định dạng file PDF và CSV',
    badgeText: 'SẮP CÓ',
    badgeColor: UIColors.textMuted,
    futureTitle: 'Xuất Báo cáo Môi trường',
    futureSubtitle:
        'Công cụ tổng hợp biểu đồ diễn biến nồng độ và xuất bản báo cáo phân tích chất lượng không khí.',
  ),
  healthProfile(
    icon: Icons.health_and_safety_rounded,
    iconColor: UIColors.secondary,
    title: 'Hồ sơ sức khỏe',
    subtitle: 'Cá nhân hóa cảnh báo cho người hen suyễn, trẻ em',
    badgeText: 'SẮP CÓ',
    badgeColor: UIColors.textMuted,
    futureTitle: 'Hồ sơ Sức khỏe Cá nhân',
    futureSubtitle:
        'Thiết lập cảnh báo chuyên biệt theo tình trạng thể chất và bệnh lý hô hấp của bạn và người thân.',
  ),
  nasaRadar(
    icon: Icons.radar_rounded,
    iconColor: UIColors.pinPurple,
    title: 'Radar nhiệt NASA',
    subtitle: 'Phân tích điểm phát xạ nhiệt theo chu kỳ vệ tinh NOAA',
    badgeText: 'SẮP CÓ',
    badgeColor: UIColors.textMuted,
    futureTitle: 'Radar Dị thường nhiệt NASA',
    futureSubtitle:
        'Hệ thống quét vệ tinh thời gian thực phát hiện các điểm nhiệt độ bề mặt cao trên toàn quốc.',
  ),
  monitoringHistory(
    icon: Icons.history_rounded,
    iconColor: UIColors.primaryDark,
    title: 'Lịch sử quan trắc',
    subtitle: 'Truy xuất biến động chất lượng không khí 30 ngày qua',
    badgeText: 'SẮP CÓ',
    badgeColor: UIColors.textMuted,
    futureTitle: 'Lịch sử Quan trắc 30 Ngày',
    futureSubtitle:
        'Dữ liệu lưu trữ cục bộ đối chiếu xu hướng ô nhiễm theo tuần và tháng.',
  ),
  multiPointCompare(
    icon: Icons.compare_arrows_rounded,
    iconColor: UIColors.warning,
    title: 'So sánh đa điểm',
    subtitle: 'So sánh chỉ số ô nhiễm giữa các thành phố',
    badgeText: 'SẮP CÓ',
    badgeColor: UIColors.textMuted,
    futureTitle: 'So sánh Chất lượng Không khí',
    futureSubtitle:
        'Công cụ so sánh song song các chỉ số ô nhiễm giữa 2 hoặc nhiều tỉnh thành trên cả nước.',
  );

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final String? futureTitle;
  final String? futureSubtitle;

  const ExploreUtility({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.badgeColor,
    this.futureTitle,
    this.futureSubtitle,
  });

  /// Kiểm tra xem tính năng này đã có sẵn để dùng hay chưa
  bool get isAvailable => this == ExploreUtility.storyShare;

  /// Điều hướng hoặc mở màn hình thông báo tương ứng
  void handleTap(BuildContext context) {
    switch (this) {
      case ExploreUtility.storyShare:
        Navigator.pushNamed(context, RouterPath.storyShare);
        break;
      default:
        FutureWorkWidget.push(
          context,
          title: futureTitle ?? title,
          subtitle: futureSubtitle ?? subtitle,
          badgeText: 'SẮP RA MẮT • COMING SOON',
          centerIcon: icon,
          bottomPadding: 0,
        );
        break;
    }
  }
}
