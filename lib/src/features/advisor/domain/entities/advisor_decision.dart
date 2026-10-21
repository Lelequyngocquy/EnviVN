import 'safety_level.dart';

enum AdvisorDecision {
  runningIdeal(
    level: SafetyLevel.safe,
    headline: 'Thời điểm vàng để chạy bộ & tập thể thao',
    explanation:
        'Chỉ số không khí rất trong lành và thời tiết thuận lợi, dung tích phổi hấp thụ oxy tối ưu mà không tích tụ độc tố.',
    tips: [
      'Khởi động kỹ 5-10 phút trước khi tăng tốc',
      'Uống đủ 200-300ml nước trước và sau buổi chạy',
      'Tận dụng các cung đường nhiều cây xanh hoặc công viên',
    ],
    alternativeHour: null,
  ),
  runningCautious(
    level: SafetyLevel.caution,
    headline: 'Có thể chạy nhẹ, tránh bài tập cường độ quá cao',
    explanation:
        'Nồng độ bụi mịn ở mức trung bình. Người khỏe mạnh có thể chạy nhưng nên giảm bớt cự ly hoặc giữ nhịp tim ổn định.',
    tips: [
      'Giảm 20-30% cường độ tập luyện so với thường ngày',
      'Ưu tiên chạy bộ trong khung giờ sáng sớm hoặc cuối chiều mát',
      'Đổi sang chạy trên máy trong nhà nếu bắt đầu cảm thấy khô rát họng',
    ],
    alternativeHour: '06:00 - 07:30 sáng hoặc 17:30 - 19:00',
  ),
  runningHeatOrUvRisk(
    level: SafetyLevel.warning,
    headline: 'Nguy cơ sốc nhiệt và tổn thương da do tia cực tím',
    explanation:
        'Nhiệt độ môi trường hoặc bức xạ UV cao quá mức an toàn, dễ gây mất nước, chuột rút và kiệt sức do nhiệt.',
    tips: [
      'Chuyển sang tập luyện trong phòng gym hoặc không gian râm mát',
      'Nếu bắt buộc ra ngoài, bôi kem chống nắng SPF 50+ và đội mũ',
      'Bổ sung nước điện giải (Oresol) liên tục từng ngụm nhỏ',
    ],
    alternativeHour: 'Sau 17:30 khi mặt trời đã lặn',
  ),
  runningSevereAirDanger(
    level: SafetyLevel.danger,
    headline: 'Không nên chạy ngoài trời - Nguy hại cho tim & phổi',
    explanation:
        'Chỉ số ô nhiễm AQI và bụi mịn PM2.5 ở mức có hại. Khi chạy bộ, lưu lượng thở tăng gấp 4-8 lần, đưa lượng lớn bụi siêu mịn thâm nhập thẳng vào phế nang và máu.',
    tips: [
      'Tập cardio, yoga hoặc chạy máy hoàn toàn trong phòng kín',
      'Bật máy lọc không khí ở chế độ tăng cường (Turbo/Auto)',
      'Đóng kín cửa sổ hướng mặt đường chính',
    ],
    alternativeHour: 'Chờ chất lượng không khí cải thiện sau 24h tới',
  ),
  runningSensitiveWarning(
    level: SafetyLevel.warning,
    headline: 'Nhóm nhạy cảm (xoang, hen suyễn) nên tập trong nhà',
    explanation:
        'Chất lượng không khí vượt ngưỡng chịu đựng an toàn đối với hệ hô hấp nhạy cảm, dễ khởi phát cơn khó thở hoặc kích ứng niêm mạc.',
    tips: [
      'Duy trì tập luyện nhẹ nhàng trong phòng kín có máy lọc khí',
      'Chuẩn bị sẵn ống hít hoặc thuốc xịt mũi được bác sĩ chỉ định',
      'Theo dõi sát sao các triệu chứng ho, tức ngực',
    ],
    alternativeHour: null,
  ),
  runningRainWarning(
    level: SafetyLevel.warning,
    headline: 'Không nên chạy ngoài trời khi trời đang mưa',
    explanation:
        'Mặt đường trơn trượt làm tăng nguy cơ ngã chấn thương. Nước mưa ngấm vào cơ thể khi thân nhiệt cao dễ gây hạ thân nhiệt và cảm lạnh đột ngột.',
    tips: [
      'Không chạy bộ ngoài trời khi mưa để tránh trơn ngã và cảm lạnh',
      'Chuyển sang chạy máy trong nhà, tập cardio hoặc các bài giãn cơ yoga',
      'Nếu đang chạy ngoài đường, tìm nơi trú mưa an toàn, tuyệt đối không trú dưới gốc cây to tránh sét',
      'Lau khô đầu tóc và thay quần áo khô ấm ngay sau khi về nhà',
    ],
    alternativeHour: 'Chờ sau khi tạnh mưa và mặt đường khô ráo',
  ),

  ventilationOptimal(
    level: SafetyLevel.safe,
    headline: 'Nên mở toang cửa để đón không khí tươi mới',
    explanation:
        'Không khí bên ngoài sạch và thoáng, việc thông gió giúp giảm nồng độ khí CO2 và mùi ẩm mốc trong nhà.',
    tips: [
      'Mở đồng thời các cửa sổ đối diện nhau để tạo luồng gió đối lưu tự nhiên',
      'Thời gian mở lý tưởng từ 20 đến 45 phút',
      'Tranh thủ phơi chăn màn hoặc quần áo ra ban công',
    ],
    alternativeHour: null,
  ),
  ventilationBriefOnly(
    level: SafetyLevel.caution,
    headline: 'Chỉ nên mở hé cửa trong khoảng 10 - 15 phút',
    explanation:
        'Mức độ bụi lơ lửng ngoài trời ở ngưỡng trung bình, mở cửa quá lâu sẽ khiến bụi tích tụ vào rèm cửa và nội thất.',
    tips: [
      'Mở cửa sổ lấy gió thoáng trong 10-15 phút rồi đóng kín lại',
      'Bật quạt hút gió hoặc quạt thông gió nhà vệ sinh/bếp',
      'Bật máy lọc không khí ngay sau khi đóng cửa sổ',
    ],
    alternativeHour: '09:30 - 11:00 (khi nắng lên làm tan sương mù bụi)',
  ),
  ventilationKeepClosed(
    level: SafetyLevel.danger,
    headline: 'Đóng chặt cửa sổ & Bật máy lọc không khí',
    explanation:
        'Không khí bên ngoài ô nhiễm nghiêm trọng. Mở cửa sổ lúc này sẽ biến căn nhà thành bẫy giữ bụi mịn PM2.5 độc hại.',
    tips: [
      'Đóng kín toàn bộ cửa sổ, cửa ban công và ô thoáng gió',
      'Bật máy lọc không khí công suất cao có màng lọc HEPA',
      'Lau ẩm bề mặt sàn và bàn ghế thay vì quét khô',
    ],
    alternativeHour: 'Chờ sau cơn mưa hoặc khi hướng gió đổi sạch hơn',
  ),

  childrenSafeToGo(
    level: SafetyLevel.safe,
    headline: 'Thời điểm rất tốt để trẻ em & người già vận động ngoài trời',
    explanation:
        'Chỉ số môi trường xanh sạch và an toàn cho sự phát triển của phổi trẻ nhỏ cũng như hệ hô hấp người lớn tuổi.',
    tips: [
      'Khuyến khích trẻ tham gia các hoạt động thể chất tự nhiên',
      'Mang theo bình nước cá nhân để bổ sung nước thường xuyên',
      'Người cao tuổi có thể đi dạo thư giãn 30-45 phút',
    ],
    alternativeHour: null,
  ),
  childrenNeedCaution(
    level: SafetyLevel.caution,
    headline: 'Có thể ra ngoài nhưng cần theo dõi sát thời gian',
    explanation:
        'Chỉ số môi trường ở mức vừa phải, trẻ em hoặc người già có thể vui chơi trong thời gian ngắn dưới bóng râm.',
    tips: [
      'Giới hạn thời gian hoạt động ngoài trời trong khoảng 30-45 phút',
      'Đội mũ rộng vành và che chắn vùng gáy cho trẻ',
      'Rửa sạch tay chân, nhỏ mắt và súc họng sau khi vào nhà',
    ],
    alternativeHour: 'Khung giờ sáng sớm trước 08:30',
  ),
  childrenStayIndoorDanger(
    level: SafetyLevel.danger,
    headline: 'Tuyệt đối giữ trẻ nhỏ và người cao tuổi trong nhà',
    explanation:
        'Hệ miễn dịch và phế quản của trẻ em/người già chưa hoàn thiện hoặc đã suy giảm, hấp thụ nồng độ PM2.5 cao dễ dẫn đến viêm phế quản và viêm phổi cấp tính.',
    tips: [
      'Tạo các trò chơi giải trí, đọc sách hoặc vận động nhẹ trong nhà',
      'Đảm bảo không gian sinh hoạt kín và có không khí sạch',
      'Bổ sung nhiều nước ấm, hoa quả giàu vitamin C để tăng đề kháng',
    ],
    alternativeHour: 'Chờ chất lượng không khí cải thiện về mức Xanh (Tốt)',
  ),
  childrenRainWarning(
    level: SafetyLevel.warning,
    headline: 'Không nên cho trẻ em & người cao tuổi ra ngoài trời mưa',
    explanation:
        'Thời tiết mưa ẩm dễ làm trẻ nhỏ bị nhiễm lạnh đường hô hấp, trong khi người cao tuổi có nguy cơ trơn trượt té ngã nguy hiểm.',
    tips: [
      'Giữ trẻ em và người già sinh hoạt vui chơi trong không gian khô ấm trong nhà',
      'Người cao tuổi tránh đi lại ở sân vườn, bậc thềm ẩm ướt',
      'Cho trẻ uống nước ấm và giữ ấm bàn chân, cổ ngực',
    ],
    alternativeHour: 'Ra ngoài sau khi trời ráo và có nắng ấm',
  ),

  commuteSafeConditions(
    level: SafetyLevel.safe,
    headline: 'Đường thông thoáng, không khí trong lành',
    explanation:
        'Điều kiện di chuyển trên đường rất thoải mái và an toàn, chỉ cần các trang bị giao thông cơ bản.',
    tips: [
      'Đội mũ bảo hiểm chuẩn và đeo kính râm chống bụi gió',
      'Nên để sẵn áo mưa gấp gọn hoặc ô trong cốp xe đề phòng thời tiết bất chợt',
      'Tận hưởng lộ trình di chuyển thoải mái',
    ],
    alternativeHour: null,
  ),
  commuteRequireRegularMask(
    level: SafetyLevel.caution,
    headline: 'Nên đeo khẩu trang y tế và kính chắn gió',
    explanation:
        'Lượng khói xe và bụi đường lơ lửng ở mức trung bình, có thể gây khô họng và ngứa mắt khi di chuyển lâu.',
    tips: [
      'Đeo khẩu trang 4 lớp che kín mũi và cằm',
      'Đeo kính mắt hoặc hạ kính chắn gió mũ bảo hiểm',
      'Mang theo áo mưa nhẹ hoặc ô gấp gọn phòng cơn mưa rào bất chợt',
      'Rửa mặt và tra nước muối sinh lý khi đến nơi làm việc',
    ],
    alternativeHour: 'Tránh các nút giao ùn tắc giờ cao điểm',
  ),
  commuteRequireN95Protective(
    level: SafetyLevel.danger,
    headline: 'Bắt buộc đeo khẩu trang lọc bụi N95 / KF94',
    explanation:
        'Mức độ bụi mịn PM2.5 và khí thải NO2 trên các tuyến đường giao thông vượt ngưỡng báo động đỏ, khẩu trang vải thường không thể cản được.',
    tips: [
      'Bắt buộc dùng khẩu trang chuyên dụng chuẩn N95, KN95 hoặc KF94 có viền ôm khít sống mũi',
      'Đóng kín cửa sổ ô tô và chuyển điều hòa sang chế độ lấy gió trong',
      'Mang theo áo mưa phòng thời tiết chuyển biến xấu',
      'Ưu tiên sử dụng phương tiện giao thông công cộng (xe buýt, tàu điện ngầm) nếu có',
    ],
    alternativeHour: 'Chuyển sang đi sớm trước 07:00 hoặc sau 08:45',
  ),
  commuteRainWarning(
    level: SafetyLevel.caution,
    headline: 'Chuẩn bị áo mưa & cẩn trọng khi tham gia giao thông',
    explanation:
        'Thời tiết có mưa làm giảm tầm nhìn và độ ma sát của lốp xe trên đường. Cần trang bị áo mưa và điều khiển phương tiện thận trọng.',
    tips: [
      'Luôn mang theo áo mưa (ưu tiên áo mưa bộ) hoặc ô/dù trước khi ra đường',
      'Bọc túi nylon chống nước cho điện thoại, laptop và đồ dùng giá trị',
      'Giảm tốc độ, tránh phanh gấp trên vạch kẻ đường hoặc nắp cống kim loại trơn trượt',
      'Bật đèn xe chiếu gần và giữ khoảng cách an toàn gấp đôi so với ngày khô ráo',
    ],
    alternativeHour: 'Tránh xuất phát vào lúc mưa rào nặng hạt nhất',
  ),
  commuteRainAndPollutionWarning(
    level: SafetyLevel.warning,
    headline: 'Chuẩn bị áo mưa & Đeo khẩu trang chống thấm',
    explanation:
        'Mưa kết hợp nồng độ khói bụi giao thông cao. Cần mặc áo mưa và sử dụng khẩu trang có khả năng chống thấm nước để vừa không bị ướt vừa ngăn bụi mịn.',
    tips: [
      'Mặc áo mưa bộ kín gió và đeo khẩu trang y tế/N95 có bề mặt chống thấm',
      'Đóng kín cửa kính xe ô tô hoặc hạ kính chắn gió mũ bảo hiểm',
      'Giữ khoảng cách xe an toàn tối thiểu 10m khi di chuyển trong mưa',
      'Bọc bảo vệ ba lô và đồ dùng điện tử bằng túi chống nước chuyên dụng',
    ],
    alternativeHour: 'Tránh đi lại vào giờ cao điểm mưa gió ùn tắc',
  );

  final SafetyLevel level;
  final String headline;
  final String explanation;
  final List<String> tips;
  final String? alternativeHour;

  const AdvisorDecision({
    required this.level,
    required this.headline,
    required this.explanation,
    required this.tips,
    this.alternativeHour,
  });
}
