import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/utils/aqi_helper.dart';
import '../../../../core/presentation/widgets/app_status_tag.dart';

class AQIGaugeWidget extends StatefulWidget {
  final int aqi;

  const AQIGaugeWidget({
    super.key,
    required this.aqi,
  });

  @override
  State<AQIGaugeWidget> createState() => _AQIGaugeWidgetState();
}

class _AQIGaugeWidgetState extends State<AQIGaugeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: widget.aqi.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AQIGaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.aqi != widget.aqi) {
      _animation = Tween<double>(
        begin: oldWidget.aqi.toDouble(),
        end: widget.aqi.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = AQIHelper.getAQIInfo(widget.aqi);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedAqi = _animation.value.round();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: UIColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: UIColors.border),
            boxShadow: [
              BoxShadow(
                color: info.color.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: info.color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.eco_rounded, color: info.color, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Chỉ số AQI (US)',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: UIColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppStatusTag(
                    label: info.label,
                    color: info.color,
                    size: AppTagSize.medium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                width: 260,
                child: CustomPaint(
                  painter: _AQIGaugePainter(
                    aqi: _animation.value,
                    activeColor: info.color,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$animatedAqi',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              color: info.color,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'US AQI',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: UIColors.textLight,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                info.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: UIColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AQIGaugePainter extends CustomPainter {
  final double aqi;
  final Color activeColor;

  _AQIGaugePainter({required this.aqi, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = size.width * 0.42;

    const startAngle = pi * 0.85;
    const sweepAngle = pi * 1.3;

    // Background track
    final bgPaint = Paint()
      ..color = UIColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Active progress arc
    final progress = (aqi / 300.0).clamp(0.0, 1.0);
    final activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: const [
          UIColors.aqiGood,
          UIColors.aqiModerate,
          UIColors.aqiUnhealthySensitive,
          UIColors.aqiUnhealthy,
          UIColors.aqiVeryUnhealthy,
          UIColors.aqiHazardous,
        ],
        stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      activePaint,
    );

    // Indicator Dot on Arc
    final currentAngle = startAngle + (sweepAngle * progress);
    final indicatorX = center.dx + radius * cos(currentAngle);
    final indicatorY = center.dy + radius * sin(currentAngle);

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotInnerPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(indicatorX, indicatorY), 8, dotBorderPaint);
    canvas.drawCircle(Offset(indicatorX, indicatorY), 5, dotInnerPaint);
  }

  @override
  bool shouldRepaint(covariant _AQIGaugePainter oldDelegate) {
    return oldDelegate.aqi != aqi || oldDelegate.activeColor != activeColor;
  }
}
