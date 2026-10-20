import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Đại diện cho một điểm nổi bật của tính năng sắp ra mắt trong lộ trình
class FutureWorkHighlight {
  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;

  const FutureWorkHighlight({
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
  });
}

/// Widget chuẩn hiển thị các tính năng đang phát triển / sắp ra mắt (Future Works / Coming Soon).
/// Thiết kế đồng bộ 100% theo style Dark Theme & Liquid Glass của `location_permission_page.dart`.
class FutureWorkWidget extends StatelessWidget {
  /// Tiêu đề chính của tính năng
  final String title;

  /// Mô tả chi tiết hoặc lộ trình phát triển
  final String subtitle;

  /// Nhãn hiển thị trên badge (mặc định: 'SẮP RA MẮT • COMING SOON')
  final String? badgeText;

  /// Icon đại diện ở trung tâm vòng radar phát sáng
  final IconData centerIcon;

  /// Danh sách các tính năng con nổi bật sẽ có trong bản cập nhật tới
  final List<FutureWorkHighlight>? highlights;

  /// Callback khi bấm nút Quay lại (nếu null sẽ tự động pop Navigator hoặc về tab Trang chủ)
  final VoidCallback? onBack;

  /// Văn bản hiển thị trên nút quay lại chính
  final String backButtonText;

  /// Padding dưới cùng (mặc định là 96 chuẩn theo location_permission_page)
  final double bottomPadding;

  const FutureWorkWidget({
    super.key,
    this.title = 'Tính năng đang phát triển',
    this.subtitle =
        'Đội ngũ EnviVN đang tích cực hoàn thiện tính năng này để mang lại dữ liệu môi trường và trải nghiệm tối ưu nhất cho bạn.',
    this.badgeText = 'SẮP RA MẮT • COMING SOON',
    this.centerIcon = Icons.auto_awesome_rounded,
    this.highlights,
    this.onBack,
    this.backButtonText = 'Quay lại',
    this.bottomPadding = 96,
  });

  /// Điều hướng nhanh tới trang FutureWorkWidget dạng fullscreen route
  static Future<T?> push<T>(
    BuildContext context, {
    String title = 'Tính năng đang phát triển',
    String subtitle =
        'Đội ngũ EnviVN đang tích cực hoàn thiện tính năng này để mang lại dữ liệu môi trường và trải nghiệm tối ưu nhất cho bạn.',
    String? badgeText,
    IconData centerIcon = Icons.auto_awesome_rounded,
    List<FutureWorkHighlight>? highlights,
    VoidCallback? onBack,
    String backButtonText = 'Quay lại',
    double bottomPadding = 96,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (_) => FutureWorkWidget(
          title: title,
          subtitle: subtitle,
          badgeText: badgeText,
          centerIcon: centerIcon,
          highlights: highlights,
          onBack: onBack,
          backButtonText: backButtonText,
          bottomPadding: bottomPadding,
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    try {
      context.read<HomeDashboardCubit>().setTab(0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        _FutureWorkRadarIllustration(centerIcon: centerIcon),
                        const SizedBox(height: 32),

                        // 2. Status Badge Pill
                        if (badgeText != null && badgeText!.isNotEmpty) ...[
                          _buildStatusBadge(),
                          const SizedBox(height: 16),
                        ],
                        AppText.bold(
                          title,
                          textAlign: TextAlign.center,
                          size: 24,
                          color: UIColors.textPrimary,
                          height: 1.3,
                        ),
                        const SizedBox(height: 14),
                        AppText.regular(
                          subtitle,
                          textAlign: TextAlign.center,
                          size: 14,
                          color: UIColors.textSecondary,
                          height: 1.5,
                        ),
                        if (highlights != null && highlights!.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildHighlightsCard(),
                        ],
                        const Spacer(),
                        _buildActionPanel(context),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: UIColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: UIColors.primary.withOpacity(0.32), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: UIColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: UIColors.primary.withOpacity(0.8),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppText.bold(
            badgeText!,
            size: 11,
            letterSpacing: 0.8,
            color: UIColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsCard() {
    return AppGlass(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(highlights!.length, (index) {
          final item = highlights![index];
          final isLast = index == highlights!.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (item.iconColor ?? UIColors.secondary).withOpacity(
                      0.15,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (item.iconColor ?? UIColors.secondary).withOpacity(
                        0.3,
                      ),
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: AppIcon(
                      item.icon,
                      size: 18,
                      color: item.iconColor ?? UIColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.semiBold(
                        item.title,
                        size: 13,
                        color: UIColors.textPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText.regular(
                        item.description,
                        size: 11,
                        color: UIColors.textSecondary,
                        height: 1.4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionPanel(BuildContext context) {
    return AppGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () => _handleBack(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: UIColors.primary,
            foregroundColor: UIColors.bg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppIcon(
                Icons.arrow_back_rounded,
                size: 18,
                color: UIColors.bg,
              ),
              const SizedBox(width: 8),
              AppText.bold(backButtonText, size: 15, color: UIColors.bg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minh họa Radar Pulse phong cách futuristic đồng bộ tuyệt đối với `LocationRadarIllustration`
class _FutureWorkRadarIllustration extends StatelessWidget {
  final IconData centerIcon;

  const _FutureWorkRadarIllustration({required this.centerIcon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse 1 (Vòng ngoài cùng)
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: UIColors.primary.withOpacity(0.18),
                  width: 2,
                ),
              ),
            ),

            // Pulse 2 (Vòng giữa)
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: UIColors.primary.withOpacity(0.32),
                  width: 2,
                ),
              ),
            ),

            // Pulse 3 (Vòng trong)
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: UIColors.primary.withOpacity(0.48),
                  width: 2,
                ),
              ),
            ),

            // Điểm vệ tinh phát sáng phụ (Orbiting accent lights)
            Positioned(
              top: 36,
              right: 48,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: UIColors.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: UIColors.secondary.withOpacity(0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 46,
              left: 54,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: UIColors.warning,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: UIColors.warning.withOpacity(0.8),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),

            // Bóng mờ bên dưới tâm phát sáng
            Positioned(
              bottom: 68,
              child: Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: UIColors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Quả cầu tâm phát sáng (Main Glowing Center Orb)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: UIColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: UIColors.primary.withOpacity(0.6),
                    blurRadius: 26,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Center(
                child: AppIcon(centerIcon, size: 30, color: UIColors.bg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
