/// Điểm đen ngập úng đô thị kinh niên tại các thành phố lớn ở Việt Nam
class FloodBlackspot {
  final String id;
  final String name;
  final String province;
  final double latitude;
  final double longitude;
  final String description;
  final int averageDepthCm;
  final String triggerCondition; // Điều kiện kích hoạt gây ngập
  final String proneTime; // Khoảng thời gian / mùa thường xảy ra ngập

  const FloodBlackspot({
    required this.id,
    required this.name,
    required this.province,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.averageDepthCm,
    required this.triggerCondition,
    required this.proneTime,
  });

  /// Danh mục điểm đen ngập lụt kinh niên trọng điểm tại Việt Nam
  static const List<FloodBlackspot> vietnamBlackspots = [
    // HÀ NỘI
    FloodBlackspot(
      id: 'hn_flood_01',
      name: 'Ngã tư Phan Bội Châu - Lý Thường Kiệt',
      province: 'Hà Nội',
      latitude: 21.0258,
      longitude: 105.8458,
      description: 'Vùng trũng trung tâm Hoàn Kiếm, nước thoát chậm vào hệ thống cống cổ',
      averageDepthCm: 35,
      triggerCondition: 'Mưa rào dồn dập trên 35mm/h trong 30-45 phút',
      proneTime: 'Mùa mưa bão miền Bắc (Tháng 5 - Tháng 9)',
    ),
    FloodBlackspot(
      id: 'hn_flood_02',
      name: 'Đường Thụy Khuê (Dốc La Pho)',
      province: 'Hà Nội',
      latitude: 21.0425,
      longitude: 105.8285,
      description: 'Đoạn trũng gần dốc Tam Đa, mực nước hồ Tây dâng cao làm chậm dòng chảy',
      averageDepthCm: 30,
      triggerCondition: 'Mưa dông lớn >40mm/h',
      proneTime: 'Mùa hè - thu (Tháng 6 - Tháng 9)',
    ),
    FloodBlackspot(
      id: 'hn_flood_03',
      name: 'Phố Nguyễn Khuyến (Khu vực Văn Miếu)',
      province: 'Hà Nội',
      latitude: 21.0280,
      longitude: 105.8360,
      description: 'Điểm trũng lịch sử Đống Đa, thường xuyên đọng nước cục bộ',
      averageDepthCm: 45,
      triggerCondition: 'Mưa rào kéo dài trên 40 phút (>30mm)',
      proneTime: 'Mùa mưa bão (Tháng 5 - Tháng 10)',
    ),
    FloodBlackspot(
      id: 'hn_flood_04',
      name: 'Phố Hoa Bằng (Cầu Giấy)',
      province: 'Hà Nội',
      latitude: 21.0230,
      longitude: 105.7950,
      description: 'Đoạn ngập kéo dài dọc ngõ phố dân cư, giao thông xe máy bị tê liệt',
      averageDepthCm: 40,
      triggerCondition: 'Mưa to cục bộ >35mm/h',
      proneTime: 'Cao điểm mùa hè (Tháng 6 - Tháng 8)',
    ),
    FloodBlackspot(
      id: 'hn_flood_05',
      name: 'Hầm chui Đại Lộ Thăng Long',
      province: 'Hà Nội',
      latitude: 21.0020,
      longitude: 105.7600,
      description: 'Hầm chui số 3, 5, 6 trũng thấp, nước gom nhanh từ lưu vực đường cao tốc',
      averageDepthCm: 50,
      triggerCondition: 'Mưa to dồn dập >50mm kết hợp xả tràn gom nước',
      proneTime: 'Mùa mưa bão (Tháng 6 - Tháng 10)',
    ),

    // TP. HỒ CHÍ MINH
    FloodBlackspot(
      id: 'hcm_flood_01',
      name: 'Đường Nguyễn Văn Khối (Cây Trâm cũ)',
      province: 'TP. Hồ Chí Minh',
      latitude: 10.8420,
      longitude: 106.6540,
      description: 'Khu vực Gò Vấp, địa hình trũng đón nước từ đường Lê Văn Thọ đổ về',
      averageDepthCm: 45,
      triggerCondition: 'Mưa lớn >40mm/h hoặc mưa dông chiều kết hợp triều dâng',
      proneTime: 'Mùa mưa Nam Bộ (Tháng 5 - Tháng 11)',
    ),
    FloodBlackspot(
      id: 'hcm_flood_02',
      name: 'Đường Quốc Hương (Thảo Điền)',
      province: 'TP. Hồ Chí Minh',
      latitude: 10.8040,
      longitude: 106.7320,
      description: 'Rốn ngập Thảo Điền TP. Thủ Đức, chịu tác động kép triều cường sông Sài Gòn',
      averageDepthCm: 40,
      triggerCondition: 'Triều cường vượt báo động 3 (>1.60m) hoặc mưa to >30mm',
      proneTime: 'Tháng 9 - Tháng 12 (Đỉnh triều) & Mùa mưa (T5 - T11)',
    ),
    FloodBlackspot(
      id: 'hcm_flood_03',
      name: 'Đường Huỳnh Tấn Phát (Quận 7)',
      province: 'TP. Hồ Chí Minh',
      latitude: 10.7420,
      longitude: 106.7280,
      description: 'Đoạn từ cầu Phú Xuân đến Nhà Bè, mép sông Nhà Bè dâng nhanh',
      averageDepthCm: 35,
      triggerCondition: 'Đỉnh triều rằm / mùng 1 âm lịch hoặc mưa kéo dài',
      proneTime: 'Tháng 8 - Tháng 12 âm lịch',
    ),
    FloodBlackspot(
      id: 'hcm_flood_04',
      name: 'Đường Ung Văn Khiêm (Bình Thạnh)',
      province: 'TP. Hồ Chí Minh',
      latitude: 10.8080,
      longitude: 106.7150,
      description: 'Đoạn ngã ba Nguyễn Gia Trí, cống tiêu ra sông Sài Gòn bị áp lực nước dâng',
      averageDepthCm: 35,
      triggerCondition: 'Mưa to trên 40mm/h trong 1 giờ',
      proneTime: 'Mùa mưa (Tháng 5 - Tháng 11)',
    ),
    FloodBlackspot(
      id: 'hcm_flood_05',
      name: 'Đường Tô Ngọc Vân (TP. Thủ Đức)',
      province: 'TP. Hồ Chí Minh',
      latitude: 10.8620,
      longitude: 106.7550,
      description: 'Đoạn giao cắt đường sắt Bắc Nam, độ dốc lớn dồn dòng nước cuộn xiết',
      averageDepthCm: 45,
      triggerCondition: 'Mưa dông lớn >35mm/h',
      proneTime: 'Mùa mưa bão (Tháng 6 - Tháng 11)',
    ),

    // ĐÀ NẴNG
    FloodBlackspot(
      id: 'dn_flood_01',
      name: 'Khu vực Hàm Nghi - Bờ Hồ',
      province: 'Đà Nẵng',
      latitude: 16.0610,
      longitude: 108.2120,
      description: 'Vùng trũng hồ Thạc Gián - Vĩnh Trung trung tâm Hải Châu/Thanh Khê',
      averageDepthCm: 35,
      triggerCondition: 'Mưa lớn dồn dập sau áp thấp nhiệt đới (>50mm/h)',
      proneTime: 'Mùa mưa bão miền Trung (Tháng 9 - Tháng 12)',
    ),
    FloodBlackspot(
      id: 'dn_flood_02',
      name: 'Đường Trưng Nữ Vương',
      province: 'Đà Nẵng',
      latitude: 16.0520,
      longitude: 108.2190,
      description: 'Đoạn gần cầu Rồng và chợ Mới, cống thoát ra sông Hàn bị hạn chế khi thủy triều cao',
      averageDepthCm: 30,
      triggerCondition: 'Mưa lớn >40mm/h kết hợp triều cường sông Hàn',
      proneTime: 'Tháng 10 - Tháng 12',
    ),

    // CẦN THƠ
    FloodBlackspot(
      id: 'ct_flood_01',
      name: 'Đường Mậu Thân - Nguyễn Văn Cừ',
      province: 'Cần Thơ',
      latitude: 10.0380,
      longitude: 105.7720,
      description: 'Giao lộ trọng điểm Ninh Kiều, chịu tác động trực tiếp của lũ thượng nguồn sông Hậu',
      averageDepthCm: 40,
      triggerCondition: 'Đỉnh triều rằm tháng 9 - 10 âm lịch kết hợp mưa chiều',
      proneTime: 'Tháng 9 - Tháng 11 (Mùa nước nổi & triều cường ĐBSCL)',
    ),
  ];
}
