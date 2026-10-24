# EnviVN - Environmental Monitoring and Weather Risk Early-Warning System

EnviVN is a cross-platform mobile application developed with Flutter, providing real-time air quality index (AQI) tracking, high-precision weather forecasting, urban flood risk warnings, and satellite-detected thermal radiation and surface temperature anomaly monitoring across Vietnam via NASA FIRMS.

The application is architected strictly following Clean Architecture principles combined with the BLoC/Cubit state management pattern, ensuring strong separation of concerns, high maintainability, and enterprise-grade testability.

---

## 1. Core Features & Screen Breakdown

### 1.1. Real-Time Environmental Dashboard

The central dashboard aggregates real-time air quality indices and meteorological metrics for the user's current GPS location or selected city. Key data points include US AQI, PM2.5, PM10, ambient temperature, apparent heat index, humidity, wind velocity, precipitation likelihood, and ultraviolet exposure.

![Dashboard Overview](screenshots/dashboard_screen.png)

### 1.2. 24-Hour Analytics & 7-Day Forecasting

Provides comprehensive 24-hour hourly trend charts for air pollution and temperature fluctuations, accompanied by extended 7-day meteorological outlooks and pollutant concentration breakdowns (CO, NO2, SO2, O3) benchmarked against international standards.

![24-Hour Detail and Forecast](screenshots/details_screen.png)

### 1.3. Interactive Multi-Layer GIS Map & Custom Dropped Pin

An interactive mapping interface powered by vector tiles featuring 4 specialized operational layers: Air Quality (AQI), Weather, Urban Flood Vulnerability, and Satellite Thermal Anomalies. Users can tap anywhere across Vietnam to drop a custom pin, instantly resolving the nearest administrative province and querying live environmental data for that specific coordinate.

![Multi-layer Map and Custom Pin](screenshots/map_layers_screen.png)

### 1.4. NASA FIRMS Satellite Thermal Radiation Monitoring

Direct integration with NASA FIRMS utilizing next-generation NOAA-20 and NOAA-21 VIIRS 375m sensor data. Visualizes active surface thermal radiation points across Vietnam with fire radiative power (FRP) metrics and terrain-aware contextual categorization.

![Satellite Thermal Hotspots](screenshots/thermal_hotspots_screen.png)

### 1.5. Deterministic Environmental Health & Activity Advisor

An on-device, zero-latency rule engine evaluating current ambient conditions to generate actionable outdoor health recommendations (e.g., jogging, cycling, mask usage) accompanied by concrete evidentiary comparisons against WHO and Vietnam national standard QCVN 05:2023/BTNMT.

![Smart Advisor](screenshots/advisor_screen.png)

### 1.6. Visual Story Sharing & Card Export

Allows users to generate exportable visual cards formatted for social sharing in 9:16 (Story/Reel) and 1:1 (Square) aspect ratios with customizable card metrics and high-fidelity rendering.

![Story Share Preview](screenshots/story_share_screen.png)

---

## 2. System Architecture

The codebase enforces Clean Architecture with strict separation across Presentation, Domain, Infrastructure, Core, Shared, and Common layers.

```
lib/
├── main.dart
└── src/
    ├── common/
    │   ├── constants/
    │   │   ├── colors.dart               # Palette definitions (UIColors)
    │   │   └── strings.dart              # Default application strings
    │   ├── extensions/                   # Utility extensions on primitive types
    │   └── utils/
    │       ├── aqi_helper.dart           # US EPA AQI linear interpolation helper
    │       ├── geo_distance_helper.dart  # Great-circle Haversine distance calculator
    │       └── heat_index_helper.dart    # Rothfusz apparent heat index equation
    ├── core/
    │   ├── di/
    │   │   └── injection_container.dart  # Dependency injection setup (GetIt)
    │   ├── domain/
    │   │   └── entities/                 # BaseResult, BaseResponse contracts
    │   ├── infrastructure/
    │   │   ├── configs/                  # EnvConfig (.env loader)
    │   │   ├── datasources/
    │   │   │   ├── local/                # LocalStorage (SharedPreferences wrapper)
    │   │   │   └── network/              # RestfulRequest (HTTP client wrapper)
    │   │   └── services/                 # LocationService (GPS hardware wrapper)
    │   └── presentation/                 # Shared core UI widgets (AppText, AppIcon)
    ├── features/
    │   ├── advisor/                      # Health & outdoor activity advisor
    │   │   ├── domain/entities/          # AdvisorDecision, AdvisorEvidence, SafetyLevel
    │   │   └── presentation/             # AdvisorCubit, AdvisorModalSheet
    │   ├── air_quality/                  # Air quality tracking (Open-Meteo)
    │   │   ├── domain/                   # IAirQualityRepository, AirQualityEntity
    │   │   ├── infrastructure/           # AirQualityRepository, AirQualityModel, Paths
    │   │   └── presentation/             # AirQualityCubit, AQIGaugeWidget
    │   ├── details/                      # Weather and 24h hourly detail analytics
    │   │   ├── domain/                   # IDetailsRepository, DetailsEntity
    │   │   ├── infrastructure/           # DetailsRepository, DetailsModel, Paths
    │   │   └── presentation/             # DetailsCubit, TwentyFourHourDetailPage
    │   ├── explore/                      # Environmental news and utilities
    │   │   ├── domain/entities/          # UtilityItem, NewsItem
    │   │   └── presentation/             # ExplorePage, UtilityCard
    │   ├── home/                         # Central dashboard
    │   │   ├── domain/entities/          # CityEntity
    │   │   └── presentation/             # HomeDashboardCubit, HomePage, Sheets
    │   ├── map/                          # Multi-layer GIS map and NASA FIRMS
    │   │   ├── domain/                   # IMapRepository, INasaFirmsRepository
    │   │   │   └── entities/             # MapLayerType, StationEntity, VietnamProvince
    │   │   ├── infrastructure/           # MapRepository, NasaFirmsRepository
    │   │   │   ├── models/               # StationModel, ThermalHotspotModel
    │   │   │   └── paths/                # MapPaths, NasaFirmsPaths
    │   │   └── presentation/             # MapCubit, MapPage, MapSideControls
    │   └── story_share/                  # Story card generation and export
    │       └── presentation/             # StoryPreviewPage, StoryCardView
    └── shared/
        ├── router/                       # GlobalKeyManager, RouterPath
        └── widgets/                      # AppGlass, AppButton, AppTopToast
```

### Architectural Layer Responsibilities

- Domain Layer: Contains Repository interfaces, domain entities, and business rules. Completely decoupled from external packages, databases, and UI frameworks.
- Infrastructure Layer: Implements repository contracts, handles API communications via RestfulRequest, manages local persistence via LocalStorage, defines network endpoints, and maps raw JSON or CSV into typed models.
- Presentation Layer: Uses BLoC/Cubit for deterministic state management, consumes domain entities, and delivers responsive, adaptive interfaces.
- Core & Common: Foundation layer providing dependency injection via GetIt, central application environment configuration, shared network/storage abstractions, and reusable mathematical utility engines.

---

## 3. Developer Guide to Calculation Methods

The application performs several real-time calculations directly on the client side. The following summaries focus on practical implementation, inputs, outputs, and their usage within the app.

### 3.1. Geographic Distance Calculation (`GeoDistanceHelper`)

- Purpose: Computes the spherical great-circle distance between two geographic coordinates on Earth using the Haversine formula (Earth radius R = 6,371 km).
- Implementation:
  - Inputs: Latitude and longitude of Point A (lat1, lon1) and Point B (lat2, lon2).
  - Method: `GeoDistanceHelper.calculateDistanceKm(lat1, lon1, lat2, lon2)`.
  - Display formatting:
    - Distance under 10 km: Displayed with 1 decimal place (e.g., "~3.4km").
    - Distance 10 km and above: Rounded to the nearest integer (e.g., "~25km", "~140km").
- App usage: When a user taps anywhere on the map, the app uses this method to find the closest monitoring station. If the nearest station is further than 35 km, the app queries `VietnamProvince.provinces` to resolve the nearest Vietnamese province and formats a human-readable title (e.g., "Dropped Pin (~4.2km from Da Nang)").

### 3.2. Apparent Heat Index Calculation (`HeatIndexHelper`)

- Purpose: Estimates the physiological temperature perceived by the human body by combining dry-bulb ambient temperature with relative humidity.
- Implementation:
  - Inputs: Ambient temperature in Celsius (T) and relative humidity percentage (RH).
  - Method: `HeatIndexHelper.calculateHeatIndex(temperatureCelsius, humidity)`.
  - Logic: Converts temperature to Fahrenheit, computes apparent temperature via Rothfusz's multivariate regression polynomial equation, and converts the result back to Celsius.
  - Risk tiers:
    - Under 27 degrees Celsius: Safe (Normal conditions).
    - 27 to 31 degrees Celsius: Caution (Fatigue possible with prolonged physical exertion).
    - 32 to 40 degrees Celsius: Extreme Caution (Risk of sunstroke and muscle cramps).
    - 41 degrees Celsius and above: Danger (Imminent risk of heat exhaustion and heatstroke).
- App usage: Displayed on the Home Weather Card and Details page with dedicated warning badges to inform users of thermal stress risks during heatwaves.

### 3.3. Air Quality Index Interpolation (`AQIHelper`)

- Purpose: Converts raw particulate matter concentrations (PM2.5 and PM10 in ug/m3) into standard US EPA Air Quality Index values.
- Implementation:
  - Inputs: Measured pollutant concentration (C).
  - Method: `AQIHelper.calculateAqiFromPm25(pm25)` and `AQIHelper.calculateAqiFromPm10(pm10)`.
  - Logic: Employs standard piecewise linear interpolation:
    `I = [ (I_high - I_low) / (C_high - C_low) ] * (C - C_low) + I_low`
    where C_low and C_high are regulatory concentration thresholds, and I_low and I_high are the corresponding index bracket values.
  - Categories:
    - 0 - 50: Good (Green)
    - 51 - 100: Moderate (Yellow)
    - 101 - 150: Unhealthy for Sensitive Groups (Orange)
    - 151 - 200: Unhealthy (Red)
    - 201 - 300: Very Unhealthy (Purple)
    - 301+: Hazardous (Maroon)
- App usage: Generates the prominent AQI gauge on the home screen, drives color-coded health risk indicators, and informs the smart advisor rule engine.

### 3.4. NASA FIRMS Satellite Thermal Anomaly Metrics (`ThermalHotspotModel`)

- Purpose: Parses and contextualizes infrared brightness and radiant energy detected by NOAA-20 and NOAA-21 VIIRS 375m satellite sensors.
- Implementation:
  - Brightness temperature: Converts sensor Band I4 brightness from Kelvin to Celsius (`T_celsius = T_kelvin - 273.15`).
  - Fire Radiative Power (FRP): Measured in Megawatts (MW).
    - FRP >= 20.0 MW: Classified as high radiative output.
    - FRP < 20.0 MW: Classified as standard surface thermal emission.
  - Terrain classification: The app evaluates geographic coordinates against Vietnamese regional terrain:
    - Lowland / Delta regions: Classified objectively as surface thermal points in lowland terrain.
    - Highland / Mountainous regions: Classified objectively as surface thermal points in highland terrain.
  - Sensor confidence: Maps sensor detection flags ('h', 'n', 'l') to confidence percentages (95%, 80%, 50%).
- App usage: Renders glowing thermal hotspot markers on the satellite map layer, accompanied by preview cards detailing radiative intensity, detection timestamp, and terrain context.

### 3.5. Urban Flood Vulnerability Evaluation

- Purpose: Flags localized urban flooding danger in vulnerable metropolitan centers.
- Implementation: Combines real-time precipitation intensity (precipitation >= 20.0 mm/h) with pre-mapped historical drainage blackspots (`FloodBlackspot.vietnamBlackspots`).
- App usage: Toggles the `isHighFloodRisk` warning flag on station cards and the flood map layer to alert users of potential street-level inundation.

---

## 4. Setup and Installation Guide

### 4.1. Prerequisites

- Flutter SDK: Version 3.22.0 or higher (compatible with Flutter 3.44+).
- Dart SDK: Version 3.12.0 or higher.
- Git installed on your system.
- Android Studio (with Android SDK and command-line tools) or VS Code.
- Xcode (version 15 or higher, for macOS/iOS builds).

### 4.2. Environment Configuration

Create a `.env` file in the project root directory:

```bash
# Windows PowerShell:
Copy-Item .env_example .env

# macOS / Linux:
cp .env_example .env
```

Ensure the `.env` file contains your NASA FIRMS map key:

```properties
APP_NAME=EnviVN
APP_ENV=development
OPEN_METEO_WEATHER_BASE_URL=https://api.open-meteo.com
OPEN_METEO_AIR_QUALITY_BASE_URL=https://air-quality-api.open-meteo.com
OPEN_METEO_GEOCODING_BASE_URL=https://geocoding-api.open-meteo.com
OSM_TILE_URL=https://tile.openstreetmap.org/{z}/{x}/{y}.png
MAP_USER_AGENT=com.envivn.envivn
NASA_FIRMS_BASE_URL=https://firms.modaps.eosdis.nasa.gov/api
NASA_FIRMS_MAP_KEY= #get your key at: https://firms.modaps.eosdis.nasa.gov/api/map_key
```

### 4.3. Running on Visual Studio Code

1. Install the official Flutter and Dart extensions from the Marketplace.
2. Open the project root directory in VS Code.
3. Open the integrated terminal and resolve dependencies:
   ```bash
   flutter pub get
   ```
4. Select your target device from the bottom status bar (connected Android phone, emulator, or iOS simulator).
5. Press F5 or run:
   ```bash
   flutter run
   ```

### 4.4. Running on Android Studio

1. Install the Flutter plugin (Settings -> Plugins -> Marketplace -> Search "Flutter").
2. Open the `EnviVN` project directory.
3. Click "Pub get" in the top notification bar when opening `pubspec.yaml`.
4. Select your connected device or Android Virtual Device (AVD).
5. Click the green Run button or press Shift + F10.

### 4.5. Running on Xcode and iOS (macOS Required)

1. Verify CocoaPods installation:
   ```bash
   pod --version
   ```
2. Install Pod dependencies:
   ```bash
   cd ios
   pod install
   cd ..
   ```
3. Open the workspace file in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
4. In Xcode, configure Signing & Capabilities with your Apple Developer Team.
5. Run on an iOS Simulator or connected iPhone:
   ```bash
   flutter run -d ios
   ```

### 4.6. Building Android APK for Direct Installation

To generate APK files for direct side-loading on Android devices:

- Optimized 64-bit APK (Recommended, ~23MB):

  ```bash
  flutter build apk --split-per-abi
  ```

  Output path: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

- Universal Fat APK (Works across all Android CPUs, ~59MB):
  ```bash
  flutter build apk --release
  ```
  Output path: `build/app/outputs/flutter-apk/app-release.apk`

Install directly via ADB:

```bash
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## 5. Automated Testing & Verification

The project includes an automated test suite with 30 unit and widget tests:

- Run static analysis:

  ```bash
  flutter analyze
  ```

  Expected outcome: 0 issues.

- Execute the test suite:
  ```bash
  flutter test
  ```
  Coverage includes:
  - NASA FIRMS NOAA-20 VIIRS CSV parsing and 15-minute TTL caching mechanisms.
  - In-flight HTTP request deduplication and HTTP 429 rate-limit cooldown handling.
  - Great-circle Haversine distance calculations and nearest province resolvers.
  - Apparent heat index polynomial calculation and risk tier mappings.
  - US EPA AQI linear interpolation calculations.
  - Responsive layout tests verifying zero pixel overflow on narrow mobile screens (320px).

---

## 6. Data Attribution

- Meteorological forecasts and air quality observations provided by Open-Meteo under standard API terms.
- Active surface thermal radiation data provided by NASA FIRMS (NOAA-20 and NOAA-21 VIIRS Near Real-Time).
- Map base tiles provided by OpenStreetMap contributors.

---

---

# BẢN DỊCH TIẾNG VIỆT (VIETNAMESE TRANSLATION)

---

# EnviVN - Hệ Thống Giám Sát Môi Trường Và Cảnh Báo Rủi Ro Thời Tiết

EnviVN là ứng dụng di động đa nền tảng phát triển bằng Flutter, cung cấp giải pháp theo dõi chất lượng không khí (AQI), dự báo thời tiết độ chính xác cao, cảnh báo nguy cơ ngập úng đô thị và giám sát các điểm phát xạ nhiệt/dị thường nhiệt bề mặt theo thời gian thực từ vệ tinh NASA FIRMS trên toàn lãnh thổ Việt Nam.

Ứng dụng được thiết kế tuân thủ nghiêm ngặt mô hình Kiến trúc Sạch (Clean Architecture) kết hợp quản lý trạng thái BLoC/Cubit, bảo đảm tính độc lập giữa các tầng, dễ bảo trì và khả năng kiểm thử toàn diện.

---

## 1. Tính Năng Chính Và Giao Diện Ứng Dụng

### 1.1. Bảng Điều Khiển Môi Trường Thời Gian Thực

Màn hình tổng quan hợp nhất các chỉ số chất lượng không khí và dữ liệu khí tượng tức thời tại vị trí GPS thực tế của người dùng hoặc thành phố được chọn. Các thông số hiển thị bao gồm: chỉ số US AQI, bụi mịn PM2.5, PM10, nhiệt độ môi trường, nhiệt độ cảm nhận (Heat Index), độ ẩm, tốc độ gió, xác suất mưa và chỉ số tia UV.

![Man Hinh Tong Quan](screenshots/dashboard_screen.png)

### 1.2. Phân Tích Xu Hướng 24 Giờ & Dự Báo 7 Ngày

Cung cấp biểu đồ diễn biến 24 giờ tiếp theo cho chất lượng không khí và nhiệt độ, kèm theo bảng dự báo thời tiết 7 ngày mở rộng và chi tiết nồng độ các chất ô nhiễm (CO, NO2, SO2, O3) đối chiếu theo quy chuẩn quốc tế.

![Chi Tiet 24 Gio Va Du Bao](screenshots/details_screen.png)

### 1.3. Bản Đồ Môi Trường Đa Tầng & Ghim Vị Trí Tùy Chọn

Giao diện bản đồ tương tác với 4 lớp dữ liệu chuyên biệt: Chất lượng không khí (AQI), Thời tiết, Điểm đen ngập úng đô thị, và Điểm phát xạ nhiệt vệ tinh. Người dùng có thể chạm vào bất kỳ điểm nào trên bản đồ để ghim vị trí tùy chọn; hệ thống sẽ tự động xác định tỉnh thành Việt Nam gần nhất và tải dữ liệu môi trường thực tế cho tọa độ đó.

![Ban Do Da Tang Va Ghim Vi Tri](screenshots/map_layers_screen.png)

### 1.4. Lớp Dữ Liệu Điểm Phát Xạ Nhiệt Vệ Tinh NASA FIRMS

Tích hợp trực tiếp dữ liệu từ vệ tinh thế hệ mới NOAA-20 và NOAA-21 VIIRS độ phân giải 375m của NASA. Hiển thị trực quan các điểm phát xạ nhiệt bề mặt trên cả nước kèm thông lượng bức xạ nhiệt (FRP) và phân loại khách quan theo vùng địa hình (vùng cao / đồi núi hoặc vùng đồng bằng).

![Diem Nhiet Ve Tinh](screenshots/thermal_hotspots_screen.png)

### 1.5. Cố Vấn Sức Khỏe & Hoạt Động Ngoài Trời

Động cơ tính toán hoạt động hoàn toàn trên thiết bị (offline, 0ms latency), tự động phân tích các chỉ số môi trường hiện tại để đưa ra quyết định tư vấn thực tế (chạy bộ, đạp xe, đeo khẩu trang) kèm bảng đối chiếu khoa học theo quy chuẩn WHO và QCVN 05:2023/BTNMT.

![Co Van Thong Minh](screenshots/advisor_screen.png)

### 1.6. Xuất Ảnh Chia Sẻ Story & Mạng Xã Hội

Cho phép người dùng tạo các thẻ ảnh môi trường tùy biến chuẩn tỉ lệ 9:16 (Story/Reel) và 1:1 (Vuông) để chia sẻ trực tiếp lên mạng xã hội với chất lượng đồ họa sắc nét.

![Chia Se Story](screenshots/story_share_screen.png)

---

## 2. Kiến Trúc Hệ Thống (Clean Architecture)

Mã nguồn được phân bổ chặt chẽ theo mô hình Clean Architecture:

```
lib/
├── main.dart
└── src/
    ├── common/
    │   ├── constants/
    │   │   ├── colors.dart               # Bảng màu định chuẩn (UIColors)
    │   │   └── strings.dart              # Chuỗi văn bản mặc định
    │   ├── extensions/                   # Tiện ích mở rộng cho kiểu dữ liệu
    │   └── utils/
    │       ├── aqi_helper.dart           # Thuật toán nội suy tuyến tính US EPA AQI
    │       ├── geo_distance_helper.dart  # Tính khoảng cách mặt cầu Haversine
    │       └── heat_index_helper.dart    # Phương trình tính chỉ số nhiệt cảm nhận
    ├── core/
    │   ├── di/
    │   │   └── injection_container.dart  # Khởi tạo Dependency Injection (GetIt)
    │   ├── domain/
    │   │   └── entities/                 # Hợp đồng chuẩn BaseResult, BaseResponse
    │   ├── infrastructure/
    │   │   ├── configs/                  # Nạp cấu hình môi trường EnvConfig
    │   │   ├── datasources/
    │   │   │   ├── local/                # Bộ nhớ đệm LocalStorage (SharedPreferences)
    │   │   │   └── network/              # Giao tiếp HTTP client RestfulRequest
    │   │   └── services/                 # Dịch vụ phần cứng GPS LocationService
    │   └── presentation/                 # Widget giao diện dùng chung (AppText, AppIcon)
    ├── features/
    │   ├── advisor/                      # Tính năng cố vấn sức khỏe & hoạt động
    │   │   ├── domain/entities/          # AdvisorDecision, AdvisorEvidence, SafetyLevel
    │   │   └── presentation/             # AdvisorCubit, AdvisorModalSheet
    │   ├── air_quality/                  # Tính năng chất lượng không khí (Open-Meteo)
    │   │   ├── domain/                   # IAirQualityRepository, AirQualityEntity
    │   │   ├── infrastructure/           # AirQualityRepository, AirQualityModel, Paths
    │   │   └── presentation/             # AirQualityCubit, AQIGaugeWidget
    │   ├── details/                      # Chi tiết thời tiết & xu hướng 24 giờ
    │   │   ├── domain/                   # IDetailsRepository, DetailsEntity
    │   │   ├── infrastructure/           # DetailsRepository, DetailsModel, Paths
    │   │   └── presentation/             # DetailsCubit, TwentyFourHourDetailPage
    │   ├── explore/                      # Tin tức môi trường & tiện ích
    │   │   ├── domain/entities/          # UtilityItem, NewsItem
    │   │   └── presentation/             # ExplorePage, UtilityCard
    │   ├── home/                         # Màn hình Dashboard trung tâm
    │   │   ├── domain/entities/          # CityEntity
    │   │   └── presentation/             # HomeDashboardCubit, HomePage, Sheets
    │   ├── map/                          # Bản đồ đa tầng & vệ tinh NASA FIRMS
    │   │   ├── domain/                   # IMapRepository, INasaFirmsRepository
    │   │   │   └── entities/             # MapLayerType, StationEntity, VietnamProvince
    │   │   ├── infrastructure/           # MapRepository, NasaFirmsRepository
    │   │   │   ├── models/               # StationModel, ThermalHotspotModel
    │   │   │   └── paths/                # MapPaths, NasaFirmsPaths
    │   │   └── presentation/             # MapCubit, MapPage, MapSideControls
    │   └── story_share/                  # Tạo và xuất thẻ ảnh Story
    │       └── presentation/             # StoryPreviewPage, StoryCardView
    └── shared/
        ├── router/                       # Điều hướng GlobalKeyManager, RouterPath
        └── widgets/                      # Widget chia sẻ AppGlass, AppButton, AppTopToast
```

### Phân Định Trách Nhiệm Từng Tầng

- Tầng Domain: Chứa Interface của Repository, các Entity thuần túy và Enum định nghĩa luật nghiệp vụ. Hoàn toàn độc lập với các thư viện bên ngoài và giao diện người dùng.
- Tầng Infrastructure: Triển khai các phương thức Repository, xử lý gọi mạng qua RestfulRequest, đọc/ghi dữ liệu tạm vào LocalStorage, định nghĩa đường dẫn API và chuyển đổi dữ liệu thô (JSON/CSV) sang Model.
- Tầng Presentation: Sử dụng BLoC/Cubit để quản lý trạng thái giao diện, tiếp nhận dữ liệu từ Domain và kết xuất giao diện phản hồi linh hoạt.
- Tầng Core & Common: Cung cấp container phụ thuộc GetIt, nạp biến môi trường `.env`, bộ định vị phần cứng và các công cụ tính toán toán học dùng chung.

---

## 3. Hướng Dẫn Kỹ Thuật Về Các Phương Thức Tính Toán

Các phép tính toán trong ứng dụng đều được xử lý trực tiếp trên thiết bị di động của người dùng. Dưới đây là mô tả phương thức theo góc nhìn phát triển phần mềm (đầu vào, đầu ra và cách ứng dụng sử dụng):

### 3.1. Tính Toán Khoảng Cách Địa Lý (`GeoDistanceHelper`)

- Mục đích: Tính khoảng cách đường chim bay giữa hai tọa độ địa lý trên mặt cầu Trái Đất theo công thức Haversine (bán kính Trái Đất R = 6.371 km).
- Triển khai:
  - Tham số đầu vào: Vĩ độ và kinh độ của Điểm 1 (lat1, lon1) và Điểm 2 (lat2, lon2).
  - Phương thức: `GeoDistanceHelper.calculateDistanceKm(lat1, lon1, lat2, lon2)`.
  - Quy chuẩn làm tròn hiển thị:
    - Khoảng cách nhỏ hơn 10 km: Hiển thị 1 chữ số thập phân (ví dụ: "~3.4km").
    - Khoảng cách từ 10 km trở lên: Làm tròn về số nguyên gần nhất (ví dụ: "~25km", "~140km").
- Sử dụng trong app: Khi người dùng ghim một điểm bất kỳ trên bản đồ, hàm này được gọi để tìm trạm quan trắc gần nhất. Nếu khoảng cách vượt quá 35 km, ứng dụng sẽ duyệt danh sách `VietnamProvince.provinces` để tìm ra tỉnh thành Việt Nam gần nhất và hiển thị tên chuẩn hóa (ví dụ: "Điểm ghim (~4.2km từ Đà Nẵng)").

### 3.2. Tính Chỉ Số Nhiệt Cảm Nhận (`HeatIndexHelper`)

- Mục đích: Ước lượng mức nhiệt độ thực tế mà cơ thể người cảm nhận khi kết hợp giữa nhiệt độ không khí và độ ẩm tương đối.
- Triển khai:
  - Tham số đầu vào: Nhiệt độ môi trường tính theo độ C và độ ẩm tương đối (%).
  - Phương thức: `HeatIndexHelper.calculateHeatIndex(temperatureCelsius, humidity)`.
  - Thuật toán: Đổi nhiệt độ sang Fahrenheit, áp dụng phương trình đa thức hồi quy Rothfusz của NOAA/NWS, sau đó chuyển ngược kết quả về độ C.
  - Phân cấp mức độ nguy cơ:
    - Dưới 27 độ C: An toàn (Điểu kiện bình thường).
    - 27 đến 31 độ C: Cần thận trọng (Có thể mệt mỏi nếu vận động ngoài trời kéo dài).
    - 32 đến 40 độ C: Đặc biệt cẩn trọng (Nguy cơ say nắng, chuột rút).
    - Từ 41 độ C trở lên: Nguy hiểm (Nguy cơ kiệt sức vì nhiệt và sốc nhiệt cấp tính).
- Sử dụng trong app: Hiển thị trên thẻ thời tiết ở Dashboard và trang Chi tiết 24h kèm huy hiệu cảnh báo màu để người dùng chủ động phòng tránh sốc nhiệt trong những ngày nắng nóng đỉnh điểm.

### 3.3. Tính Chỉ Số Chất Lượng Không Khí (`AQIHelper`)

- Mục đích: Chuyển đổi nồng độ bụi mịn PM2.5 hoặc PM10 (đơn vị ug/m3) thành chỉ số chất lượng không khí US EPA AQI chuẩn quốc tế.
- Triển khai:
  - Tham số đầu vào: Nồng độ bụi mịn đo được (C).
  - Phương thức: `AQIHelper.calculateAqiFromPm25(pm25)` và `AQIHelper.calculateAqiFromPm10(pm10)`.
  - Thuật toán: Sử dụng công thức nội suy tuyến tính theo từng khoảng quy chuẩn:
    `I = [ (I_high - I_low) / (C_high - C_low) ] * (C - C_low) + I_low`
    trong đó C_low và C_high là ngưỡng nồng độ giới hạn dưới và trên, I_low và I_high là các mức điểm AQI tương ứng.
  - Phân cấp mức độ:
    - 0 - 50: Tốt (Xanh lá)
    - 51 - 100: Trung bình (Vàng)
    - 101 - 150: Kém cho nhóm nhạy cảm (Cam)
    - 151 - 200: Xấu (Đỏ)
    - 201 - 300: Rất xấu (Tím)
    - 301+: Nguy hại (Nâu thẫm)
- Sử dụng trong app: Dùng để kết xuất vòng đồng hồ đo AQI ở màn hình chính, quy định màu sắc cảnh báo toàn ứng dụng và làm dữ liệu đầu vào cho động cơ cố vấn sức khỏe.

### 3.4. Dữ Liệu Điểm Phát Xạ Nhiệt Vệ Tinh NASA FIRMS (`ThermalHotspotModel`)

- Mục đích: Xử lý và diễn giải dữ liệu bức xạ nhiệt hồng ngoại từ cảm biến VIIRS 375m trên vệ tinh NOAA-20 và NOAA-21.
- Triển khai:
  - Nhiệt độ phát xạ: Đổi nhiệt độ bức xạ kênh I4 từ Kelvin sang Celsius (`T_celsius = T_kelvin - 273.15`).
  - Công suất bức xạ nhiệt (FRP - tính bằng Megawatt):
    - FRP >= 20.0 MW: Điểm phát xạ nhiệt công suất cao.
    - FRP < 20.0 MW: Điểm phát xạ nhiệt tiêu chuẩn.
  - Phân loại theo địa hình: Đánh giá tọa độ điểm vệ tinh dựa trên vùng địa hình Việt Nam:
    - Vùng đồng bằng: Phân loại khách quan là điểm phát xạ nhiệt ở vùng đồng bằng.
    - Vùng cao / Đồi núi: Phân loại khách quan là điểm phát xạ nhiệt ở vùng cao.
  - Độ tin cậy cảm biến: Ánh xạ ký hiệu chất lượng ('h', 'n', 'l') tương ứng với 95%, 80%, và 50% độ tin cậy.
- Sử dụng trong app: Dùng để vẽ các đốm nhiệt phát sáng trên bản đồ, kết hợp thẻ thông tin xem trước cho biết cường độ bức xạ, thời gian vệ tinh quét qua và ngữ cảnh địa hình.

### 3.5. Đánh Giá Nguy Cơ Ngập Úng Đô Thị

- Mục đích: Cảnh báo nguy cơ ngập úng cục bộ tại các đô thị lớn khi có mưa lớn.
- Triển khai: Kết hợp lượng mưa thời gian thực (cường độ mưa >= 20.0 mm/h) với dữ liệu các điểm trũng thấp, điểm nghẽn thoát nước trong lịch sử (`FloodBlackspot.vietnamBlackspots`).
- Sử dụng trong app: Bật cờ cảnh báo `isHighFloodRisk` trên thẻ trạm quan trắc và hiển thị cảnh báo đỏ trên lớp bản đồ Ngập úng.

---

## 4. Hướng Dẫn Cài Đặt & Chạy Ứng Dụng Cho Lập Trình Viên

### 4.1. Yêu Cầu Môi Trường

- Flutter SDK: Phiên bản từ 3.22.0 trở lên (tương thích tốt với Flutter 3.44+).
- Dart SDK: Phiên bản từ 3.12.0 trở lên.
- Đã cài đặt Git trên máy tính.
- Android Studio (có Android SDK) hoặc Visual Studio Code.
- Xcode (từ phiên bản 15 trở lên, nếu muốn chạy trên iOS/macOS).

### 4.2. Cấu Hình Biến Môi Trường

Tạo file `.env` tại thư mục gốc của dự án:

```bash
# Trên Windows PowerShell:
Copy-Item .env_example .env

# Trên macOS / Linux:
cp .env_example .env
```

Kiểm tra nội dung file `.env` để bảo đảm khóa NASA FIRMS hợp lệ:

```properties
APP_NAME=EnviVN
APP_ENV=development
OPEN_METEO_WEATHER_BASE_URL=https://api.open-meteo.com
OPEN_METEO_AIR_QUALITY_BASE_URL=https://air-quality-api.open-meteo.com
OPEN_METEO_GEOCODING_BASE_URL=https://geocoding-api.open-meteo.com
OSM_TILE_URL=https://tile.openstreetmap.org/{z}/{x}/{y}.png
MAP_USER_AGENT=com.envivn.envivn
NASA_FIRMS_BASE_URL=https://firms.modaps.eosdis.nasa.gov/api
NASA_FIRMS_MAP_KEY= #lấy mã tại: https://firms.modaps.eosdis.nasa.gov/api/map_key/
```

### 4.3. Chạy Trên Visual Studio Code (VS Code)

1. Cài extension Flutter và Dart chính thức từ Marketplace.
2. Mở thư mục dự án `EnviVN` bằng VS Code.
3. Mở Terminal tích hợp và tải thư viện:
   ```bash
   flutter pub get
   ```
4. Chọn thiết bị đích ở thanh trạng thái dưới cùng (điện thoại cắm cáp, máy ảo Android hoặc iOS Simulator).
5. Nhấn F5 hoặc gõ lệnh:
   ```bash
   flutter run
   ```

### 4.4. Chạy Trên Android Studio

1. Cài đặt plugin Flutter (Settings -> Plugins -> Tìm "Flutter").
2. Mở thư mục dự án `EnviVN`.
3. Bấm "Pub get" ở thanh thông báo phía trên file `pubspec.yaml`.
4. Chọn thiết bị máy ảo hoặc điện thoại thật ở thanh công cụ.
5. Nhấn nút Run (tam giác xanh) hoặc phím tắt Shift + F10.

### 4.5. Chạy Trên Xcode & iOS (Yêu Cầu macOS)

1. Kiểm tra công cụ CocoaPods:
   ```bash
   pod --version
   ```
2. Cài đặt Pod dependencies:
   ```bash
   cd ios
   pod install
   cd ..
   ```
3. Mở file workspace trong Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
4. Cấu hình Signing & Capabilities với tài khoản Apple Developer Team của bạn.
5. Chạy ứng dụng trên iPhone hoặc Simulator:
   ```bash
   flutter run -d ios
   ```

### 4.6. Build Bản Android APK Để Cài Đặt Trực Tiếp

Để tạo file cài APK chạy ngay trên điện thoại (không cần xuất bản lên Store):

- Bản tối ưu cho chip 64-bit (Khuyên dùng, dung lượng nhẹ ~23MB):

  ```bash
  flutter build apk --split-per-abi
  ```

  File xuất ra tại: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

- Bản Fat APK dùng chung cho mọi dòng máy (~59MB):
  ```bash
  flutter build apk --release
  ```
  File xuất ra tại: `build/app/outputs/flutter-apk/app-release.apk`

Cài trực tiếp vào điện thoại qua cáp ADB:

```bash
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## 5. Kiểm Thử Tự Động & Đảm Bảo Chất Lượng

Dự án đi kèm bộ 30 bài kiểm thử tự động (Unit Test & Widget Test):

- Kiểm tra phân tích tĩnh mã nguồn:

  ```bash
  flutter analyze
  ```

  Kết quả chuẩn: 0 lỗi, 0 cảnh báo.

- Chạy toàn bộ test suites:
  ```bash
  flutter test
  ```
  Các phạm vi được kiểm thử bao gồm:
  - Phân tích cú pháp dữ liệu CSV từ vệ tinh NASA NOAA-20 VIIRS và cơ chế lưu đệm TTL 15 phút.
  - Cơ chế khử trùng lặp yêu cầu mạng (deduplication) và tự phục hồi khi gặp lỗi giới hạn lượt gọi HTTP 429.
  - Phép tính khoảng cách mặt cầu Haversine và thuật toán ghim tìm tỉnh thành gần nhất.
  - Tính toán chỉ số nhiệt cảm nhận (Heat Index) và phân loại cấp độ rủi ro.
  - Phép nội suy chất lượng không khí chuẩn US EPA AQI.
  - Kiểm tra giao diện chống tràn điểm ảnh (overflow) trên màn hình kích thước hẹp (320px).

---

## 6. Nguồn Dữ Liệu & Bản Quyền Sử Dụng

- Dữ liệu dự báo thời tiết và chất lượng không khí được cung cấp bởi Open-Meteo API.
- Dữ liệu điểm phát xạ nhiệt vệ tinh thời gian thực được cung cấp bởi NASA FIRMS (NOAA-20 và NOAA-21 VIIRS Near Real-Time).
- Bản đồ nền do cộng đồng OpenStreetMap đóng góp.
