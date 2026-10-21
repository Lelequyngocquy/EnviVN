import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/common/utils/heat_index_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/map/domain/entities/map_layer_type.dart';
import 'package:envivn/src/features/map/domain/entities/station_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class StationPreviewCard extends StatelessWidget {
  final StationEntity station;
  final VoidCallback onClose;
  final bool isLoading;
  final MapLayerType activeLayer;

  const StationPreviewCard({
    super.key,
    required this.station,
    required this.onClose,
    this.isLoading = false,
    this.activeLayer = MapLayerType.weather,
  });

  bool get _isContentLoading {
    if (isLoading) {
      
      
      if (activeLayer == MapLayerType.airQuality &&
          !station.id.startsWith('picked_')) {
        return false;
      }
      return true;
    }
    
    if (station.id.startsWith('picked_') && station.temperature == null) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AppGlass(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          _buildHeader(),
          const SizedBox(height: 8),

          
          if (_isContentLoading)
            _buildLoadingContent()
          else
            _buildLayerContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isPicked = station.id.startsWith('picked_');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.rich(
                TextSpan(
                  text: station.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: UIColors.textPrimary,
                  ),
                  children: station.province.isNotEmpty
                      ? [
                          TextSpan(
                            text: ' • ${station.province}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: UIColors.textSecondary,
                            ),
                          ),
                        ]
                      : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isPicked) ...[
                const SizedBox(height: 2.5),
                Row(
                  children: [
                    const AppIcon(
                      Icons.gps_fixed_rounded,
                      size: 11,
                      color: UIColors.pinPurple,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AppText.regular(
                        'Tọa độ: ${station.latitude.toStringAsFixed(4)}°B, ${station.longitude.toStringAsFixed(4)}°Đ',
                        color: UIColors.textSecondary,
                        size: 11,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (isLoading && !_isContentLoading)
          const Padding(
            padding: EdgeInsets.only(right: 8, top: 2),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(UIColors.primary),
              ),
            ),
          ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onClose,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: UIColors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const AppIcon(
              Icons.close_rounded,
              color: UIColors.textSecondary,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    final (icon, color, title, subtitle) = switch (activeLayer) {
      MapLayerType.weather => (
        Icons.cloud_sync_rounded,
        UIColors.secondary,
        'Đang đồng bộ dữ liệu thời tiết...',
        'Nhiệt độ, độ ẩm, sức gió và lượng mưa theo thời gian thực',
      ),
      MapLayerType.airQuality => (
        Icons.air_rounded,
        UIColors.aqiGood,
        'Đang đo lường chất lượng không khí...',
        'Phân tích chỉ số AQI và nồng độ bụi mịn PM2.5, PM10',
      ),
      MapLayerType.thermal => (
        Icons.thermostat_rounded,
        UIColors.aqiUnhealthySensitive,
        'Đang tính toán nguy cơ sốc nhiệt & tia cực tím...',
        'Chỉ số nhiệt Heat Index và bức xạ UV từ vệ tinh',
      ),
      MapLayerType.flood => (
        Icons.water_drop_rounded,
        UIColors.gpsBlue,
        'Đang phân tích nguy cơ ngập úng...',
        'Lưu lượng mưa tức thời và lưu thông dòng chảy',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                AppIcon(icon, size: 18, color: color),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.bold(
                  title,
                  size: 12.5,
                  color: UIColors.textPrimary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                AppText.regular(
                  subtitle,
                  size: 10.5,
                  color: UIColors.textSecondary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerContent() {
    switch (activeLayer) {
      case MapLayerType.weather:
        return _buildWeatherContent();
      case MapLayerType.airQuality:
        return _buildAirQualityContent();
      case MapLayerType.thermal:
        return _buildThermalContent();
      case MapLayerType.flood:
        return _buildFloodContent();
    }
  }

  
  
  
  Widget _buildWeatherContent() {
    final weatherInfo = WeatherCodeHelper.getInfo(station.weatherCode);
    final temp = station.temperature ?? 28.0;
    final feelsLike = station.apparentTemp ?? (temp + 2.0);
    final rain = station.precipitation ?? 0.0;
    final humidity = station.humidity ?? 70;
    final wind = station.windSpeed ?? 10.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: weatherInfo.color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: weatherInfo.color.withOpacity(0.35)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(weatherInfo.icon, size: 22, color: weatherInfo.color),
                  const SizedBox(height: 2),
                  AppText.extraBold(
                    '${temp.toStringAsFixed(0)}°C',
                    size: 14,
                    color: UIColors.textPrimary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText.rich(
                    TextSpan(
                      text: weatherInfo.description,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: weatherInfo.color,
                      ),
                      children: [
                        TextSpan(
                          text:
                              ' • Cảm giác ${feelsLike.toStringAsFixed(0)}°C',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                            color: UIColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      AppText.regular(
                        '🌧️ ${rain.toStringAsFixed(1)}mm',
                        size: 10.5,
                        color: UIColors.textSecondary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppText.regular(
                        '💧 $humidity%',
                        size: 10.5,
                        color: UIColors.textSecondary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppText.regular(
                        '💨 ${wind.toStringAsFixed(0)}km/h',
                        size: 10.5,
                        color: UIColors.textSecondary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),

        
        _buildBottomTip(
          icon: rain > 0 ? Icons.umbrella_rounded : Icons.wb_sunny_outlined,
          color: weatherInfo.color,
          text: rain > 0
              ? 'Có mưa tại khu vực, hãy trang bị áo mưa và giữ khoảng cách an toàn khi lái xe.'
              : 'Thời tiết ổn định, thuận lợi cho các hoạt động di chuyển và sinh hoạt ngoài trời.',
        ),
      ],
    );
  }

  
  
  
  Widget _buildAirQualityContent() {
    final aqiInfo = AQIHelper.getAQIInfo(station.aqi);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: aqiInfo.color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: aqiInfo.color.withOpacity(0.35)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText.extraBold(
                    '${station.aqi}',
                    size: 20,
                    color: aqiInfo.color,
                    height: 1.0,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  AppText.bold(
                    aqiInfo.label,
                    size: 9.5,
                    color: aqiInfo.color,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText.regular(
                          'Bụi mịn PM2.5',
                          size: 10,
                          color: UIColors.textSecondary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        AppText.bold(
                          '${station.pm25.toStringAsFixed(1)} µg/m³',
                          size: 12.5,
                          color: UIColors.textPrimary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: UIColors.white.withOpacity(0.1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText.regular(
                          'Bụi thô PM10',
                          size: 10,
                          color: UIColors.textSecondary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        AppText.bold(
                          '${station.pm10.toStringAsFixed(1)} µg/m³',
                          size: 12.5,
                          color: UIColors.textPrimary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),

        
        _buildBottomTip(
          icon: aqiInfo.wearMask
              ? Icons.masks_rounded
              : Icons.check_circle_outline_rounded,
          color: aqiInfo.color,
          text: aqiInfo.healthAdvice,
        ),
      ],
    );
  }

  
  
  
  Widget _buildThermalContent() {
    
    
    
    if (station.isThermalHotspot) {
      final isActive = station.isActiveFire;
      final Color statusColor = isActive
          ? UIColors.markerRedDark
          : UIColors.aqiGood;
      final IconData statusIcon = isActive
          ? Icons.local_fire_department_rounded
          : Icons.check_circle_outline_rounded;
      final String tempStr = isActive
          ? '${(station.fireBrightnessCelsius ?? 55).toStringAsFixed(0)}°C'
          : '${(station.temperature ?? 28).toStringAsFixed(0)}°C';
      final String statusTitle = isActive
          ? 'CẢNH BÁO: TÍN HIỆU PHÁT XẠ NHIỆT'
          : 'Hiện tại: Bình thường - Không ghi nhận điểm nhiệt';
      final String statusSubtitle = isActive
          ? '${station.fireType ?? "Điểm nhiệt bề mặt"} • Độ tin cậy vệ tinh: ${(station.fireConfidence ?? 90).toStringAsFixed(0)}%'
          : 'Nhiệt độ môi trường: ${(station.temperature ?? 28).toStringAsFixed(0)}°C • Không có tín hiệu nhiệt bất thường';

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(statusIcon, size: 20, color: statusColor),
                    const SizedBox(height: 2),
                    AppText.extraBold(
                      tempStr,
                      size: 13,
                      color: statusColor,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bold(
                      statusTitle,
                      size: 12.5,
                      color: statusColor,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    AppText.regular(
                      statusSubtitle,
                      size: 10.5,
                      color: UIColors.textSecondary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: (isActive ? UIColors.markerRedDark : UIColors.warning)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: (isActive ? UIColors.markerRedDark : UIColors.warning)
                    .withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppIcon(
                      isActive
                          ? Icons.local_fire_department_rounded
                          : Icons.whatshot_outlined,
                      size: 13,
                      color: isActive
                          ? UIColors.markerRedDark
                          : UIColors.warning,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: AppText.bold(
                        isActive
                            ? 'TÍN HIỆU NHIỆT PHÁT HIỆN QUA VỆ TINH NASA'
                            : 'VÙNG CÓ BIẾN ĐỘNG NHIỆT THEO CHU KỲ',
                        size: 10,
                        color: isActive
                            ? UIColors.markerRedDark
                            : UIColors.warning,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (isActive && station.fireDetectedTime != null) ...[
                  const SizedBox(height: 3),
                  AppText.regular(
                    '⏱️ ${station.fireDetectedTime!}',
                    size: 9.5,
                    color: UIColors.textPrimary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (!isActive && station.fireProneSeason != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText.regular(
                        '⏱️ Thời điểm: ',
                        size: 9.5,
                        color: UIColors.textSecondary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Expanded(
                        child: AppText.regular(
                          station.fireProneSeason!,
                          size: 9.5,
                          color: UIColors.textPrimary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (station.spotDescription != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText.regular(
                        '📍 Ghi nhận: ',
                        size: 9.5,
                        color: UIColors.textSecondary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Expanded(
                        child: AppText.regular(
                          station.spotDescription!,
                          size: 9.5,
                          color: UIColors.textPrimary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 6),

          
          _buildBottomTip(
            icon: isActive ? Icons.warning_rounded : Icons.info_outline_rounded,
            color: isActive ? UIColors.markerRedDark : UIColors.warning,
            text: isActive
                ? 'Ghi nhận bức xạ nhiệt tăng cao! Người dân lân cận nên chú ý theo dõi chất lượng không khí và che chắn khi ra ngoài.'
                : 'Hiện tại chưa ghi nhận điểm nhiệt bất thường. Khu vực này có thể xuất hiện biến động nhiệt theo mùa khô hoặc chu kỳ thời tiết.',
          ),
        ],
      );
    }

    
    
    
    final heatIndex = station.calculatedHeatIndex;
    final risk = station.heatRiskLevel;
    final uv = station.uvIndex ?? 6.0;
    final sunburnAdvice = HeatIndexHelper.getSunburnTimeAdvice(uv);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: risk.color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: risk.color.withOpacity(0.35)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(risk.icon, size: 20, color: risk.color),
                  const SizedBox(height: 2),
                  AppText.extraBold(
                    '${heatIndex.toStringAsFixed(0)}°C',
                    size: 14,
                    color: risk.color,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.rich(
                    TextSpan(
                      text: risk.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: risk.color,
                      ),
                      children: [
                        TextSpan(
                          text:
                              ' • Nhiệt thực ${(station.temperature ?? 28).toStringAsFixed(0)}°C',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                            color: UIColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      AppText.regular(
                        '☀️ UV: ${uv.toStringAsFixed(1)}',
                        size: 10.5,
                        color: UIColors.textSecondary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppText.regular(
                        '⏱️ Phơi nắng an toàn: $sunburnAdvice',
                        size: 10.5,
                        color: UIColors.textSecondary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),

        
        _buildBottomTip(
          icon: Icons.wb_sunny_rounded,
          color: risk.color,
          text: risk.description,
        ),
      ],
    );
  }

  
  
  
  Widget _buildFloodContent() {
    final rain = station.precipitation ?? 0.0;
    final isBlackspot = station.isFloodBlackspot;
    final isHighRain = rain >= 20.0;
    final hasRain = rain > 0.0;

    
    final Color liveColor;
    final IconData liveIcon;
    final String liveStatus;
    final String liveDetail;

    if (isHighRain) {
      liveColor = UIColors.markerRed;
      liveIcon = Icons.waves_rounded;
      liveStatus = 'CẢNH BÁO: NGUY CƠ NGẬP';
      liveDetail = isBlackspot
          ? 'Mưa lớn ${rain.toStringAsFixed(1)}mm/h • Dễ ngập ~${station.historicalDepthCm ?? 35}cm'
          : 'Mưa lớn ${rain.toStringAsFixed(1)}mm/h • Tiêu thoát chậm';
    } else if (hasRain) {
      liveColor = UIColors.secondary;
      liveIcon = Icons.water_drop_outlined;
      liveStatus = 'Mưa nhẹ - Lưu thông bình thường';
      liveDetail =
          'Lượng mưa: ${rain.toStringAsFixed(1)}mm/h • Độ ẩm: ${station.humidity ?? 80}%';
    } else {
      liveColor = UIColors.aqiGood;
      liveIcon = Icons.check_circle_outline_rounded;
      liveStatus = 'Hiện tại: Khô ráo - Thông thoáng';
      liveDetail =
          'Không có mưa (0.0mm) • Độ ẩm: ${station.humidity ?? 65}% • Lưu thông tốt';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Row(
          children: [
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: liveColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: liveColor.withOpacity(0.35)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(liveIcon, size: 20, color: liveColor),
                  const SizedBox(height: 2),
                  AppText.extraBold(
                    '${rain.toStringAsFixed(1)}mm',
                    size: 12.5,
                    color: liveColor,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bold(
                    liveStatus,
                    size: 12.5,
                    color: liveColor,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  AppText.regular(
                    liveDetail,
                    size: 10.5,
                    color: UIColors.textSecondary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        
        if (isBlackspot) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: UIColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: UIColors.warning.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppIcon(
                      Icons.warning_amber_rounded,
                      size: 13,
                      color: UIColors.warning,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: AppText.rich(
                        TextSpan(
                          text: 'ĐIỂM ĐEN THƯỜNG NGẬP KHI MƯA LỚN',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: UIColors.warning,
                          ),
                          children: station.historicalDepthCm != null
                              ? [
                                  TextSpan(
                                    text:
                                        ' • Ngập sâu ~${station.historicalDepthCm}cm',
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: UIColors.warning,
                                    ),
                                  ),
                                ]
                              : null,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (station.floodProneTime != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText.regular(
                        '⏱️ Thời điểm: ',
                        size: 9.5,
                        color: UIColors.textSecondary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Expanded(
                        child: AppText.regular(
                          station.floodProneTime!,
                          size: 9.5,
                          color: UIColors.textPrimary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (station.floodTriggerCondition != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText.regular(
                        '⚠️ Điều kiện: ',
                        size: 9.5,
                        color: UIColors.textSecondary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Expanded(
                        child: AppText.regular(
                          station.floodTriggerCondition!,
                          size: 9.5,
                          color: UIColors.textPrimary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 6),

        
        _buildBottomTip(
          icon: isHighRain
              ? Icons.warning_rounded
              : (isBlackspot
                    ? Icons.info_outline_rounded
                    : Icons.check_circle_outline_rounded),
          color: isHighRain
              ? UIColors.markerRed
              : (isBlackspot ? UIColors.warning : liveColor),
          text: isHighRain
              ? 'Lượng mưa vượt ngưỡng an toàn! Hãy chủ động tránh hầm chui & vùng trũng.'
              : (isBlackspot
                    ? 'Hiện tại không ngập. Lưu ý chủ động phương án di chuyển khi có mưa dông hoặc triều cường.'
                    : 'Lưu lượng tiêu thoát nước bình thường, không ghi nhận tình trạng ứ đọng ngập úng.'),
        ),
      ],
    );
  }

  Widget _buildBottomTip({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: UIColors.surfaceVariant.withOpacity(0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: AppIcon(icon, color: color, size: 13),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: AppText.regular(
              text,
              size: 10,
              color: UIColors.textPrimary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
