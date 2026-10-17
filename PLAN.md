# KẾ HOẠCH NÂNG CẤP DỰ ÁN ENVIVN (NO-BACKEND ARCHITECTURE)
> **EnviVN** - Nền tảng Theo dõi Môi trường & Thời tiết Cá nhân hóa Thông minh tại Việt Nam.  
> **Kiến trúc định hướng**: **100% Client-Side / Serverless** — Khai thác hệ sinh thái Public API mở, xử lý logic & bộ nhớ đệm hoàn toàn trên thiết bị (On-Device Storage & Compute).

---

## 1. TỔNG QUAN HIỆN TRẠNG & ĐỊNH HƯỚNG TỐI ƯU

### 1.1. Nền tảng sẵn có (Core Strengths)
- **Kiến trúc phần mềm chuẩn mực**: Clean Architecture (Domain - Infrastructure - Presentation), State Management `flutter_bloc`, Dependency Injection `get_it`.
- **Giao diện hiện đại (Modern Liquid Glass)**: Thiết kế Glassmorphism chuẩn phong cách Apple Dark Mode (`liquid_glass_renderer`, `AppGlass`).
- **Dữ liệu thời tiết & chất lượng không khí mở**: Tích hợp Open-Meteo API (Forecast & Air Quality), không tốn phí bản quyền.
- **Bản đồ tương tác**: Tích hợp `flutter_map` (OpenStreetMap Dark Tiles) hiển thị vòng nhiệt ô nhiễm và trạm đo.
- **Biểu đồ phân tích**: Trực quan hóa dữ liệu 24h & 7 ngày bằng `fl_chart`.

### 1.2. Chiến lược No-Backend (Tại sao và Như thế nào?)
- **Mục tiêu**: Tối giản tối đa chi phí vận hành (0đ chi phí máy chủ), không cần bảo trì Backend, dễ dàng clone và build trực tiếp từ GitHub.
- **Nguyên lý thực thi**:
    1. Sử dụng trực tiếp các REST API công cộng (Public APIs) với cơ chế parse dữ liệu streaming/caching thông minh.
    2. Toàn bộ logic cá nhân hóa, lọc chỉ số, thuật toán tính nguy cơ và ghi nhớ tùy chọn được lưu trữ bằng Database cục bộ (Hive / SharedPreferences).
    3. Chuyển đổi các tác vụ phụ thuộc server (như crowdsourcing, server-push notification) sang các cơ chế Local Notifications, Client-Side Geocoding và Local Heuristics.

---

## 2. HỆ THỐNG PUBLIC API ĐƯỢC TÍCH HỢP

| Tên nguồn API | Mục đích sử dụng | Xác thực / Chi phí | Gói tích hợp |
| :--- | :--- | :--- | :--- |
| **Open-Meteo Weather API** | Dự báo nhiệt độ, độ ẩm, gió, UV, lượng mưa từng giờ/ngày | Miễn phí, Không cần Key | `http` / `dio` |
| **Open-Meteo Air Quality API** | Chỉ số AQI (US & VN), nồng độ bụi PM2.5, PM10, $NO_2$, $O_3$, $SO_2$ | Miễn phí, Không cần Key | `http` / `dio` |
| **Open-Meteo Geocoding API** | Tìm kiếm địa chỉ, xã/phường/quận/huyện trên 63 tỉnh thành | Miễn phí, Không cần Key | `http` / `dio` |
| **Google Gemini Flash API** | Trợ lý ảo AI tư vấn sức khỏe & giải thích môi trường | Free Tier (Google AI Studio) | `google_generative_ai` |
| **WAQI / OpenAQ API** | Mạng lưới trạm quan trắc thực tế (Đại sứ quán, Tổng cục Môi trường) | Miễn phí (Đăng ký Token công khai) | `dio` |
| **NASA FIRMS API** | Điểm vệ tinh đốt rơm rạ / cháy sinh khối thời gian thực | Miễn phí MAP_KEY | `dio` / GeoJSON |

---

## 3. CÁC TRỤ CỘT NÂNG CẤP CHI TIẾT (CLIENT-ONLY)

```
                      ┌─────────────────────────────────────────┐
                      │        ENVIVN (CLIENT-ONLY ENGINE)      │
                      └────────────────────┬────────────────────┘
                                           │
         ┌───────────────────┬─────────────┴───────┬───────────────────┐
         │                   │                     │                   │
┌────────┴────────┐ ┌────────┴────────┐   ┌────────┴────────┐ ┌────────┴────────┐
│  1. TRỢ LÝ AI   │ │  2. SỨC KHỎE    │   │  3. BẢN ĐỒ VỆ   │ │  4. NỘI NGOẠI     │
│  & LOCAL PROFILE│ │  & ĐIỂM NÓNG VN │   │  TINH & TRẠM ĐO │ │  WIDGET & SHARE │
└─────────────────┘ └─────────────────┘   └─────────────────┘ └─────────────────┘
```

---

### TRỤ CỘT 1: TRỢ LÝ AI & HỒ SƠ CÁ NHÂN HÓA NỘI BỘ

#### 1.1. Kích hoạt Trợ lý Môi trường EnviBot (Google Gemini Flash)
- **Vị trí**: Kích hoạt khi bấm nút `Trợ lý` trên thanh điều hướng `LiquidGlassBottomBar`.
- **Cơ chế Client-Direct**:
    - Tích hợp trực tiếp thông qua SDK `google_generative_ai`.
    - Quản lý API Key an toàn qua biến môi trường Dart (`--dart-define=GEMINI_API_KEY=your_key`).
- **Context Injection thông minh (Prompt Engineering)**:
    - Khi người dùng gửi câu hỏi, Flutter tự động đóng gói ngữ cảnh môi trường hiện tại vào System Prompt:
        - Vị trí hiện tại, chỉ số AQI thực tế, nồng độ PM2.5, UV, nhiệt độ, độ ẩm.
        - Hồ sơ sức khỏe của người dùng lưu trên máy (ví dụ: *Viêm xoang mãn tính, nhạy cảm với bụi mịn*).
    - Tích hợp gợi ý nhanh các câu hỏi mẫu:
        - *"Hôm nay có nên chạy bộ ngoài trời không?"*
        - *"Nên mở cửa thông gió vào khung giờ nào sạch nhất?"*
        - *"Giải thích hiện tượng nghịch nhiệt hôm nay."*

#### 1.2. Màn hình Cài đặt & Hồ sơ Sức khỏe Cục bộ (Local Health Profile)
- **Vị trí**: Thay thế tab `LocationPermissionPage` hiện tại thành `SettingsPage`.
- **Lưu trữ dữ liệu**: Sử dụng `SharedPreferences` hoặc `Hive` để lưu trữ 100% trên thiết bị:
    - **Nhóm đối tượng**: *Người khỏe mạnh, Trẻ em, Người cao tuổi, Bệnh hô hấp (xoang/hen), Bệnh tim mạch, Vận động viên*.
    - **Quy chuẩn AQI hiển thị**: Chuyển đổi qua lại giữa **US-AQI (EPA)** và **VN-AQI** (QCVN 05:2023/BTNMT).
    - **Ngưỡng nhạy cảm cá nhân**: Tự động hạ thấp ngưỡng cảnh báo nguy hiểm trong `AQIHelper` khi người dùng thuộc nhóm nguy cơ cao (AQI > 75 đã bắt đầu hiển thị cảnh báo đỏ thay vì đợi đến 150).
    - **Đơn vị hiển thị**: °C/°F, km/h hoặc m/s.

#### 1.3. Tìm kiếm Tự do 63 Tỉnh Thành & Địa điểm Yêu thích (Favorites)
- **Nguồn cấp**: Open-Meteo Geocoding API (`https://geocoding-api.open-meteo.com/v1/search`).
- **Trải nghiệm**:
    - Gõ debounce 400ms: Tự động gợi ý thị xã, huyện, quận, phường trên khắp Việt Nam.
    - Thêm chức năng **Lưu địa điểm yêu thích** (Lưu tọa độ + tên địa phương vào Local Storage): *Nhà riêng, Cơ quan, Nhà ông bà*. Người dùng có thể trượt nhanh giữa các địa điểm yêu thích trên AppBar.

---

### TRỤ CỘT 2: GIẢI QUYẾT ĐẶC THÙ MÔI TRƯỜNG VIỆT NAM (KHÔNG CẦN BE)

#### 2.1. Cảnh báo Điểm nóng Đốt rơm rạ Mùa vụ (NASA FIRMS)
- **Vấn đề**: Tình trạng đốt rơm rạ sau mùa gặt ở ngoại thành Hà Nội và ĐBSCL gây ô nhiễm diện rộng cục bộ.
- **Giải pháp No-BE**:
    - Gọi trực tiếp API mở từ **NASA FIRMS (Fire Information for Resource Management System)** lấy dữ liệu phát hiện nhiệt từ vệ tinh VIIRS/MODIS trong 24h qua cho khu vực Việt Nam (`area: 8.0,102.0,24.0,110.0`).
    - Render các điểm phát thải nhiệt độ cao dưới dạng các đốm phát sáng màu cam/đỏ trên bản đồ `flutter_map`.
    - Kết hợp vector hướng gió từ Open-Meteo để trực quan hóa luồng khói bụi hướng về khu đô thị.

#### 2.2. Thẻ Cảnh báo Sốc nhiệt (Heat Index) & Khung giờ Nắng gắt (UV Peak)
- **Tính toán On-Device**:
    - Tính toán chỉ số nhiệt cảm nhận (**Heat Index / Steadman Formula**) dựa trên cặp thông số Nhiệt độ & Độ ẩm tương đối từ Open-Meteo.
    - Hiển thị mức độ rủi ro sốc nhiệt (*An toàn $\rightarrow$ Thận trọng $\rightarrow$ Nguy hiểm $\rightarrow$ Cực đoan*).
    - Tính toán khung giờ có chỉ số tia cực tím UV > 6 (Khung giờ tránh nắng) và đưa ra số phút tối đa nên tiếp xúc trực tiếp dưới ánh nắng trước khi da bắt đầu bị tổn thương.

#### 2.3. Cảnh báo Nguy cơ Ngập úng Đô thị (Client-Side Threshold & Hotspot Mapping)
- **Thay thế cho API ngập thời gian thực (vốn không tồn tại API public chuẩn)**:
    - **Dữ liệu điểm đen tĩnh (Local GeoJSON/JSON Assets)**: Tổng hợp sẵn danh sách tọa độ các tuyến đường/nút giao ngập lụt kinh niên tại các đô thị lớn (Hà Nội, TP.HCM, Đà Nẵng).
    - **Cơ chế kích hoạt thông minh**:
        - Khi lượng mưa dự báo hoặc thực đo trong 1-3 giờ của Open-Meteo vượt ngưỡng **35 - 40mm/h**, ứng dụng sẽ tự động kích hoạt **"Thẻ cảnh báo nguy cơ ngập úng"**.
        - Hiển thị các điểm đen ngập gần vị trí người dùng nhất trên bản đồ với bán kính 5km.

---

### TRỤ CỘT 3: TƯƠNG TÁC, LAN TỎA & TIỆN ÍCH HỆ ĐIỀU HÀNH

#### 3.1. Bộ Trạm Quan trắc Cảm biến Mở (Thay thế tính năng Báo cáo Cộng đồng)
- **Lý do thay thế**: Tính năng crowdsourcing (người dùng up ảnh điểm rác/cháy) yêu cầu Cloud Database & Auth. Thay vì dùng backend, ứng dụng khai thác **mạng lưới trạm đo thực tế mở**.
- **Giải pháp**:
    - Tích hợp **WAQI API (World Air Quality Index)** hoặc **OpenAQ**.
    - Tải danh sách trạm quan trắc mặt đất thực tế tại Việt Nam (các trạm thuộc Đại sứ quán, Tổng cục Môi trường, mạng lưới PAM Air mở).
    - Cho phép người dùng chuyển đổi trên bản đồ giữa: *Dữ liệu mô hình vệ tinh nội suy (Open-Meteo)* và *Dữ liệu cảm biến mặt đất thực tế (WAQI)*.

#### 3.2. Tạo Thẻ ảnh Story Liquid Glass Chia sẻ Mạng Xã hội
- **Mục tiêu**: Tăng tính viral cho dự án trên mạng xã hội mà không tốn chi phí.
- **Triển khai kỹ thuật**:
    - Sử dụng widget `RepaintBoundary` hoặc thư viện `screenshot` để render UI sang định dạng hình ảnh PNG chất lượng cao (tỷ lệ Story 9:16 hoặc Feed 1:1).
    - Thiết kế template Liquid Glass tuyệt đẹp hiển thị: Địa danh, chỉ số AQI kèm viền phát sáng, nhiệt độ, chất lượng không khí kèm câu trích dẫn nhắc nhở sức khỏe.
    - Gọi package `share_plus` để mở bảng chia sẻ trực tiếp sang Facebook Story, Instagram, Zalo.

#### 3.3. Tiện ích Màn hình chính (Home Screen Widget)
- **Kỹ thuật**: Sử dụng package `home_widget` kết hợp Swift WidgetKit (iOS) và Glance/RemoteViews (Android).
- **Phân loại**:
    - **Small (2x2)**: Vòng tròn Glassmorphism hiển thị điểm AQI, icon thời tiết và nhiệt độ.
    - **Medium (4x2)**: Thêm thanh nồng độ PM2.5, chỉ số UV và khuyến cáo hành động (Ví dụ: *Cần đeo khẩu trang N95*).
- **Chu kỳ cập nhật**: Thiết bị tự động lên lịch làm mới dữ liệu nền mỗi 30 - 60 phút trực tiếp từ Open-Meteo API.

#### 3.4. Thông báo Cục bộ Định kỳ Buổi sáng (Scheduled Local Notifications)
- **Kỹ thuật**: Sử dụng package `flutter_local_notifications` kết hợp múi giờ `timezone`.
- **Cơ chế No-BE**:
    - Lập lịch cố định vào **06:30 sáng** mỗi ngày trên thiết bị.
    - Khi thông báo kích hoạt, app đọc dữ liệu đệm thời tiết ngày hôm đó và hiển thị tóm tắt:
      > 🌤️ **Chào buổi sáng Hà Nội!**  
      > AQI hôm nay: **158 (Kém)** • Bụi mịn PM2.5 cao.  
      > Nhiệt độ 27°C, nắng hanh. Trưa nay UV đạt đỉnh 9.5.  
      > 👉 *Khuyến nghị: Nhớ mang khẩu trang lọc bụi trước khi ra đường!*

---

## 4. BẢNG DANH MỤC THƯ VIỆN BỔ SUNG (DEPENDENCIES)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Quản trị trạng thái & Kiến trúc
  flutter_bloc: ^8.1.6
  get_it: ^7.7.0
  equatable: ^2.0.5

  # Mạng & API Public
  dio: ^5.7.0
  google_generative_ai: ^0.4.6 # Trợ lý AI Gemini

  # Bản đồ & Đồ họa
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  fl_chart: ^0.69.0

  # Lưu trữ cục bộ (Local Storage)
  shared_preferences: ^2.3.2
  hive_flutter: ^1.1.0 # Cache dữ liệu trạm & Offline history

  # Tiện ích hệ thống & Mạng xã hội
  home_widget: ^0.7.0 # Android/iOS Widgets
  flutter_local_notifications: ^19.0.0 # Báo thức sáng & Cảnh báo cục bộ
  timezone: ^0.10.0
  screenshot: ^3.0.0 # Chụp ảnh Glass Card
  share_plus: ^10.1.4 # Chia sẻ Story
```

---

## 5. CẤU TRÚC THƯ MỤC DỰ ÁN MỞ RỘNG (CLEAN ARCHITECTURE)

```
lib/
├── main.dart
├── injection_container.dart       # Cấu hình GetIt DI
│
├── core/
│   ├── config/env_config.dart     # Quản lý Gemini API Key, WAQI Token
│   ├── constants/flooding_blackspots.dart # Tọa độ điểm đen ngập lụt cục bộ
│   ├── theme/liquid_glass_theme.dart
│   └── utils/
│       ├── aqi_calculator.dart    # Chuyển đổi US-AQI & VN-AQI
│       └── heat_index_calculator.dart
│
└── src/features/
    ├── air_quality/               # Open-Meteo Air Quality & AQI logic
    ├── weather/                   # Open-Meteo Forecast
    │
    ├── ai_advisor/                # [MỚI] Trợ lý ảo AI Môi trường
    │   ├── domain/repositories/ai_advisor_repository.dart
    │   ├── infrastructure/repositories/gemini_advisor_repository_impl.dart
    │   └── presentation/
    │       ├── cubits/ai_advisor_cubit.dart
    │       └── widgets/ai_advisor_bottom_sheet.dart
    │
    ├── settings/                  # [MỚI] Màn hình Cài đặt & Hồ sơ sức khỏe
    │   ├── domain/entities/user_profile_entity.dart
    │   ├── infrastructure/datasources/settings_local_data_source.dart
    │   └── presentation/pages/settings_page.dart
    │
    ├── map_layers/                # [MỚI] Các tầng bản đồ vệ tinh & Trạm đo
    │   ├── domain/entities/fire_point_entity.dart
    │   ├── infrastructure/repositories/nasa_firms_repository_impl.dart
    │   ├── infrastructure/repositories/waqi_station_repository_impl.dart
    │   └── presentation/widgets/map_layer_toggles.dart
    │
    ├── story_share/               # [MỚI] Chụp ảnh & Chia sẻ Glass Story Card
    │   └── presentation/widgets/shareable_glass_story.dart
    │
    └── system_integration/        # [MỚI] Tích hợp HĐH (Widgets & Notification)
        ├── notification_service.dart
        └── widget_sync_service.dart
```

---

## 6. LỘ TRÌNH THỰC THI 3 GIAI ĐOẠN (ACTIONABLE ROADMAP)

```
Tuần 1: HOÀN THIỆN CORE            Tuần 2: NÂNG TẦM DỮ LIỆU          Tuần 3: VIRAL & TIỆN ÍCH
┌───────────────────────────┐      ┌───────────────────────────┐     ┌───────────────────────────┐
│ • Tích hợp Gemini Flash   │      │ • Thêm NASA FIRMS (Điểm   │     │ • Tích hợp Home Widget    │
│ • Hoàn thiện SettingsPage │ ───> │   nóng đốt rơm rạ)        │ ──> │ • Local Notification 6:30 │
│ • Hồ sơ sức khỏe cá nhân  │      │ • Thêm trạm đo thực WAQI  │     │ • Xuất ảnh Story 9:16     │
│ • Geocoding 63 tỉnh thành │      │ • Logic Cảnh báo ngập úng │     │ • Đóng gói README GitHub  │
└───────────────────────────┘      └───────────────────────────┘     └───────────────────────────┘
```

### Giai đoạn 1: Lấp đầy khoảng trống UI & Kích hoạt Trí tuệ Nhân tạo (Tuần 1)
1. **Trợ lý AI Gemini**:
    - Tạo `GeminiAdvisorRepositoryImpl` kết nối `google_generative_ai`.
    - Viết giao diện Glassmorphism Bottom Sheet khi ấn nút "Trợ lý" ở thanh bar.
2. **Settings & Hồ sơ Sức khỏe**:
    - Xây dựng `SettingsPage` thay thế tab cấp quyền vị trí.
    - Lưu cấu hình độ nhạy AQI và hồ sơ bệnh hô hấp vào `SharedPreferences`.
3. **Mở rộng Địa điểm**:
    - Tích hợp Open-Meteo Geocoding tìm kiếm địa danh tức thì, hỗ trợ lưu danh sách Favorites.

### Giai đoạn 2: Tăng cường Dữ liệu Thực địa & Tính năng Bản địa (Tuần 2)
1. **Tầng Vệ tinh Điểm cháy NASA FIRMS**:
    - Gọi API FIRMS lấy tọa độ điểm cháy sinh khối, thêm Layer Marker trên `flutter_map`.
2. **Tầng Trạm Quan trắc Thực tế WAQI**:
    - Bổ sung trạm đo cảm biến thực tế, cho phép chuyển đổi chế độ xem giữa *Nội suy mô hình* và *Đo lường thực tế*.
3. **Cảnh báo Sốc nhiệt & Ngập úng**:
    - Cài đặt thuật toán Heat Index và liên kết danh sách điểm đen ngập lụt khi lượng mưa vượt ngưỡng.

### Giai đoạn 3: Giữ chân Người dùng, Chia sẻ Mạng Xã hội & Showcase GitHub (Tuần 3)
1. **Home Screen Widget**:
    - Cấu hình tiện ích đồng bộ thông số thời tiết và màu sắc AQI ra màn hình chính điện thoại.
2. **Thông báo Chào buổi sáng**:
    - Lập lịch thông báo định kỳ 06:30 bằng `flutter_local_notifications`.
3. **Tạo ảnh Story Liquid Glass**:
    - Dùng `screenshot` và `share_plus` hoàn thiện tính năng chia sẻ bảng tin 1 chạm.
4. **Chuẩn hóa Repository GitHub**:
    - Thiết kế ảnh Demo GIF chuyển động, kiến trúc thư mục, hướng dẫn lấy API key trong `README.md`.