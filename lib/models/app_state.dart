import 'package:flutter/foundation.dart';

// =====================================================
// 견적 요청 모델 (PC 점포관리자 연동 대비 구조 설계)
// estimate_requests 테이블 대응
// =====================================================

/// 수리 현황 상태
enum RepairStatus {
  pending,     // 견적 요청 대기
  bidding,     // 투찰 진행중(점포 견적 수신중)
  received,    // 견적 도착(사용자 확인 전)
  matched,     // 매칭 완료(거래 중)
  repairing,   // 수리중
  completed,   // 수리완료
  cancelled,   // 취소
}

extension RepairStatusExt on RepairStatus {
  String get label {
    switch (this) {
      case RepairStatus.pending:   return '요청됨';
      case RepairStatus.bidding:   return '견적 수신중';
      case RepairStatus.received:  return '견적 도착';
      case RepairStatus.matched:   return '거래 중';
      case RepairStatus.repairing: return '수리중';
      case RepairStatus.completed: return '수리완료';
      case RepairStatus.cancelled: return '취소됨';
    }
  }
  String get emoji {
    switch (this) {
      case RepairStatus.pending:   return '⏳';
      case RepairStatus.bidding:   return '📩';
      case RepairStatus.received:  return '📬';
      case RepairStatus.matched:   return '🔧';
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
  final String ownerMessage;       // 사장님 메시지
  final List<String> availableSchedules; // 예약 가능 일정
  String? selectedSchedule;        // 사용자가 선택한 예약 일정
  final DateTime createdAt;
  bool phoneRevealed; // 전화번호 공개 여부 (1:1문의/예약 후)
  final String storePhone;  // 실제 전화번호 (phoneRevealed=true 시에만 표시)
  RepairStatus status;
  bool isRead; // 견적서 확인 여부

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
    this.ownerMessage = '',
    this.availableSchedules = const [],
    this.selectedSchedule,
    required this.createdAt,
    required this.storePhone,
    this.phoneRevealed = false,
    this.status = RepairStatus.bidding,
    this.isRead = false,
  });

  QuoteBid copyWith({bool? phoneRevealed, RepairStatus? status, bool? isRead, String? selectedSchedule}) {
    return QuoteBid(
      bidId: bidId, storeId: storeId, storeName: storeName,
      storeDistance: storeDistance, storeRating: storeRating,
      storeBadge: storeBadge, storeImage: storeImage,
      partsCost: partsCost, laborCost: laborCost, totalCost: totalCost,
      estimatedTime: estimatedTime, memo: memo,
      ownerMessage: ownerMessage, availableSchedules: availableSchedules,
      selectedSchedule: selectedSchedule ?? this.selectedSchedule,
      createdAt: createdAt,
      storePhone: storePhone,
      phoneRevealed: phoneRevealed ?? this.phoneRevealed,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// 견적 요청서 (사용자 → 점포)
class EstimateRequest {
  final String requestId;
  final String carName;       // 차량명
  final String carNumber;     // 차량번호(번호판)
  final String carRegDate;    // 최초 등록일 (예: 2019-03-15)
  final String carYear;       // 연식 (예: 2019년식)
  final String region;        // 방문 지역
  final String repairType;    // 정비 유형
  final List<String> symptoms;// 증상 아이콘 ID 목록
  final String memo;          // 상세 메모
  final List<String> compressedImageUrls; // 압축된 사진 (로컬 경로 or URL)
  final DateTime createdAt;
  RepairStatus status;
  final List<QuoteBid> bids;  // 도착한 견적서 목록
  String? matchedBidId;       // 매칭된 bid ID
  String? matchedSchedule;    // 예약 확정 일정

  EstimateRequest({
    required this.requestId,
    required this.carName,
    required this.carNumber,
    this.carRegDate = '',
    this.carYear = '',
    required this.region,
    required this.repairType,
    required this.symptoms,
    required this.memo,
    required this.compressedImageUrls,
    required this.createdAt,
    this.status = RepairStatus.bidding,
    List<QuoteBid>? bids,
    this.matchedBidId,
    this.matchedSchedule,
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
  // 앱 내 알림 목록 (알림탭 전용)
  final List<Map<String, String>> inAppNotifications = [];
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

  // 알림탭에 알림 추가 (메인배너 대신)
  void addInAppNotification(String title, String body) {
    inAppNotifications.insert(0, {
      'title': title,
      'body': body,
      'time': DateTime.now().toString(),
    });
    notificationCount += 1;
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
            ownerMessage: '안녕하세요! 저희 센터는 KAA 공식 인증점으로 20년 경력 기술진이 직접 작업합니다. 실물 확인 후 정확한 견적 드리겠습니다 😊',
            availableSchedules: ['오늘 오후 2시', '오늘 오후 4시', '내일 오전 10시', '내일 오후 2시', '내일 오후 5시'],
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
            ownerMessage: '고객님 차량 상태 보니 판금+도색 모두 필요할 것 같습니다. 저희는 독일 수입 도료만 사용해 색상 완벽 매칭 보장합니다!',
            availableSchedules: ['내일 오전 9시', '내일 오후 1시', '모레 오전 10시', '모레 오후 3시'],
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
            ownerMessage: '빠른 작업 자신있습니다! 부품 재고 보유 중이라 당일 완료 가능해요. 합리적인 가격으로 최선을 다하겠습니다.',
            availableSchedules: ['오늘 오후 1시', '오늘 오후 3시', '오늘 오후 5시', '내일 오전 11시'],
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
    // 알림탭에만 추가 (메인배너 대신)
    addInAppNotification('새로운 견적서가 도착했습니다', '${req.carName} 견적 요청에 점포가 답변했습니다.');
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

  // ── 매칭 확정: 선택한 bid → matched, 나머지 → cancelled ─────
  // 동일 차량(carName)의 다른 요청도 모두 거래종료(cancelled) 처리
  void matchRequest(String requestId, String selectedBidId, {String? selectedSchedule}) {
    try {
      final req = estimateRequests.firstWhere(
        (r) => r.requestId == requestId,
        orElse: () => estimateRequests.first,
      );
      req.status = RepairStatus.matched;
      req.matchedBidId = selectedBidId;
      req.matchedSchedule = selectedSchedule;
      for (final bid in req.bids) {
        bid.status = bid.bidId == selectedBidId
            ? RepairStatus.matched
            : RepairStatus.cancelled;
      }
      // 동일 차량의 다른 요청 → 거래종료
      for (final other in estimateRequests) {
        if (other.requestId != requestId &&
            other.carName == req.carName &&
            other.status != RepairStatus.cancelled) {
          other.status = RepairStatus.cancelled;
          for (final b in other.bids) {
            if (b.status != RepairStatus.matched) {
              b.status = RepairStatus.cancelled;
            }
          }
        }
      }
      _isRequestActive = false; // 매칭 완료 시 배너 플래그 해제
      // 정비 내역 저장 (마이페이지 연동)
      _saveMaintenanceRecord(req);
    } catch (_) {}
    notifyListeners();
  }

  // ── 거래 완료 처리 (점주 확인 후 호출) ───────────────────────
  void completeRequest(String requestId) {
    try {
      final req = estimateRequests.firstWhere(
        (r) => r.requestId == requestId,
        orElse: () => estimateRequests.first,
      );
      req.status = RepairStatus.completed;
    } catch (_) {}
    notifyListeners();
  }

  // ── 정비 내역 저장 (마이페이지 자동 저장) ──────────────────
  final List<MaintenanceRecord> maintenanceHistory = [];

  void _saveMaintenanceRecord(EstimateRequest req) {
    final matched = req.bids.where((b) => b.bidId == req.matchedBidId).toList();
    if (matched.isEmpty) return;
    final bid = matched.first;
    maintenanceHistory.add(MaintenanceRecord(
      requestId: req.requestId,
      carName: req.carName,
      carNumber: req.carNumber,
      repairType: req.repairType,
      storeName: bid.storeName,
      totalCost: bid.totalCost,
      schedule: req.matchedSchedule ?? bid.selectedSchedule ?? '',
      createdAt: req.createdAt,
    ));
  }

  // ── 견적서 읽음 처리 ─────────────────────────────────────────
  void markBidRead(String requestId, String bidId) {
    final req = estimateRequests.firstWhere(
      (r) => r.requestId == requestId,
      orElse: () => estimateRequests.first,
    );
    for (final bid in req.bids) {
      if (bid.bidId == bidId) {
        bid.isRead = true;
        break;
      }
    }
    notifyListeners();
  }

  // ── 미읽음 견적서 수 ─────────────────────────────────────────
  int get unreadBidCount => estimateRequests.fold(
    0, (sum, r) => sum + r.bids.where((b) => !b.isRead).length);

  // ── 견적 요청 활성 여부 (요청 직후 true → 배너 강제 표시) ────
  bool _isRequestActive = false;
  bool get isRequestActive => _isRequestActive;
  void setRequestActive(bool v) {
    _isRequestActive = v;
    notifyListeners();
  }

  // ── 매칭된 요청 수 ───────────────────────────────────────────
  bool get hasActiveRequest => _isRequestActive || estimateRequests.any(
    (r) => r.status == RepairStatus.bidding   ||
           r.status == RepairStatus.pending    ||
           r.status == RepairStatus.received   ||
           r.status == RepairStatus.matched    ||
           r.status == RepairStatus.repairing);

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

// ==================== 정비 내역 레코드 ====================
class MaintenanceRecord {
  final String requestId;
  final String carName;
  final String carNumber;
  final String repairType;
  final String storeName;
  final int totalCost;
  final String schedule;
  final DateTime createdAt;

  MaintenanceRecord({
    required this.requestId,
    required this.carName,
    required this.carNumber,
    required this.repairType,
    required this.storeName,
    required this.totalCost,
    required this.schedule,
    required this.createdAt,
  });
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

// ==========================================
// 중고차 상태 머신 (헤이딜러 역경매 방식)
// ==========================================

/// 중고차 판매 상태
enum UsedCarStatus {
  waiting,   // 대기 (등록 완료, 딜러 투찰 전)
  bidding,   // 견적중 (딜러 견적 수신중)
  matched,   // 매칭완료 (사용자 동의)
  closed,    // 거래종료 (완료 or 취소)
}

extension UsedCarStatusExt on UsedCarStatus {
  String get label {
    switch (this) {
      case UsedCarStatus.waiting:  return '대기중';
      case UsedCarStatus.bidding:  return '견적수신중';
      case UsedCarStatus.matched:  return '매칭완료';
      case UsedCarStatus.closed:   return '거래종료';
    }
  }
  String get emoji {
    switch (this) {
      case UsedCarStatus.waiting:  return '⏳';
      case UsedCarStatus.bidding:  return '📩';
      case UsedCarStatus.matched:  return '🤝';
      case UsedCarStatus.closed:   return '✅';
    }
  }
}

/// 딜러 투찰 모델
class DealerBid {
  final String bidId;
  final String dealerName;
  final String dealerBadge;   // 'KAA인증', '우수딜러' 등
  final String dealerPhone;
  final double dealerRating;
  final String dealerLocation;
  final int offerPrice;       // 제안 매입가
  final String memo;
  final DateTime createdAt;
  UsedCarStatus status;
  bool isRead;

  DealerBid({
    required this.bidId,
    required this.dealerName,
    required this.dealerBadge,
    required this.dealerPhone,
    required this.dealerRating,
    required this.dealerLocation,
    required this.offerPrice,
    required this.memo,
    required this.createdAt,
    this.status = UsedCarStatus.bidding,
    this.isRead = false,
  });
}

/// 내 차 팔기 요청 모델
class UsedCarSaleRequest {
  final String requestId;
  final String carNumber;     // 차량번호
  final String carName;       // 모델명 (API 조회)
  final String regDate;       // 최초등록일
  final String modelYear;     // 연식
  final int mileage;          // 주행거리
  final bool hasAccident;     // 사고 유무
  final String memo;
  final List<String> photoUrls;
  final DateTime createdAt;
  UsedCarStatus status;
  String? matchedDealerId;
  String? matchedPhone;       // 사용자 연락처 (동의 후 입력)
  final List<DealerBid> bids;

  UsedCarSaleRequest({
    required this.requestId,
    required this.carNumber,
    required this.carName,
    required this.regDate,
    required this.modelYear,
    required this.mileage,
    required this.hasAccident,
    required this.memo,
    required this.photoUrls,
    required this.createdAt,
    this.status = UsedCarStatus.waiting,
    this.matchedDealerId,
    this.matchedPhone,
    List<DealerBid>? bids,
  }) : bids = bids ?? [];

  int get bidCount => bids.length;
  int get unreadBidCount => bids.where((b) => !b.isRead).length;
}

/// 중고차 매물 모델 (엔카/차차차 방식)
class UsedCarListing {
  final String listingId;
  final String title;
  final String carName;
  final String modelYear;
  final int mileage;
  final int price;
  final String fuel;
  final String transmission;
  final String color;
  final bool hasAccident;
  final String region;
  final String sellerName;
  final String sellerPhone;
  final String sellerType;    // 'individual' | 'dealer'
  final int? storeId;         // 점포 연동
  final List<String> photoUrls;
  final String desc;
  final DateTime createdAt;
  bool isFavorite;
  bool isSold;           // 판매완료 여부
  bool isCertified;      // 협회 인증 배지

  UsedCarListing({
    required this.listingId,
    required this.title,
    required this.carName,
    required this.modelYear,
    required this.mileage,
    required this.price,
    required this.fuel,
    required this.transmission,
    required this.color,
    required this.hasAccident,
    required this.region,
    required this.sellerName,
    required this.sellerPhone,
    required this.sellerType,
    this.storeId,
    required this.photoUrls,
    required this.desc,
    required this.createdAt,
    this.isFavorite = false,
    this.isSold = false,
    this.isCertified = false,
  });
}

// ==========================================
// 중고차 AppState 확장 (AppState 싱글톤에 믹스인)
// ==========================================
class UsedCarState extends ChangeNotifier {
  static final UsedCarState _instance = UsedCarState._internal();
  factory UsedCarState() => _instance;
  UsedCarState._internal() { _initDummyData(); }

  final List<UsedCarSaleRequest> saleRequests = [];
  final List<UsedCarListing> listings = [];

  void _initDummyData() {
    // ── 더미 판매 요청 (딜러 투찰 있는 상태) ──
    saleRequests.add(UsedCarSaleRequest(
      requestId: 'SALE-001',
      carNumber: '123가4567',
      carName: '현대 그랜저 IG 3.0',
      regDate: '2019-03-15',
      modelYear: '2019년식',
      mileage: 72000,
      hasAccident: false,
      memo: '무사고 1인 소유 차량, 풀옵션',
      photoUrls: [
        'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=600&q=80',
        'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=600&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: UsedCarStatus.bidding,
      bids: [
        DealerBid(
          bidId: 'BID-001',
          dealerName: 'KAA 인증 중고차센터',
          dealerBadge: 'KAA인증',
          dealerPhone: '053-456-7890',
          dealerRating: 4.8,
          dealerLocation: '대구 수성구 · 2.1km',
          offerPrice: 2450,
          memo: '무사고 실물 확인 후 금액 조정 가능합니다. 당일 이전 처리 가능.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: false,
        ),
        DealerBid(
          bidId: 'BID-002',
          dealerName: '범어 중고차 매매단지',
          dealerBadge: '우수딜러',
          dealerPhone: '053-567-8901',
          dealerRating: 4.5,
          dealerLocation: '대구 수성구 · 1.9km',
          offerPrice: 2380,
          memo: '시세 대비 최고가 매입 보장! 즉시 현금 지급.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          isRead: false,
        ),
        DealerBid(
          bidId: 'BID-003',
          dealerName: '황금동 오토플라자',
          dealerBadge: '인기딜러',
          dealerPhone: '053-678-9012',
          dealerRating: 4.3,
          dealerLocation: '대구 수성구 · 3.2km',
          offerPrice: 2290,
          memo: '사진 확인 완료. 추가 협의 가능합니다.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
          isRead: false,
        ),
      ],
    ));

    // ── 더미 중고차 매물 ──
    listings.addAll([
      UsedCarListing(
        listingId: 'L-001',
        title: '2022 현대 아반떼 CN7 1.6 가솔린 풀옵션',
        carName: '현대 아반떼', modelYear: '2022년식',
        mileage: 28000, price: 1950,
        fuel: '가솔린', transmission: '자동', color: '흰색',
        hasAccident: false, region: '대구 수성구',
        sellerName: 'KAA 인증 중고차센터', sellerPhone: '053-456-7890',
        sellerType: 'dealer', storeId: 4,
        photoUrls: [
          'https://images.unsplash.com/photo-1619767886558-efdc259cde1a?w=600&q=80',
          'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=600&q=80',
          'https://images.unsplash.com/photo-1558981033-88f754cbde65?w=600&q=80',
        ],
        desc: '무사고 1인 소유. 풀옵션 (스마트센스·선루프·통풍시트). 보증기간 잔여 2년. 실물 확인 환영합니다.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      UsedCarListing(
        listingId: 'L-002',
        title: '2021 기아 K5 DL3 2.0 하이브리드 시그니처',
        carName: '기아 K5', modelYear: '2021년식',
        mileage: 45000, price: 2380,
        fuel: '하이브리드', transmission: '자동', color: '검정',
        hasAccident: false, region: '대구 동구',
        sellerName: '범어 중고차 매매단지', sellerPhone: '053-567-8901',
        sellerType: 'dealer', storeId: 5,
        photoUrls: [
          'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=600&q=80',
          'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=600&q=80',
        ],
        desc: '하이브리드 연비 18km/L. 시그니처 풀옵션. 무사고 깨끗한 차량입니다.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      UsedCarListing(
        listingId: 'L-003',
        title: '2020 BMW 320i M스포츠 (G20)',
        carName: 'BMW 320i', modelYear: '2020년식',
        mileage: 52000, price: 3450,
        fuel: '가솔린', transmission: '자동', color: '파랑',
        hasAccident: false, region: '대구 수성구',
        sellerName: '홍길동', sellerPhone: '010-1234-5678',
        sellerType: 'individual',
        photoUrls: [
          'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=600&q=80',
          'https://images.unsplash.com/photo-1617531653332-bd46c16f4d68?w=600&q=80',
        ],
        desc: 'M스포츠패키지 장착. 순정 상태 유지. 직거래 선호합니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      UsedCarListing(
        listingId: 'L-004',
        title: '2023 테슬라 모델3 롱레인지 AWD',
        carName: '테슬라 모델3', modelYear: '2023년식',
        mileage: 12000, price: 4800,
        fuel: '전기', transmission: '자동', color: '흰색',
        hasAccident: false, region: '대구 달서구',
        sellerName: '황금동 오토플라자', sellerPhone: '053-678-9012',
        sellerType: 'dealer', storeId: 4,
        photoUrls: [
          'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=600&q=80',
          'https://images.unsplash.com/photo-1536700503339-1e4b06520771?w=600&q=80',
        ],
        desc: '주행거리 12,000km 극저주행. 자율주행 패키지 포함. 세금계산서 발행 가능.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      UsedCarListing(
        listingId: 'L-005',
        title: '2019 현대 그랜저 IG 3.0 프리미엄',
        carName: '현대 그랜저', modelYear: '2019년식',
        mileage: 68000, price: 2750,
        fuel: '가솔린', transmission: '자동', color: '은색',
        hasAccident: false, region: '대구 수성구',
        sellerName: '이민준', sellerPhone: '010-9876-5432',
        sellerType: 'individual',
        photoUrls: [
          'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=600&q=80',
        ],
        desc: '무사고 2인 소유. 정기 점검 이력 완비. 가격 협의 가능합니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      UsedCarListing(
        listingId: 'L-006',
        title: '2022 벤츠 E220d 아방가르드',
        carName: '벤츠 E220d', modelYear: '2022년식',
        mileage: 18000, price: 5800,
        fuel: '디젤', transmission: '자동', color: '검정',
        hasAccident: false, region: '대구 수성구',
        sellerName: 'KAA 인증 중고차센터', sellerPhone: '053-456-7890',
        sellerType: 'dealer', storeId: 4,
        photoUrls: [
          'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=600&q=80',
          'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=600&q=80',
        ],
        desc: '아방가르드 풀옵션. 18,000km 극저주행. KAA 인증 보증 포함.',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ]);
  }

  // ── 판매 요청 등록 ──
  void addSaleRequest(UsedCarSaleRequest req) {
    saleRequests.insert(0, req);
    notifyListeners();
  }

  // ── 딜러 매칭 확정 ──
  void matchSaleRequest(String requestId, String bidId, {String? phone}) {
    try {
      final req = saleRequests.firstWhere((r) => r.requestId == requestId);
      req.status = UsedCarStatus.matched;
      req.matchedDealerId = bidId;
      req.matchedPhone = phone;
      for (final bid in req.bids) {
        bid.status = bid.bidId == bidId
            ? UsedCarStatus.matched
            : UsedCarStatus.closed;
      }
    } catch (_) {}
    notifyListeners();
  }

  // ── 거래 종료 ──
  void closeSaleRequest(String requestId) {
    try {
      final req = saleRequests.firstWhere((r) => r.requestId == requestId);
      req.status = UsedCarStatus.closed;
    } catch (_) {}
    notifyListeners();
  }

  // ── 매물 찜하기 토글 ──
  void toggleFavorite(String listingId) {
    try {
      final l = listings.firstWhere((l) => l.listingId == listingId);
      l.isFavorite = !l.isFavorite;
    } catch (_) {}
    notifyListeners();
  }

  // ── 매물 등록 ──
  void addListing(UsedCarListing listing) {
    listings.insert(0, listing);
    notifyListeners();
  }

  // ── 판매완료 처리 ──
  void markSold(String listingId) {
    try {
      final l = listings.firstWhere((l) => l.listingId == listingId);
      l.isSold = true;
    } catch (_) {}
    notifyListeners();
  }

  // ── 인증 배지 추가 ──
  void certifyListing(String listingId) {
    try {
      final l = listings.firstWhere((l) => l.listingId == listingId);
      l.isCertified = true;
    } catch (_) {}
    notifyListeners();
  }
}
