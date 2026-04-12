import 'package:flutter/foundation.dart';

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
}

// ==================== 데이터 모델 ====================
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
  });
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
      aiIntro: '대구 수성구에 위치한 KAA 공식 인증 프리미엄 정비소입니다. 20년 이상 경력의 전문 정비사가 직접 차량을 점검하며, 엔진·미션·브레이크 등 핵심 부품 전반을 다룹니다. 고객 대기실에는 무료 음료와 Wi-Fi가 제공되며, 실시간 정비 현황을 문자로 안내해 드립니다.',
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
      aiIntro: '친환경 세차 용품만 사용하는 수성구 대표 세차 코팅 전문점입니다. 세라믹 코팅 3년 보증 서비스를 제공하며, 전담 코팅 전문가가 차량 상태를 분석한 후 맞춤형 코팅 플랜을 제안합니다. 광택 복원율 98%를 자랑합니다.',
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
      aiIntro: 'KAA 인증 타이어 전문점으로, 국내외 모든 주요 타이어 브랜드를 최저가로 공급합니다. 최신 3D 얼라인먼트 장비를 보유하고 있으며, 구매 후 6개월 무상 점검 서비스와 펑크 무상 수리 혜택이 제공됩니다.',
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
      aiIntro: 'KAA 공식 인증 투명한 중고차 거래 전문센터입니다. 160개 항목의 철저한 성능 점검과 무료 사고이력 조회를 통해 안심 구매를 보장합니다. 구매 후 30일 무상 AS와 1년 보증 서비스가 제공됩니다.',
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
      aiIntro: '하이브리드 전기차 배터리 전문 정비센터입니다. 현대 기아 도요타 등 주요 차량의 배터리 진단 장비를 완비하고 있으며, 배터리 교체 시 12개월 품질 보증이 제공됩니다.',
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
      aiIntro: 'BMW 벤츠 아우디 공식 인증 정비사가 상주하는 수입차 전문 케어센터입니다. 수입차 전용 OBD 진단 장비와 정품 부품만을 사용하며, 딜러사 대비 30~40% 저렴한 가격으로 동일한 품질의 서비스를 제공합니다.',
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
