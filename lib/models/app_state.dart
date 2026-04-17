import 'package:flutter/foundation.dart';

// =====================================================
// 견적 요청 모델 (PC 점포관리자 연동 대비 구조 설계)
// estimate_requests 테이블 대응
// =====================================================

/// 수리 현황 상태
enum RepairStatus {
  pending,     // 견적 요청 대기
  bidding,     // 투찰 진행중
  matched,     // 매칭 완료
  repairing,   // 수리중
  completed,   // 수리완료
  cancelled,   // 취소
}

extension RepairStatusExt on RepairStatus {
  String get label {
    switch (this) {
      case RepairStatus.pending:   return '대기중';
      case RepairStatus.bidding:   return '견적 수신중';
      case RepairStatus.matched:   return '매칭완료';
      case RepairStatus.repairing: return '수리중';
      case RepairStatus.completed: return '수리완료';
      case RepairStatus.cancelled: return '취소됨';
    }
  }
  String get emoji {
    switch (this) {
      case RepairStatus.pending:   return '⏳';
      case RepairStatus.bidding:   return '📩';
      case RepairStatus.matched:   return '✅';
      case RepairStatus.repairing: return '🔧';
      case RepairStatus.completed: return '🎉';
      case RepairStatus.cancelled: return '❌';
    }
  }
}

/// 증상 아이콘 목록
class SymptomIcon {
  final String id;
  final String emoji;
  final String label;
  const SymptomIcon({required this.id, required this.emoji, required this.label});
}

const List<SymptomIcon> kSymptomIcons = [
  SymptomIcon(id: 'noise',    emoji: '🔊', label: '소음'),
  SymptomIcon(id: 'leak',     emoji: '💧', label: '누유'),
  SymptomIcon(id: 'brake',    emoji: '🛑', label: '브레이크'),
  SymptomIcon(id: 'battery',  emoji: '🔋', label: '배터리'),
  SymptomIcon(id: 'engine',   emoji: '⚙️',  label: '계통류'),
  SymptomIcon(id: 'aircon',   emoji: '❄️',  label: '에어컨'),
  SymptomIcon(id: 'chassis',  emoji: '🚗', label: '하체충격'),
  SymptomIcon(id: 'accident', emoji: '💥', label: '사고수리'),
];

/// 점포 투찰 (견적 답변)
class QuoteBid {
  final String bidId;
  final int storeId;
  final String storeName;
  final String storeDistance;
  final double storeRating;
  final String storeBadge;
  final String storeImage;
  final int partsCost;      // 부품비
  final int laborCost;      // 공임비
  final int totalCost;      // 예상총액
  final String estimatedTime; // 예상 소요시간
  final String memo;
  final DateTime createdAt;
  bool phoneRevealed; // 전화번호 공개 여부 (1:1문의/예약 후)
  final String storePhone;  // 실제 전화번호 (phoneRevealed=true 시에만 표시)
  RepairStatus status;

  QuoteBid({
    required this.bidId,
    required this.storeId,
    required this.storeName,
    required this.storeDistance,
    required this.storeRating,
    required this.storeBadge,
    required this.storeImage,
    required this.partsCost,
    required this.laborCost,
    required this.totalCost,
    required this.estimatedTime,
    required this.memo,
    required this.createdAt,
    required this.storePhone,
    this.phoneRevealed = false,
    this.status = RepairStatus.matched,
  });

  QuoteBid copyWith({bool? phoneRevealed, RepairStatus? status}) {
    return QuoteBid(
      bidId: bidId, storeId: storeId, storeName: storeName,
      storeDistance: storeDistance, storeRating: storeRating,
      storeBadge: storeBadge, storeImage: storeImage,
      partsCost: partsCost, laborCost: laborCost, totalCost: totalCost,
      estimatedTime: estimatedTime, memo: memo, createdAt: createdAt,
      storePhone: storePhone,
      phoneRevealed: phoneRevealed ?? this.phoneRevealed,
      status: status ?? this.status,
    );
  }
}

/// 견적 요청서 (사용자 → 점포)
class EstimateRequest {
  final String requestId;
  final String carName;       // 차량명
  final String carNumber;     // 차량번호
  final String region;        // 방문 지역
  final String repairType;    // 정비 유형
  final List<String> symptoms;// 증상 아이콘 ID 목록
  final String memo;          // 상세 메모
  final List<String> compressedImageUrls; // 압축된 사진 (로컬 경로 or URL)
  final DateTime createdAt;
  RepairStatus status;
  final List<QuoteBid> bids;  // 도착한 견적서 목록

  EstimateRequest({
    required this.requestId,
    required this.carName,
    required this.carNumber,
    required this.region,
    required this.repairType,
    required this.symptoms,
    required this.memo,
    required this.compressedImageUrls,
    required this.createdAt,
    this.status = RepairStatus.bidding,
    List<QuoteBid>? bids,
  }) : bids = bids ?? [];

  int get bidCount => bids.length;
}

/// 점포 알림 설정 (PC 점포관리자 연동 대비)
class ShopNotificationSettings {
  bool soundEnabled;    // 음성 알림
  bool textEnabled;     // 텍스트 알림
  bool vibration;       // 진동
  bool fcmEnabled;      // FCM 푸시 (향후 연동)

  ShopNotificationSettings({
    this.soundEnabled = true,
    this.textEnabled  = true,
    this.vibration    = true,
    this.fcmEnabled   = true,
  });
}

class UserModel {
  final String name;
  final String userType;
  final List<String> interests;
  final String region;
  final String phone;
  final String email;
  final String loginType; // 'normal' or 'social'

  UserModel({
    required this.name,
    this.userType = 'user',
    this.interests = const [],
    this.region = '대구 수성구',
    this.phone = '',
    this.email = '',
    this.loginType = 'social',
  });
}

class SignupState {
  String? provider;
  List<String> agreed = [];
  String name = '';
  String carNumber = '';
  String region = '';
  String selectedCity = '대구';
  List<String> interests = [];
  String userType = 'user';
}

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  String currentPage = 'intro';
  String currentTab = 'home';
  int notificationCount = 4;
  String location = '대구 수성구';
  bool isLoggedIn = false;
  UserModel? user;
  SignupState signup = SignupState();

  void navigateTo(String page) {
    currentPage = page;
    notifyListeners();
  }

  void setLoggedIn(UserModel u) {
    isLoggedIn = true;
    user = u;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    user = null;
    notifyListeners();
  }

  void updateNotificationCount(int count) {
    notificationCount = count;
    notifyListeners();
  }

  // ── 견적 요청 전역 상태 ──────────────────────────
  final List<EstimateRequest> estimateRequests = [];

  // 더미 데이터 초기화 (앱 로드 시 호출)
  void initDummyEstimates() {
    if (estimateRequests.isNotEmpty) return;
    estimateRequests.addAll([
      EstimateRequest(
        requestId: 'REQ-001',
        carName: '그랜저',
        carNumber: '123가4567',
        region: '대구 수성구',
        repairType: '사고수리',
        symptoms: ['noise', 'accident'],
        memo: '알범 급금과 무주 하던 소음이 있습니다. 빠른 예상 견적을 받고 싶습니다.',
        compressedImageUrls: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: RepairStatus.bidding,
        bids: [
          QuoteBid(
            bidId: 'BID-001',
            storeId: 1,
            storeName: 'KAA 수성 협회인증 정비센터',
            storeDistance: '1.1km',
            storeRating: 4.9,
            storeBadge: 'KAA 인증',
            storeImage: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
            partsCost: 180000,
            laborCost: 90000,
            totalCost: 270000,
            estimatedTime: '당일 1시간',
            memo: '실물 확인 시 추가 손상 여부에 따라 달라질 수 있습니다.',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            storePhone: '053-123-4567',
          ),
          QuoteBid(
            bidId: 'BID-002',
            storeId: 2,
            storeName: '프리미엄 바디케어 정비소',
            storeDistance: '2.0km',
            storeRating: 4.8,
            storeBadge: '추천',
            storeImage: 'https://images.unsplash.com/photo-1632823469850-2f77dd9c7f93?w=400&q=80',
            partsCost: 250000,
            laborCost: 130000,
            totalCost: 380000,
            estimatedTime: '소요 1일',
            memo: '판금·도색 포함 견적입니다. 실물 확인 후 조정 가능합니다.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
            storePhone: '053-234-5678',
          ),
          QuoteBid(
            bidId: 'BID-003',
            storeId: 3,
            storeName: 'KAA 스피드 경정비',
            storeDistance: '2.8km',
            storeRating: 4.7,
            storeBadge: '추천',
            storeImage: 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400&q=80',
            partsCost: 120000,
            laborCost: 60000,
            totalCost: 180000,
            estimatedTime: '약 4시간',
            memo: '당일 예약 가능합니다.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
            storePhone: '053-345-6789',
          ),
        ],
      ),
    ]);
    notifyListeners();
  }

  void addEstimateRequest(EstimateRequest req) {
    estimateRequests.insert(0, req);
    notificationCount += 1;
    notifyListeners();
  }

  void revealPhone(String requestId, String bidId) {
    final req = estimateRequests.firstWhere((r) => r.requestId == requestId, orElse: () => estimateRequests.first);
    for (final bid in req.bids) {
      if (bid.bidId == bidId) {
        bid.phoneRevealed = true;
        break;
      }
    }
    notifyListeners();
  }

  void updateRepairStatus(String requestId, String bidId, RepairStatus status) {
    final req = estimateRequests.firstWhere((r) => r.requestId == requestId, orElse: () => estimateRequests.first);
    for (final bid in req.bids) {
      if (bid.bidId == bidId) {
        bid.status = status;
        break;
      }
    }
    notifyListeners();
  }

  // ── 점포 알림 설정 ─────────────────────────────
  ShopNotificationSettings shopNotifSettings = ShopNotificationSettings();

  void updateShopNotifSettings({bool? sound, bool? text, bool? vibration}) {
    if (sound != null)     shopNotifSettings.soundEnabled = sound;
    if (text != null)      shopNotifSettings.textEnabled  = text;
    if (vibration != null) shopNotifSettings.vibration    = vibration;
    notifyListeners();
  }

  // ── 도착 견적서 총 개수 ─────────────────────────
  int get totalBidCount => estimateRequests.fold(0, (sum, r) => sum + r.bidCount);
}

// ==================== 데이터 모델 ====================
// 유튜브 video_id 추출 유틸리티
String? extractYoutubeVideoId(String? url) {
  if (url == null || url.isEmpty) return null;
  final regExp = RegExp(
    r'(?:youtube\.com/(?:watch\?v=|shorts/|embed/)|youtu\.be/)([\w-]{11})',
    caseSensitive: false,
  );
  final match = regExp.firstMatch(url);
  return match?.group(1);
}

class Store {
  final int id;
  final String name;
  final String category;
  final String badge;
  final String type;
  final String distance;
  final double rating;
  final String address;
  final String hours;
  final String phone;
  final int visits;
  final int inquiries;
  final List<String> tags;
  final String image;
  final List<StoreService> services;
  final String desc;
  final String aiIntro;
  final String? youtubeUrl;
  final int videoHits;

  Store({
    required this.id,
    required this.name,
    required this.category,
    required this.badge,
    required this.type,
    required this.distance,
    required this.rating,
    required this.address,
    required this.hours,
    required this.phone,
    required this.visits,
    required this.inquiries,
    required this.tags,
    required this.image,
    required this.services,
    required this.desc,
    this.aiIntro = '',
    this.youtubeUrl,
    this.videoHits = 0,
  });

  String? get videoId => extractYoutubeVideoId(youtubeUrl);

  Store copyWith({String? youtubeUrl, int? videoHits}) {
    return Store(
      id: id, name: name, category: category, badge: badge, type: type,
      distance: distance, rating: rating, address: address, hours: hours,
      phone: phone, visits: visits, inquiries: inquiries, tags: tags,
      image: image, services: services, desc: desc, aiIntro: aiIntro,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      videoHits: videoHits ?? this.videoHits,
    );
  }
}

class StoreService {
  final String name;
  final String price;
  final String desc;
  StoreService({required this.name, required this.price, required this.desc});
}

class Banner {
  final String image;
  final String label;
  final String title;
  final String subtitle;
  Banner({required this.image, required this.label, required this.title, required this.subtitle});
}

// ==================== 정적 데이터 ====================
class AppData {
  static final List<Store> stores = [
    Store(
      id: 1, name: 'KAA 추천 프리미엄 정비소', category: '정비',
      badge: 'KAA 인증', type: 'certified',
      distance: '1.8km', rating: 4.9,
      address: '대구시 수성구 범어동 123-4',
      hours: '09:00 ~ 19:00', phone: '053-123-4567',
      visits: 128, inquiries: 34,
      tags: ['정비', '미션오일', '브레이크'],
      image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
      services: [
        StoreService(name: '엔진오일 교환', price: '89,000원', desc: '엔진오일 · 필터 교체와 기본 점검 포함'),
        StoreService(name: '브레이크 점검 패키지', price: '59,000원', desc: '브레이크 패드/디스크 기본 점검'),
        StoreService(name: '하체 소음 진단', price: '35,000원', desc: '하체 진단 및 리프트 점검'),
      ],
      desc: 'KAA 추천 프리미엄 정비소의 대표 서비스와 이용 정보를 한눈에 확인하세요.',
      aiIntro: '대구 수성구에 위치한 KAA 공식 인증 프리미엄 정비소입니다. 20년 이상 경력의 전문 정비사가 직접 차량을 점검하며, 엔진·미션·브레이크 등 핵심 부품 전반을 다룹니다.',
      youtubeUrl: 'https://www.youtube.com/shorts/SsGWb9G4bOE',
      videoHits: 3420,
    ),
    Store(
      id: 2, name: '추천 세차·코팅 전문점', category: '세차',
      badge: '추천', type: 'normal',
      distance: '2.4km', rating: 4.7,
      address: '대구시 수성구 두산동 45-2',
      hours: '08:00 ~ 20:00', phone: '053-234-5678',
      visits: 89, inquiries: 21,
      tags: ['세차', '코팅', '광택'],
      image: 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=400&q=80',
      services: [
        StoreService(name: '프리미엄 손세차', price: '35,000원', desc: '전체 외관 손세차 및 내부 청소'),
        StoreService(name: '세라믹 코팅', price: '350,000원', desc: '3년 보장 세라믹 코팅'),
      ],
      desc: '전문 세차 장비와 친환경 세차용품으로 차량을 완벽하게 관리해드립니다.',
      aiIntro: '친환경 세차 용품만 사용하는 수성구 대표 세차 코팅 전문점입니다. 세라믹 코팅 3년 보증 서비스를 제공합니다.',
      youtubeUrl: 'https://www.youtube.com/shorts/YR5GBp2GZNY',
      videoHits: 2810,
    ),
    Store(
      id: 3, name: '프리미엄 타이어 전문점', category: '타이어',
      badge: 'KAA 인증', type: 'certified',
      distance: '3.1km', rating: 4.8,
      address: '대구시 수성구 만촌동 88-1',
      hours: '09:00 ~ 18:30', phone: '053-345-6789',
      visits: 156, inquiries: 42,
      tags: ['타이어', '얼라인먼트', '밸런스'],
      image: 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400&q=80',
      services: [
        StoreService(name: '타이어 교체 (4개)', price: '80,000원~', desc: '타이어 교체+밸런스+얼라인먼트'),
        StoreService(name: '휠 얼라인먼트', price: '30,000원', desc: '4륜 얼라인먼트 정밀 측정'),
      ],
      desc: '국내외 주요 타이어 브랜드를 취급하며 전문 기술진이 최적의 타이어를 추천해드립니다.',
      aiIntro: 'KAA 인증 타이어 전문점으로, 최신 3D 얼라인먼트 장비를 보유하고 있습니다.',
      youtubeUrl: 'https://www.youtube.com/shorts/LrZV45OJZWQ',
      videoHits: 1950,
    ),
    Store(
      id: 4, name: 'KAA 인증 중고차센터', category: '중고차',
      badge: 'KAA 인증', type: 'certified',
      distance: '2.1km', rating: 4.6,
      address: '대구시 수성구 황금동 201-3',
      hours: '10:00 ~ 18:00', phone: '053-456-7890',
      visits: 203, inquiries: 67,
      tags: ['중고차', '성능점검', '보증'],
      image: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=400&q=80',
      services: [
        StoreService(name: '중고차 성능점검', price: '30,000원', desc: '160개 항목 종합 점검'),
        StoreService(name: '사고이력 조회', price: '무료', desc: '사고이력 무료 조회'),
      ],
      desc: 'KAA 인증 중고차센터에서 투명하고 안전한 중고차 거래를 경험하세요.',
      aiIntro: 'KAA 공식 인증 투명한 중고차 거래 전문센터입니다. 160개 항목의 철저한 성능 점검과 무료 사고이력 조회를 통해 안심 구매를 보장합니다.',
      youtubeUrl: 'https://www.youtube.com/shorts/aBcDE12FgHI',
      videoHits: 1540,
    ),
    Store(
      id: 5, name: '하이브리드 배터리 전문점', category: '정비',
      badge: '전문', type: 'certified',
      distance: '4.2km', rating: 4.5,
      address: '대구시 수성구 범물동 55-7',
      hours: '09:00 ~ 18:00', phone: '053-567-8901',
      visits: 74, inquiries: 28,
      tags: ['하이브리드', '배터리', '전기장치'],
      image: 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=400&q=80',
      services: [
        StoreService(name: '하이브리드 배터리 점검', price: '50,000원', desc: '하이브리드 배터리 종합 진단'),
        StoreService(name: '배터리 교체', price: '900,000원~', desc: '하이브리드 배터리 전문 교체'),
      ],
      desc: '하이브리드 및 전기차 배터리 전문 정비센터입니다.',
      aiIntro: '하이브리드 전기차 배터리 전문 정비센터입니다. 배터리 교체 시 12개월 품질 보증이 제공됩니다.',
      videoHits: 0,
    ),
    Store(
      id: 6, name: '수입차 브랜드 전문가점', category: '정비',
      badge: '전문', type: 'normal',
      distance: '3.8km', rating: 4.7,
      address: '대구시 수성구 지산동 99-2',
      hours: '09:00 ~ 19:00', phone: '053-678-9012',
      visits: 112, inquiries: 38,
      tags: ['수입차', '정비', 'BMW', '벤츠'],
      image: 'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=400&q=80',
      services: [
        StoreService(name: '수입차 엔진오일 교환', price: '120,000원~', desc: '수입차 전용 엔진오일 교환'),
        StoreService(name: '수입차 종합점검', price: '80,000원', desc: '수입차 전문 종합 점검'),
      ],
      desc: 'BMW, 벤츠, 아우디 등 수입차 전문 정비센터입니다.',
      aiIntro: 'BMW 벤츠 아우디 공식 인증 정비사가 상주하는 수입차 전문 케어센터입니다.',
      videoHits: 0,
    ),
  ];

  static final List<Banner> banners = [
    Banner(
      image: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600&q=80',
      label: '자동차 소식',
      title: '중고차 성능점검 확인 수요 확대',
      subtitle: '구매 전 사고이력 · 성능점검표 확인 필수',
    ),
    Banner(
      image: 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=600&q=80',
      label: '협회 이벤트',
      title: '협회 회원 특별 혜택',
      subtitle: '정비·세차·타이어 최대 30% 할인',
    ),
    Banner(
      image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
      label: 'KAA 인증',
      title: 'KAA 인증 점포 혜택',
      subtitle: '인증된 점포에서 믿을 수 있는 서비스를',
    ),
    Banner(
      image: 'https://images.unsplash.com/photo-1471444928139-48c5bf5173f8?w=600&q=80',
      label: '견적 서비스',
      title: '사진 한 장으로 견적 요청',
      subtitle: '근처 정비점포 예상 견적을 한번에',
    ),
  ];

  static final List<Map<String, String>> categories = [
    {'name': '정비', 'icon': '🔧'},
    {'name': '세차', 'icon': '🚿'},
    {'name': '타이어', 'icon': '⚙️'},
    {'name': '중고차', 'icon': '🏪'},
    {'name': '검사', 'icon': '📋'},
    {'name': '주유', 'icon': '⛽'},
    {'name': '주차장', 'icon': '🅿️'},
    {'name': '렌트카', 'icon': '🚗'},
    {'name': '중고차수출', 'icon': '✈️'},
    {'name': '차량용품', 'icon': '🛒'},
  ];

  static final List<Map<String, String>> interests = [
    {'id': 'car_info', 'icon': '🚗', 'label': '자동차 정보'},
    {'id': 'used_car', 'icon': '🏪', 'label': '중고차 거래'},
    {'id': 'maintenance', 'icon': '🔧', 'label': '차량 정비'},
    {'id': 'news', 'icon': '📰', 'label': '자동차 뉴스'},
    {'id': 'ev', 'icon': '⚡', 'label': '전기차·친환경'},
    {'id': 'insurance', 'icon': '🛡️', 'label': '자동차 보험'},
    {'id': 'drive', 'icon': '🛣️', 'label': '드라이브·여행'},
    {'id': 'tuning', 'icon': '🎨', 'label': '튜닝·용품'},
    {'id': 'traffic', 'icon': '🚦', 'label': '교통·법규'},
    {'id': 'carwash', 'icon': '✨', 'label': '세차·코팅'},
    {'id': 'community', 'icon': '👥', 'label': '동호회·커뮤니티'},
    {'id': 'finance', 'icon': '💳', 'label': '할부·금융'},
  ];
}
