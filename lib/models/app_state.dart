import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

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

// ══════════════════════════════════════════════════════════
// 타이어 견적 요청 모델
// ══════════════════════════════════════════════════════════
enum TireRequestStatus {
  bidding,   // 견적 수신 대기
  received,  // 견적 도착
  confirmed, // 확정
  cancelled,
}

class TireBid {
  final String bidId;
  final int storeId;
  final String storeName;
  final String storeDistance;
  final double storeRating;
  final String tireWidth;
  final String tireAspect;
  final String tireInch;
  final String tireBrand;    // 브랜드 (한국, 금호, 미쉐린 등)
  final bool isUsed;         // 중고 여부
  final int pricePerTire;    // 1개 가격
  final int quantity;        // 수량
  final int totalCost;
  final String estimatedTime;
  final String memo;
  final String storePhone;
  final DateTime createdAt;
  bool isRead;

  TireBid({
    required this.bidId,
    required this.storeId,
    required this.storeName,
    required this.storeDistance,
    required this.storeRating,
    required this.tireWidth,
    required this.tireAspect,
    required this.tireInch,
    required this.tireBrand,
    required this.isUsed,
    required this.pricePerTire,
    required this.quantity,
    required this.totalCost,
    required this.estimatedTime,
    required this.memo,
    required this.storePhone,
    required this.createdAt,
    this.isRead = false,
  });
}

class TireRequest {
  final String requestId;
  final String tireWidth;
  final String tireAspect;
  final String tireInch;
  final bool isUsed;
  final String carName;
  final String region;
  final DateTime createdAt;
  TireRequestStatus status;
  final List<TireBid> bids;

  TireRequest({
    required this.requestId,
    required this.tireWidth,
    required this.tireAspect,
    required this.tireInch,
    required this.isUsed,
    required this.carName,
    required this.region,
    required this.createdAt,
    this.status = TireRequestStatus.bidding,
    List<TireBid>? bids,
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
    _isRequestActive = true; // ← 배너 즉시 stage1 표시
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
  // 하드코딩 초기 이력: StoreDetail '이력 기반 재견적' 버튼이 즉시 표시되도록
  final List<MaintenanceRecord> maintenanceHistory = [
    MaintenanceRecord(
      requestId: 'HIST-001',
      carName: '현대 아반떼 2021',
      carNumber: '123가4567',
      repairType: '엔진오일 교환',
      storeName: 'KAA 추천 프리미엄 정비소',
      storeId: 1,
      storePhone: '053-123-4567',
      totalCost: 89000,
      schedule: '2024-12-10 오전 10시',
      createdAt: DateTime(2024, 12, 10),
    ),
    MaintenanceRecord(
      requestId: 'HIST-002',
      carName: '현대 아반떼 2021',
      carNumber: '123가4567',
      repairType: '타이어 교체 (앞 2개)',
      storeName: 'KAA 타이어 전문점',
      storeId: 3,
      storePhone: '053-345-6789',
      totalCost: 280000,
      schedule: '2024-09-05 오후 2시',
      createdAt: DateTime(2024, 9, 5),
    ),
    MaintenanceRecord(
      requestId: 'HIST-003',
      carName: '현대 아반떼 2021',
      carNumber: '123가4567',
      repairType: '브레이크 패드 교환',
      storeName: 'KAA 추천 프리미엄 정비소',
      storeId: 1,
      storePhone: '053-123-4567',
      totalCost: 150000,
      schedule: '2024-06-22 오전 11시',
      createdAt: DateTime(2024, 6, 22),
    ),
  ];

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
      storeId: bid.storeId,
      storePhone: bid.storePhone,
      totalCost: bid.totalCost,
      schedule: req.matchedSchedule ?? bid.selectedSchedule ?? '',
      createdAt: req.createdAt,
    ));
  }

  // ── [핵심] 점포가 견적서 발송 → 사용자 배너 즉시 received 전환 ─
  // shopRequestId: ShopInbox의 더미 req['id'] (isFromApp=true인 경우 AppState requestId와 매핑)
  // 직접 EstimateRequest에 QuoteBid를 추가하고 status = received 로 변경
  void shopSendBid({
    required String requestId,   // AppState.estimateRequests 의 requestId
    required QuoteBid bid,       // 점포가 작성한 견적서
  }) {
    try {
      final req = estimateRequests.firstWhere(
        (r) => r.requestId == requestId,
        orElse: () => estimateRequests.first,
      );
      // 이미 같은 점포가 낸 bid가 있으면 업데이트, 없으면 추가
      final existing = req.bids.indexWhere((b) => b.storeId == bid.storeId);
      if (existing >= 0) {
        req.bids[existing] = bid;
      } else {
        req.bids.add(bid);
      }
      // 배너를 즉시 'received'로 전환
      if (req.status == RepairStatus.pending ||
          req.status == RepairStatus.bidding) {
        req.status = RepairStatus.received;
      }
      // 사용자에게 인앱 알림
      addInAppNotification(
        '새 견적서 도착! 🎉',
        '${bid.storeName}에서 ${req.carName} 견적서를 보냈습니다.',
      );
      _isRequestActive = true; // 배너 강제 표시
    } catch (_) {}
    notifyListeners();
  }

  // ── 타이어: 점포가 견적 발송 → 배너 received 전환 ──────────
  void shopSendTireBid({
    required String requestId,
    required TireBid bid,
  }) {
    try {
      final req = tireRequests.firstWhere(
        (r) => r.requestId == requestId,
        orElse: () => tireRequests.first,
      );
      final existing = req.bids.indexWhere((b) => b.storeId == bid.storeId);
      if (existing >= 0) {
        req.bids[existing] = bid;
      } else {
        req.bids.add(bid);
      }
      if (req.status == TireRequestStatus.bidding) {
        req.status = TireRequestStatus.received;
      }
      addInAppNotification(
        '타이어 견적서 도착! 🛞',
        '${bid.storeName}에서 타이어 견적서를 보냈습니다.',
      );
    } catch (_) {}
    notifyListeners();
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

  // ── 타이어 견적 요청 ─────────────────────────────────────────
  final List<TireRequest> tireRequests = [];

  void addTireRequest(TireRequest req) {
    tireRequests.insert(0, req);
    // 더미 견적 자동 생성 (시뮬레이션)
    Future.delayed(const Duration(seconds: 2), () {
      _addDummyTireBids(req);
    });
    notifyListeners();
  }

  void _addDummyTireBids(TireRequest req) {
    req.bids.addAll([
      TireBid(
        bidId: 'TB-${req.requestId}-1',
        storeId: 1,
        storeName: 'KAA 추천 프리미엄 정비소',
        storeDistance: '1.8km',
        storeRating: 4.9,
        tireWidth: req.tireWidth,
        tireAspect: req.tireAspect,
        tireInch: req.tireInch,
        tireBrand: req.isUsed ? '한국타이어 (중고 A급)' : '한국타이어 Ventus S1',
        isUsed: req.isUsed,
        pricePerTire: req.isUsed ? 45000 : 128000,
        quantity: 4,
        totalCost: req.isUsed ? 180000 : 512000,
        estimatedTime: '약 1시간',
        memo: req.isUsed
          ? '상태 양호한 A급 중고 재고 있습니다. 당일 작업 가능.'
          : '신품 재고 있음. 균형 잡기 포함 가격.',
        storePhone: '053-123-4567',
        createdAt: DateTime.now(),
      ),
      TireBid(
        bidId: 'TB-${req.requestId}-2',
        storeId: 2,
        storeName: '타이어 스피드 전문점',
        storeDistance: '2.3km',
        storeRating: 4.7,
        tireWidth: req.tireWidth,
        tireAspect: req.tireAspect,
        tireInch: req.tireInch,
        tireBrand: req.isUsed ? '금호타이어 (중고 B급)' : '금호타이어 SOLUS 4S',
        isUsed: req.isUsed,
        pricePerTire: req.isUsed ? 35000 : 98000,
        quantity: 4,
        totalCost: req.isUsed ? 140000 : 392000,
        estimatedTime: '약 45분',
        memo: req.isUsed
          ? '저렴한 B급 중고 재고. 주행 가능 상태.'
          : '당일 장착 가능. 공임비 포함.',
        storePhone: '053-234-5678',
        createdAt: DateTime.now(),
      ),
    ]);
    req.status = TireRequestStatus.received;
    notifyListeners();
  }

  TireRequest? get activeTireRequest {
    try {
      return tireRequests.firstWhere(
        (r) => r.status == TireRequestStatus.bidding ||
               r.status == TireRequestStatus.received,
      );
    } catch (_) { return null; }
  }

  // ── 타이어 견적 확정: 선택 점포 확정 + 나머지 '거래 완료' + 배너 리셋 ──
  void confirmTireRequest(String requestId, String selectedBidId) {
    try {
      final req = tireRequests.firstWhere(
        (r) => r.requestId == requestId,
        orElse: () => tireRequests.first,
      );
      req.status = TireRequestStatus.confirmed;
      for (final bid in req.bids) {
        bid.isRead = bid.bidId != selectedBidId; // 미선택 점포 → 거래완료(비활성화)
      }
      // 타이어 정비 이력 저장
      final confirmed = req.bids.where((b) => b.bidId == selectedBidId).toList();
      if (confirmed.isNotEmpty) {
        final bid = confirmed.first;
        maintenanceHistory.add(MaintenanceRecord(
          requestId: req.requestId,
          carName: req.carName,
          carNumber: '',
          repairType: '타이어 교체 (${req.tireWidth}/${req.tireAspect}/R${req.tireInch})',
          storeName: bid.storeName,
          storeId: bid.storeId,
          storePhone: bid.storePhone,
          totalCost: bid.totalCost,
          schedule: '',
          createdAt: DateTime.now(),
        ));
      }
    } catch (_) {}
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
  final int storeId;        // 점포 상세 연결용
  final String storePhone;  // 다시 신청 시 전화
  final int totalCost;
  final String schedule;
  final DateTime createdAt;
  String? reviewText;       // 리뷰 텍스트
  int? reviewRating;        // 리뷰 별점 (1~5)

  MaintenanceRecord({
    required this.requestId,
    required this.carName,
    required this.carNumber,
    required this.repairType,
    required this.storeName,
    this.storeId = 1,
    this.storePhone = '',
    required this.totalCost,
    required this.schedule,
    required this.createdAt,
    this.reviewText,
    this.reviewRating,
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

// ══════════════════════════════════════════════════════════════
// 차량 옵션 마스터 데이터
// ══════════════════════════════════════════════════════════════

enum CarOptionCategory { seat, safety, convenience, exterior }

extension CarOptionCategoryExt on CarOptionCategory {
  String get label {
    switch (this) {
      case CarOptionCategory.seat: return '시트';
      case CarOptionCategory.safety: return '안전';
      case CarOptionCategory.convenience: return '편의/멀티미디어';
      case CarOptionCategory.exterior: return '외관/내장';
    }
  }
}

class CarOption {
  final String id;
  final String name;
  final String emoji;
  final CarOptionCategory category;
  final bool isMain; // 주요옵션 여부

  const CarOption({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    this.isMain = false,
  });
}

class AdditionalOption {
  final String name;
  final int price; // 만원 단위
  const AdditionalOption({required this.name, required this.price});
}

// 전체 옵션 마스터 리스트
const List<CarOption> kCarOptions = [
  // ── 시트 ──
  CarOption(id: 'leather_seat',  name: '가죽시트',    emoji: '🛋',  category: CarOptionCategory.seat, isMain: true),
  CarOption(id: 'ventilated',    name: '통풍시트',    emoji: '💺',  category: CarOptionCategory.seat, isMain: true),
  CarOption(id: 'heated_seat',   name: '열선시트',    emoji: '🔥',  category: CarOptionCategory.seat, isMain: true),
  CarOption(id: 'memory_seat',   name: '메모리시트',  emoji: '💾',  category: CarOptionCategory.seat),
  CarOption(id: 'massage_seat',  name: '마사지시트',  emoji: '💆',  category: CarOptionCategory.seat),
  CarOption(id: 'power_seat',    name: '전동시트',    emoji: '🔌',  category: CarOptionCategory.seat),
  // ── 안전 ──
  CarOption(id: 'rear_cam',      name: '후방카메라',  emoji: '📷',  category: CarOptionCategory.safety, isMain: true),
  CarOption(id: 'parking_sensor',name: '주차센서',    emoji: '🚗',  category: CarOptionCategory.safety, isMain: true),
  CarOption(id: 'around_view',   name: '어라운드뷰',  emoji: '🔭',  category: CarOptionCategory.safety),
  CarOption(id: 'lane_alert',    name: '차선이탈경보', emoji: '⚠️', category: CarOptionCategory.safety),
  CarOption(id: 'abs',           name: 'ABS',         emoji: '🛑',  category: CarOptionCategory.safety),
  CarOption(id: 'esc',           name: 'ESC',         emoji: '🔄',  category: CarOptionCategory.safety),
  CarOption(id: 'airbag',        name: '에어백',      emoji: '🎈',  category: CarOptionCategory.safety),
  CarOption(id: 'blind_spot',    name: '사각지대경보', emoji: '👁',  category: CarOptionCategory.safety),
  CarOption(id: 'auto_brake',    name: '긴급자동제동', emoji: '🚨',  category: CarOptionCategory.safety),
  CarOption(id: 'adaptive_cc',   name: '어댑티브CC',  emoji: '🏎',  category: CarOptionCategory.safety),
  // ── 편의/멀티미디어 ──
  CarOption(id: 'sunroof',       name: '선루프',      emoji: '🌞',  category: CarOptionCategory.convenience, isMain: true),
  CarOption(id: 'smart_key',     name: '스마트키',    emoji: '🔑',  category: CarOptionCategory.convenience, isMain: true),
  CarOption(id: 'navi',          name: '내비게이션',  emoji: '🧭',  category: CarOptionCategory.convenience, isMain: true),
  CarOption(id: 'auto_ac',       name: '자동에어컨',  emoji: '❄️',  category: CarOptionCategory.convenience, isMain: true),
  CarOption(id: 'led_head',      name: 'LED헤드램프', emoji: '💡',  category: CarOptionCategory.convenience, isMain: true),
  CarOption(id: 'bluetooth',     name: '블루투스',    emoji: '📶',  category: CarOptionCategory.convenience),
  CarOption(id: 'usb',           name: 'USB',         emoji: '🔌',  category: CarOptionCategory.convenience),
  CarOption(id: 'wireless_charge',name: '무선충전',   emoji: '⚡',  category: CarOptionCategory.convenience),
  CarOption(id: 'hud',           name: 'HUD',         emoji: '📺',  category: CarOptionCategory.convenience),
  CarOption(id: 'remote_start',  name: '원격시동',    emoji: '📡',  category: CarOptionCategory.convenience),
  CarOption(id: 'auto_trunk',    name: '전동트렁크',  emoji: '🧳',  category: CarOptionCategory.convenience),
  CarOption(id: 'panorama',      name: '파노라마선루프',emoji: '🌅', category: CarOptionCategory.convenience),
  // ── 외관/내장 ──
  CarOption(id: 'alloy_wheel',   name: '알로이휠',    emoji: '⚙️',  category: CarOptionCategory.exterior),
  CarOption(id: 'darkfilm',      name: '선팅',        emoji: '🕶',  category: CarOptionCategory.exterior),
  CarOption(id: 'sport_mode',    name: '스포츠모드',  emoji: '🏁',  category: CarOptionCategory.exterior),
  CarOption(id: 'ambient_light', name: '앰비언트라이트',emoji: '🌈', category: CarOptionCategory.exterior),
];

List<CarOption> get kMainOptions => kCarOptions.where((o) => o.isMain).toList();

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
  int mileage;         // mutable
  int price;           // mutable for price editing
  final String fuel;
  final String transmission;
  String color;        // mutable
  bool hasAccident;    // mutable
  String region;       // mutable
  final String sellerName;
  final String sellerPhone;
  final String sellerType;    // 'individual' | 'dealer'
  final int? storeId;         // 점포 연동
  final List<String> photoUrls;
  String desc;         // mutable
  final DateTime createdAt;
  bool isFavorite;
  bool isSold;           // 판매완료 여부
  bool isCertified;      // 협회 인증 배지
  List<String> selectedOptions;     // option id 목록
  List<AdditionalOption> additionalOptions; // 유료 추가옵션

  // ── 게시물 통계 & 소유 정보 ──
  int viewCount;          // 조회수
  int inquiryCount;       // 1:1 문의 수
  String? ownerId;        // 소유자 ID (로그인 사용자 구분용)
  bool isMyListing;       // 내가 등록한 매물 여부
  DateTime? lastInquiryAt; // 마지막 문의 시각
  String listingStatus;   // 'active' | 'sold' | 'hidden'

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
    List<String>? selectedOptions,
    List<AdditionalOption>? additionalOptions,
    this.viewCount = 0,
    this.inquiryCount = 0,
    this.ownerId,
    this.isMyListing = false,
    this.lastInquiryAt,
    this.listingStatus = 'active',
  })  : selectedOptions = selectedOptions ?? [],
        additionalOptions = additionalOptions ?? [];
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
        selectedOptions: ['sunroof','ventilated','heated_seat','smart_key','navi','auto_ac','led_head','rear_cam','parking_sensor','leather_seat','blind_spot','wireless_charge'],
        additionalOptions: [
          AdditionalOption(name: '스마트센스 패키지', price: 46),
          AdditionalOption(name: '프리미엄 화이트 펄 컬러', price: 10),
        ],
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
        selectedOptions: ['sunroof','heated_seat','leather_seat','smart_key','navi','auto_ac','rear_cam','parking_sensor','memory_seat','hud','around_view'],
        additionalOptions: [AdditionalOption(name: '하이 컴포트 패키지', price: 46)],
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
        isMyListing: true, ownerId: 'me', viewCount: 12, inquiryCount: 2,
        photoUrls: [
          'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=600&q=80',
          'https://images.unsplash.com/photo-1617531653332-bd46c16f4d68?w=600&q=80',
        ],
        desc: 'M스포츠패키지 장착. 순정 상태 유지. 직거래 선호합니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        selectedOptions: ['leather_seat','heated_seat','sunroof','smart_key','navi','rear_cam','parking_sensor','sport_mode','alloy_wheel','led_head'],
        additionalOptions: [AdditionalOption(name: 'M스포츠패키지', price: 120)],
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
        selectedOptions: ['navi','auto_ac','leather_seat','heated_seat','ventilated','smart_key','rear_cam','around_view','wireless_charge','ambient_light','auto_trunk'],
        additionalOptions: [
          AdditionalOption(name: '완전자율주행(FSD) 패키지', price: 900),
          AdditionalOption(name: '퍼포먼스 업그레이드', price: 200),
        ],
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
        isMyListing: true, ownerId: 'me', viewCount: 5, inquiryCount: 1,
        photoUrls: [
          'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=600&q=80',
        ],
        desc: '무사고 2인 소유. 정기 점검 이력 완비. 가격 협의 가능합니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        selectedOptions: ['sunroof','smart_key','navi','auto_ac','rear_cam','heated_seat','leather_seat'],
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
        selectedOptions: ['leather_seat','ventilated','heated_seat','memory_seat','massage_seat','sunroof','panorama','smart_key','navi','auto_ac','led_head','rear_cam','around_view','blind_spot','hud','wireless_charge','auto_trunk','ambient_light'],
        additionalOptions: [
          AdditionalOption(name: '실키 화이트 펄 컬러', price: 10),
          AdditionalOption(name: '아방가르드 플러스 패키지', price: 85),
          AdditionalOption(name: '드라이빙 어시스턴트 패키지', price: 46),
        ],
      ),
    ]);
  }

  // ── 매물 수정 ──
  void updateListing(String listingId, {
    int? price,
    String? desc,
    int? mileage,
    String? color,
    String? region,
    bool? hasAccident,
    List<String>? photoUrls,
    List<String>? selectedOptions,
    String? listingStatus,
  }) {
    try {
      final l = listings.firstWhere((l) => l.listingId == listingId);
      if (price != null) l.price = price;
      if (desc != null) l.desc = desc;
      if (mileage != null) l.mileage = mileage;
      if (color != null) l.color = color;
      if (region != null) l.region = region;
      if (hasAccident != null) l.hasAccident = hasAccident;
      if (photoUrls != null) { l.photoUrls.clear(); l.photoUrls.addAll(photoUrls); }
      if (selectedOptions != null) { l.selectedOptions.clear(); l.selectedOptions.addAll(selectedOptions); }
      if (listingStatus != null) l.listingStatus = listingStatus;
    } catch (_) {}
    notifyListeners();
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
      l.isSold = !l.isSold; // toggle: sold ↔ active
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

// ═══════════════════════════════════════════════════════════════
// 오토바이 데이터 모델 (v60 고도화)
// ═══════════════════════════════════════════════════════════════

// ── 점포 유형 ──
enum MotoShopType { repair, inspection, sale, parts, tuning, accident, transport, electric }
extension MotoShopTypeExt on MotoShopType {
  String get label {
    switch (this) {
      case MotoShopType.repair:     return '정비';
      case MotoShopType.inspection: return '검사';
      case MotoShopType.sale:       return '판매';
      case MotoShopType.parts:      return '용품';
      case MotoShopType.tuning:     return '튜닝';
      case MotoShopType.accident:   return '사고수리';
      case MotoShopType.transport:  return '탁송';
      case MotoShopType.electric:   return '전기이륜';
    }
  }
}

// ── 점포 댓글 ──
class MotoShopComment {
  final String id;
  final String authorName;
  final String content;
  final DateTime createdAt;
  MotoShopComment({required this.id, required this.authorName, required this.content, required this.createdAt});
}

// ── 점포 ──
class MotoShop {
  final String shopId;
  final String name;
  final MotoShopType type;
  final String region;
  final String phone;
  final String address;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isCertified;
  final bool isClubPartner;
  final bool hasInspection;
  final bool hasElectric;
  final List<String> brands;
  final List<String> services;
  final String? youtubeUrl;
  final double lat;
  final double lng;
  int likeCount;
  final List<MotoShopComment> comments;
  MotoShop({
    required this.shopId, required this.name, required this.type,
    required this.region, required this.phone, required this.address,
    required this.imageUrl, this.rating = 4.5, this.reviewCount = 0,
    this.isCertified = false, this.isClubPartner = false,
    this.hasInspection = false, this.hasElectric = false,
    this.brands = const [], this.services = const [], this.youtubeUrl,
    this.lat = 35.8714, this.lng = 128.6014,
    this.likeCount = 0, List<MotoShopComment>? comments,
  }) : comments = comments ?? [];
}

// ── 매물 상태 ──
enum MotoListingStatus { listing, posted, inquired, negotiating, phoneable, sold, closed }
extension MotoListingStatusExt on MotoListingStatus {
  String get label {
    switch (this) {
      case MotoListingStatus.listing:     return '등록중';
      case MotoListingStatus.posted:      return '게시중';
      case MotoListingStatus.inquired:    return '문의도착';
      case MotoListingStatus.negotiating: return '협의중';
      case MotoListingStatus.phoneable:   return '전화가능';
      case MotoListingStatus.sold:        return '판매완료';
      case MotoListingStatus.closed:      return '거래종료';
    }
  }
  Color get color {
    switch (this) {
      case MotoListingStatus.listing:     return const Color(0xFF90A4AE);
      case MotoListingStatus.posted:      return const Color(0xFF4FC3F7);
      case MotoListingStatus.inquired:    return const Color(0xFFFF6B35);
      case MotoListingStatus.negotiating: return const Color(0xFFFFD54F);
      case MotoListingStatus.phoneable:   return const Color(0xFF10B981);
      case MotoListingStatus.sold:        return const Color(0xFFE63946);
      case MotoListingStatus.closed:      return const Color(0xFF546E7A);
    }
  }
}

// ── 매물 댓글 ──
class MotoListingComment {
  final String id;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  MotoListingComment({required this.id, required this.authorName, required this.content, required this.createdAt, this.parentId});
}

// ── 매물 ──
class MotoListing {
  final String listingId;
  final String manufacturer;
  final String model;
  final int displacement;
  final String year;
  int mileage;
  int price;
  final String region;
  String desc;
  final bool accidentFlag;
  final String accidentDetail;
  final bool tuningFlag;
  final String tuningDetail;
  final String inspectionStatus;
  final String documentStatus;
  final String color;
  final bool isOriginal;
  final String tireCondition;
  final String brakeCondition;
  final String batteryCondition;
  final String recentParts;
  final String contactPreference;
  List<String> photoUrls;
  MotoListingStatus status;
  bool isMyListing;
  bool isFavorite;
  final String ownerId;
  int viewCount;
  int inquiryCount;
  int likeCount;
  final DateTime createdAt;
  final String recentMaintenance;
  final bool isClubRecommended;
  final bool isShopChecked;
  final List<MotoListingComment> comments;
  MotoListing({
    required this.listingId, required this.manufacturer, required this.model,
    required this.displacement, required this.year, required this.mileage,
    required this.price, required this.region, required this.desc,
    this.accidentFlag = false, this.accidentDetail = '',
    this.tuningFlag = false, this.tuningDetail = '',
    this.inspectionStatus = '정상', this.documentStatus = '완비',
    required this.color, this.isOriginal = true,
    this.tireCondition = '양호', this.brakeCondition = '양호', this.batteryCondition = '양호',
    this.recentParts = '', this.contactPreference = '채팅 우선',
    this.photoUrls = const [],
    this.status = MotoListingStatus.posted, this.isMyListing = false,
    this.isFavorite = false, this.ownerId = '', this.viewCount = 0,
    this.inquiryCount = 0, this.likeCount = 0, required this.createdAt,
    this.recentMaintenance = '', this.isClubRecommended = false,
    this.isShopChecked = false, List<MotoListingComment>? comments,
  }) : comments = comments ?? [];
}

// ── 이모지 반응 ──
class EmojiReaction {
  final String emoji;
  final String label;
  int count;
  bool myReacted;
  EmojiReaction({required this.emoji, required this.label, this.count = 0, this.myReacted = false});
  static List<EmojiReaction> defaults() => [
    EmojiReaction(emoji: '👍', label: '좋아요'),
    EmojiReaction(emoji: '❤️', label: '찜'),
    EmojiReaction(emoji: '🔥', label: '인기'),
    EmojiReaction(emoji: '😮', label: '놀람'),
    EmojiReaction(emoji: '😢', label: '아쉬움'),
    EmojiReaction(emoji: '👎', label: '비추'),
  ];
}

// ── 댓글 ──
class MotoComment {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  bool isReported;
  MotoComment({required this.id, required this.authorName, this.authorAvatar = '',
    required this.content, required this.createdAt, this.parentId, this.isReported = false});
}

// ── 커뮤니티 카테고리 ──
enum MotoCommunityType { brand, region, displacement, beginner, delivery }
extension MotoCommunityTypeExt on MotoCommunityType {
  String get label {
    switch (this) {
      case MotoCommunityType.brand:        return '브랜드 모임';
      case MotoCommunityType.region:       return '지역 모임';
      case MotoCommunityType.displacement: return '배기량 모임';
      case MotoCommunityType.beginner:     return '입문자';
      case MotoCommunityType.delivery:     return '배달라이더';
    }
  }
}

// ── 동호회 멤버 권한 ──
enum MotoClubRole { owner, vice, member }
extension MotoClubRoleExt on MotoClubRole {
  String get label {
    switch (this) {
      case MotoClubRole.owner:  return '방장';
      case MotoClubRole.vice:   return '부방장';
      case MotoClubRole.member: return '멤버';
    }
  }
}

// ── 동호회 멤버 ──
class MotoClubMember {
  final String userId;
  final String name;
  final String avatarUrl;
  MotoClubRole role;
  final DateTime joinedAt;
  MotoClubMember({required this.userId, required this.name, this.avatarUrl = '',
    this.role = MotoClubRole.member, required this.joinedAt});
}

// ── 동호회 가입 방식 ──
enum MotoClubJoinType { open, approval, closed }
extension MotoClubJoinTypeExt on MotoClubJoinType {
  String get label {
    switch (this) {
      case MotoClubJoinType.open:     return '즉시 가입';
      case MotoClubJoinType.approval: return '승인 후 가입';
      case MotoClubJoinType.closed:   return '비공개';
    }
  }
}

// ── 동호회 일정 ──
class MotoClubEvent {
  final String eventId;
  final String title;
  final String description;
  final DateTime eventDate;
  final String location;
  int participantCount;
  bool myJoined;
  MotoClubEvent({required this.eventId, required this.title, required this.description,
    required this.eventDate, required this.location, this.participantCount = 0, this.myJoined = false});
}

// ── 동호회 공지 ──
class MotoClubNotice {
  final String noticeId;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isPinned;
  MotoClubNotice({required this.noticeId, required this.title, required this.content,
    required this.createdAt, this.isPinned = false});
}

// ── 동호회 게시글 ──
class MotoClubPost {
  final String postId;
  final String clubId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final List<String> photoUrls;
  final String? videoUrl;
  final bool isPinned;
  int viewCount;
  final List<EmojiReaction> reactions;
  final List<MotoComment> comments;
  final DateTime createdAt;
  MotoClubPost({
    required this.postId, required this.clubId, required this.authorName,
    this.authorAvatar = '', required this.content, this.photoUrls = const [],
    this.videoUrl, this.isPinned = false, this.viewCount = 0,
    required this.reactions, List<MotoComment>? comments, required this.createdAt,
  }) : comments = comments ?? [];
}

// ── 동호회 ──
class MotoClub {
  final String clubId;
  final String name;
  final String description;
  final MotoCommunityType category;
  final String region;
  final String coverImageUrl;
  final MotoClubJoinType joinType;
  bool isPublic;
  bool myJoined;
  bool myPendingApproval;
  final List<MotoClubMember> members;
  final List<MotoClubPost> posts;
  final List<MotoClubNotice> notices;
  final List<MotoClubEvent> events;
  int likeCount;
  MotoClub({
    required this.clubId, required this.name, required this.description,
    required this.category, required this.region, required this.coverImageUrl,
    this.joinType = MotoClubJoinType.open, this.isPublic = true,
    this.myJoined = false, this.myPendingApproval = false,
    List<MotoClubMember>? members, List<MotoClubPost>? posts,
    List<MotoClubNotice>? notices, List<MotoClubEvent>? events,
    this.likeCount = 0,
  }) : members = members ?? [], posts = posts ?? [], notices = notices ?? [], events = events ?? [];

  int get memberCount => members.length;
  MotoClubMember? get owner => members.where((m) => m.role == MotoClubRole.owner).firstOrNull;
}

// ── 커뮤니티 게시글(동호회 외부 피드용) ──
class MotoCommunityPost {
  final String postId;
  final MotoCommunityType type;
  final String authorName;
  final String title;
  final String content;
  final List<String> photoUrls;
  final String? videoUrl;
  int viewCount;
  int commentCount;
  final DateTime createdAt;
  final List<EmojiReaction> reactions;
  MotoCommunityPost({
    required this.postId, required this.type, required this.authorName,
    required this.title, required this.content,
    this.photoUrls = const [], this.videoUrl,
    this.viewCount = 0, this.commentCount = 0, required this.createdAt,
    required this.reactions,
  });
}

// ── 영상 카테고리 ──
enum MotoVideoCategory { review, repair, riding, accident, education }
extension MotoVideoCategoryExt on MotoVideoCategory {
  String get label {
    switch (this) {
      case MotoVideoCategory.review:    return '리뷰';
      case MotoVideoCategory.repair:    return '정비';
      case MotoVideoCategory.riding:    return '라이딩';
      case MotoVideoCategory.accident:  return '사고사례';
      case MotoVideoCategory.education: return '교육';
    }
  }
}

// ── 영상 ──
class MotoVideo {
  final String videoId;
  final String youtubeUrl;
  final String thumbnailUrl;
  final String title;
  final String channelName;
  final String viewCountText;
  final MotoVideoCategory category;
  MotoVideo({
    required this.videoId, required this.youtubeUrl, required this.thumbnailUrl,
    required this.title, required this.channelName, required this.viewCountText,
    required this.category,
  });
}

// ── MotoState 싱글톤 ──
class MotoState extends ChangeNotifier {
  static final MotoState _instance = MotoState._internal();
  factory MotoState() => _instance;
  MotoState._internal() { _initDummy(); }

  final List<MotoShop>  shops    = [];
  final List<MotoListing> listings = [];
  final List<MotoCommunityPost> posts = [];
  final List<MotoVideo> videos   = [];
  final List<MotoClub>  clubs    = [];

  void _initDummy() {
    _initShops();
    _initListings();
    _initPosts();
    _initVideos();
    _initClubs();
  }

  void _initShops() {
    shops.addAll([
      MotoShop(
        shopId: 'MS-001', name: '라이더팩토리 수성점',
        type: MotoShopType.repair, region: '대구 수성구',
        phone: '053-111-2222', address: '대구 수성구 달구벌대로 100',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
        rating: 4.8, reviewCount: 142, isCertified: true, isClubPartner: true,
        brands: ['혼다', '야마하', '가와사키'], services: ['엔진정비', '타이어교환', '소모품점검'],
        youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        lat: 35.8584, lng: 128.6317, likeCount: 32,
        comments: [
          MotoShopComment(id: 'SC-001', authorName: '라이더김', content: '친절하고 빠른 서비스!', createdAt: DateTime.now().subtract(const Duration(days: 2))),
          MotoShopComment(id: 'SC-002', authorName: '바이커이', content: '타이어 교환 저렴하게 잘 해줬어요', createdAt: DateTime.now().subtract(const Duration(days: 5))),
        ],
      ),
      MotoShop(
        shopId: 'MS-002', name: '바이크검사소 동구점',
        type: MotoShopType.inspection, region: '대구 동구',
        phone: '053-333-4444', address: '대구 동구 동촌로 50',
        imageUrl: 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400&q=80',
        rating: 4.6, reviewCount: 88, hasInspection: true,
        services: ['이륜차 정기검사', '배출가스 검사'],
        lat: 35.8724, lng: 128.6534, likeCount: 18,
      ),
      MotoShop(
        shopId: 'MS-003', name: '라이더마켓 중고바이크',
        type: MotoShopType.sale, region: '대구 달서구',
        phone: '053-555-6666', address: '대구 달서구 달구벌대로 200',
        imageUrl: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=400&q=80',
        rating: 4.5, reviewCount: 210, isCertified: true,
        brands: ['혼다', '야마하', '스즈키', 'BMW', '할리데이비슨'],
        services: ['중고바이크 매매', '성능점검', '탁송'],
        lat: 35.8468, lng: 128.5333, likeCount: 55,
      ),
      MotoShop(
        shopId: 'MS-004', name: '라이더용품 천국',
        type: MotoShopType.parts, region: '대구 수성구',
        phone: '053-777-8888', address: '대구 수성구 범안로 30',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
        rating: 4.7, reviewCount: 325, isClubPartner: true,
        services: ['헬멧', '자켓', '장갑', '부츠', '바이크 용품 전반'],
        lat: 35.8621, lng: 128.6248, likeCount: 41,
      ),
      MotoShop(
        shopId: 'MS-005', name: '전기이륜 e-MOTO 센터',
        type: MotoShopType.electric, region: '대구 북구',
        phone: '053-999-0000', address: '대구 북구 검단로 80',
        imageUrl: 'https://images.unsplash.com/photo-1593941707882-a5bba53b0998?w=400&q=80',
        rating: 4.9, reviewCount: 67, hasElectric: true, isCertified: true,
        services: ['전기이륜 판매', '배터리교환', '충전시설', '보조금 안내'],
        lat: 35.8842, lng: 128.5892, likeCount: 27,
      ),
    ]);
  }

  void _initListings() {
    listings.addAll([
      MotoListing(
        listingId: 'ML-001', manufacturer: '혼다', model: 'CB500F',
        displacement: 471, year: '2021년식', mileage: 8500, price: 650,
        region: '대구 수성구', color: '매트 블랙',
        desc: '순정 상태 유지. 출퇴근용으로만 사용. 직거래 우선.\n타이어 교환한 지 3개월, 오일 교환 최근 완료.\n무사고, 서류 완비.',
        inspectionStatus: '정상', documentStatus: '완비',
        isOriginal: true, tireCondition: '양호', brakeCondition: '양호', batteryCondition: '양호',
        recentParts: '타이어(2024.10), 오일(2025.01)',
        photoUrls: [
          'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=600&q=80',
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
        ],
        isMyListing: true, ownerId: 'me', viewCount: 45, inquiryCount: 3, likeCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        recentMaintenance: '타이어 교환(2024.10)', isClubRecommended: true,
      ),
      MotoListing(
        listingId: 'ML-002', manufacturer: '야마하', model: 'MT-07',
        displacement: 689, year: '2022년식', mileage: 12000, price: 890,
        region: '대구 달서구', color: '아이스 플루오로',
        desc: '익스조스트 교체 외 순정. 투어링용 탑박스 포함.\n대구 달서구 직거래 가능.',
        tuningFlag: true, tuningDetail: '슬립온 머플러',
        tireCondition: '양호', brakeCondition: '양호', batteryCondition: '양호',
        photoUrls: [
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
          'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=600&q=80',
          'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=600&q=80',
        ],
        viewCount: 87, inquiryCount: 7, likeCount: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        recentMaintenance: '오일 교환(2025.03)',
      ),
      MotoListing(
        listingId: 'ML-003', manufacturer: '가와사키', model: 'Z650',
        displacement: 649, year: '2020년식', mileage: 22000, price: 580,
        region: '대구 동구', color: '메탈릭 스파크 블랙',
        desc: '주말 라이딩 전용. 무사고. 정기점검 완비.\n서류 완비, 탁송 가능.',
        photoUrls: [
          'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=600&q=80',
        ],
        viewCount: 34, inquiryCount: 2, likeCount: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        inspectionStatus: '정상',
      ),
      MotoListing(
        listingId: 'ML-004', manufacturer: 'BMW', model: 'G310R',
        displacement: 313, year: '2023년식', mileage: 3200, price: 520,
        region: '대구 수성구', color: '스타일 엑스클루시브',
        desc: '초보도 타기 좋은 BMW 입문기. 극저주행. 거의 새 것.\n구매 후 1년 미만, 거의 안 탔습니다.',
        isOriginal: true, tireCondition: '최상', brakeCondition: '최상', batteryCondition: '최상',
        photoUrls: [
          'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=600&q=80',
          'https://images.unsplash.com/photo-1593941707882-a5bba53b0998?w=600&q=80',
        ],
        viewCount: 120, inquiryCount: 11, likeCount: 23,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        isClubRecommended: true,
      ),
    ]);
  }

  void _initPosts() {
    posts.addAll([
      MotoCommunityPost(
        postId: 'MP-001', type: MotoCommunityType.brand,
        authorName: '라이더김', title: '혼다 CB500F 1년 실사용 후기',
        content: '출퇴근 8500km 타고 나서 느낀 점 공유합니다. 연비, 유지비, 장단점 솔직 후기.',
        photoUrls: ['https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=400&q=80'],
        viewCount: 342, commentCount: 28,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        reactions: [
          EmojiReaction(emoji: '👍', label: '좋아요', count: 45),
          EmojiReaction(emoji: '❤️', label: '찜', count: 12),
          EmojiReaction(emoji: '🔥', label: '인기', count: 8),
          EmojiReaction(emoji: '😮', label: '놀람', count: 3),
          EmojiReaction(emoji: '😢', label: '아쉬움', count: 1),
          EmojiReaction(emoji: '👎', label: '비추', count: 0),
        ],
      ),
      MotoCommunityPost(
        postId: 'MP-002', type: MotoCommunityType.delivery,
        authorName: '배달이박', title: '배달용 바이크 소모품 교체 주기 정리',
        content: '타이어 6000km, 브레이크패드 8000km, 오일 3000km... 배달 라이더라면 꼭 알아야 할 정보.',
        viewCount: 788, commentCount: 56,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        reactions: [
          EmojiReaction(emoji: '👍', label: '좋아요', count: 122),
          EmojiReaction(emoji: '❤️', label: '찜', count: 34),
          EmojiReaction(emoji: '🔥', label: '인기', count: 67),
          EmojiReaction(emoji: '😮', label: '놀람', count: 5),
          EmojiReaction(emoji: '😢', label: '아쉬움', count: 2),
          EmojiReaction(emoji: '👎', label: '비추', count: 0),
        ],
      ),
      MotoCommunityPost(
        postId: 'MP-003', type: MotoCommunityType.region,
        authorName: '대구라이더', title: '이번 주말 팔공산 투어 같이 가실 분!',
        content: '토요일 오전 8시 동대구역 출발 예정. 125cc 이상 가능. 초보 환영.',
        photoUrls: ['https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80'],
        viewCount: 156, commentCount: 18,
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
        reactions: [
          EmojiReaction(emoji: '👍', label: '좋아요', count: 31),
          EmojiReaction(emoji: '❤️', label: '찜', count: 8),
          EmojiReaction(emoji: '🔥', label: '인기', count: 15),
          EmojiReaction(emoji: '😮', label: '놀람', count: 0),
          EmojiReaction(emoji: '😢', label: '아쉬움', count: 0),
          EmojiReaction(emoji: '👎', label: '비추', count: 0),
        ],
      ),
      MotoCommunityPost(
        postId: 'MP-004', type: MotoCommunityType.beginner,
        authorName: '입문자이', title: '바이크 입문 2주차 - 클러치 드디어 됐어요!',
        content: '처음에는 반클러치가 뭔지도 몰랐는데 이제 조금씩 느낌이 오네요. 응원해주세요!',
        viewCount: 234, commentCount: 42,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        reactions: [
          EmojiReaction(emoji: '👍', label: '좋아요', count: 89),
          EmojiReaction(emoji: '❤️', label: '찜', count: 22),
          EmojiReaction(emoji: '🔥', label: '인기', count: 11),
          EmojiReaction(emoji: '😮', label: '놀람', count: 4),
          EmojiReaction(emoji: '😢', label: '아쉬움', count: 1),
          EmojiReaction(emoji: '👎', label: '비추', count: 0),
        ],
      ),
    ]);
  }

  void _initVideos() {
    videos.addAll([
      MotoVideo(videoId: 'V-001', youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        thumbnailUrl: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=400&q=80',
        title: '2024 혼다 CB500F 실제 시승 리뷰 - 초보라이더 추천?',
        channelName: '바이크리뷰TV', viewCountText: '12.4만회', category: MotoVideoCategory.review),
      MotoVideo(videoId: 'V-002', youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        thumbnailUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
        title: '오토바이 엔진오일 직접 교환하는 법 (풀영상)',
        channelName: '라이더정비소', viewCountText: '8.2만회', category: MotoVideoCategory.repair),
      MotoVideo(videoId: 'V-003', youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        thumbnailUrl: 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400&q=80',
        title: '[안전교육] 빗길 라이딩 시 절대 하면 안 되는 행동 5가지',
        channelName: '안전라이딩연구소', viewCountText: '34.7만회', category: MotoVideoCategory.education),
      MotoVideo(videoId: 'V-004', youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        thumbnailUrl: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=400&q=80',
        title: '배달라이더 필수! 타이어 마모 직접 확인하는 법',
        channelName: '배달라이더TV', viewCountText: '5.6만회', category: MotoVideoCategory.education),
      MotoVideo(videoId: 'V-005', youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        thumbnailUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
        title: '대구-경주 라이딩 코스 추천 BEST 3 (4K 풀영상)',
        channelName: '대구라이더클럽', viewCountText: '2.1만회', category: MotoVideoCategory.riding),
      MotoVideo(videoId: 'V-006', youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        thumbnailUrl: 'https://images.unsplash.com/photo-1593941707882-a5bba53b0998?w=400&q=80',
        title: '[정비기초] 체인 청소 & 루브 방법 완전정복',
        channelName: '라이더정비소', viewCountText: '3.1만회', category: MotoVideoCategory.repair),
    ]);
  }

  void _initClubs() {
    clubs.addAll([
      MotoClub(
        clubId: 'MC-001', name: '대구 혼다 라이더즈',
        description: '대구/경북 혼다 바이크 동호회. 매주 주말 투어 진행.',
        category: MotoCommunityType.brand, region: '대구/경북',
        coverImageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
        joinType: MotoClubJoinType.open, isPublic: true, myJoined: true,
        likeCount: 120,
        members: [
          MotoClubMember(userId: 'me', name: '나', role: MotoClubRole.member, joinedAt: DateTime.now().subtract(const Duration(days: 30))),
          MotoClubMember(userId: 'u1', name: '대구라이더', role: MotoClubRole.owner, joinedAt: DateTime.now().subtract(const Duration(days: 365))),
          MotoClubMember(userId: 'u2', name: '바이커김', role: MotoClubRole.vice, joinedAt: DateTime.now().subtract(const Duration(days: 200))),
          MotoClubMember(userId: 'u3', name: '라이더박', role: MotoClubRole.member, joinedAt: DateTime.now().subtract(const Duration(days: 60))),
        ],
        notices: [
          MotoClubNotice(noticeId: 'N-001', title: '5월 팔공산 투어 공지', content: '5월 10일(토) 오전 8시 동대구역 집결. 참여 신청은 일정 탭에서!', createdAt: DateTime.now().subtract(const Duration(days: 3)), isPinned: true),
        ],
        events: [
          MotoClubEvent(eventId: 'E-001', title: '5월 팔공산 투어', description: '봄 라이딩 정기 투어', eventDate: DateTime.now().add(const Duration(days: 14)), location: '동대구역 1번 출구', participantCount: 12, myJoined: true),
          MotoClubEvent(eventId: 'E-002', title: '정기 번개 모임', description: '달서구 맛집 투어', eventDate: DateTime.now().add(const Duration(days: 7)), location: '달서구 진천역', participantCount: 6),
        ],
        posts: [
          MotoClubPost(
            postId: 'CP-001', clubId: 'MC-001', authorName: '대구라이더',
            content: '이번 주말 팔공산 투어 사진 공유합니다. 날씨 너무 좋았어요!',
            photoUrls: ['https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=400&q=80', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80'],
            isPinned: false, viewCount: 145,
            reactions: [EmojiReaction(emoji: '👍', label: '좋아요', count: 32), EmojiReaction(emoji: '❤️', label: '찜', count: 12), EmojiReaction(emoji: '🔥', label: '인기', count: 8), EmojiReaction(emoji: '😮', label: '놀람', count: 2), EmojiReaction(emoji: '😢', label: '아쉬움', count: 0), EmojiReaction(emoji: '👎', label: '비추', count: 0)],
            comments: [
              MotoComment(id: 'c1', authorName: '바이커김', content: '오 멋지네요! 다음엔 저도 같이 가겠습니다', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
              MotoComment(id: 'c2', authorName: '라이더박', content: '다음 투어 일정도 빨리 올려주세요!', createdAt: DateTime.now().subtract(const Duration(hours: 1))),
            ],
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          MotoClubPost(
            postId: 'CP-002', clubId: 'MC-001', authorName: '바이커김',
            content: '오늘 엔진오일 교환했어요. 라이더팩토리 수성점 추천합니다!',
            photoUrls: [],
            viewCount: 87,
            reactions: [EmojiReaction(emoji: '👍', label: '좋아요', count: 15), EmojiReaction(emoji: '❤️', label: '찜', count: 3), EmojiReaction(emoji: '🔥', label: '인기', count: 2), EmojiReaction(emoji: '😮', label: '놀람', count: 0), EmojiReaction(emoji: '😢', label: '아쉬움', count: 0), EmojiReaction(emoji: '👎', label: '비추', count: 0)],
            createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          ),
        ],
      ),
      MotoClub(
        clubId: 'MC-002', name: '대구 배달라이더 모임',
        description: '대구 배달 종사자 모임. 정비 할인, 안전 정보, 긴급 지원.',
        category: MotoCommunityType.delivery, region: '대구',
        coverImageUrl: 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=600&q=80',
        joinType: MotoClubJoinType.approval, isPublic: true, myJoined: false,
        likeCount: 89,
        members: [
          MotoClubMember(userId: 'u4', name: '배달왕김', role: MotoClubRole.owner, joinedAt: DateTime.now().subtract(const Duration(days: 400))),
          MotoClubMember(userId: 'u5', name: '라이더최', role: MotoClubRole.member, joinedAt: DateTime.now().subtract(const Duration(days: 100))),
          MotoClubMember(userId: 'u6', name: '배달박', role: MotoClubRole.member, joinedAt: DateTime.now().subtract(const Duration(days: 50))),
        ],
        posts: [
          MotoClubPost(
            postId: 'CP-003', clubId: 'MC-002', authorName: '배달왕김',
            content: '이번 달 라이더팩토리 제휴 할인 행사 진행중. 회원증 보여주면 20% 할인!',
            photoUrls: [],
            viewCount: 234,
            reactions: [EmojiReaction(emoji: '👍', label: '좋아요', count: 67), EmojiReaction(emoji: '❤️', label: '찜', count: 14), EmojiReaction(emoji: '🔥', label: '인기', count: 22), EmojiReaction(emoji: '😮', label: '놀람', count: 3), EmojiReaction(emoji: '😢', label: '아쉬움', count: 0), EmojiReaction(emoji: '👎', label: '비추', count: 0)],
            createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          ),
        ],
      ),
      MotoClub(
        clubId: 'MC-003', name: '입문자 바이크 스쿨',
        description: '바이크 처음 타시는 분들을 위한 동호회. 기초 교육, 멘토링 제공.',
        category: MotoCommunityType.beginner, region: '대구',
        coverImageUrl: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=600&q=80',
        joinType: MotoClubJoinType.open, isPublic: true, myJoined: false,
        likeCount: 74,
        members: [
          MotoClubMember(userId: 'u7', name: '멘토최', role: MotoClubRole.owner, joinedAt: DateTime.now().subtract(const Duration(days: 300))),
          MotoClubMember(userId: 'u8', name: '입문자이', role: MotoClubRole.member, joinedAt: DateTime.now().subtract(const Duration(days: 14))),
        ],
        posts: [],
      ),
    ]);
  }

  // ── 이모지 반응 토글 ──
  void toggleReaction(String postId, int reactionIndex) {
    try {
      final post = posts.firstWhere((p) => p.postId == postId);
      final r = post.reactions[reactionIndex];
      if (r.myReacted) { r.myReacted = false; r.count--; }
      else {
        for (var rx in post.reactions) { if (rx.myReacted) { rx.myReacted = false; rx.count--; } }
        r.myReacted = true; r.count++;
      }
    } catch (_) {}
    notifyListeners();
  }

  // ── 동호회 게시글 이모지 토글 ──
  void toggleClubPostReaction(String clubId, String postId, int reactionIndex) {
    try {
      final club = clubs.firstWhere((c) => c.clubId == clubId);
      final post = club.posts.firstWhere((p) => p.postId == postId);
      final r = post.reactions[reactionIndex];
      if (r.myReacted) { r.myReacted = false; r.count--; }
      else {
        for (var rx in post.reactions) { if (rx.myReacted) { rx.myReacted = false; rx.count--; } }
        r.myReacted = true; r.count++;
      }
    } catch (_) {}
    notifyListeners();
  }

  // ── 동호회 댓글 추가 ──
  void addClubComment(String clubId, String postId, MotoComment comment) {
    try {
      final club = clubs.firstWhere((c) => c.clubId == clubId);
      final post = club.posts.firstWhere((p) => p.postId == postId);
      post.comments.add(comment);
    } catch (_) {}
    notifyListeners();
  }

  // ── 동호회 가입 ──
  void joinClub(String clubId) {
    try {
      final club = clubs.firstWhere((c) => c.clubId == clubId);
      if (club.joinType == MotoClubJoinType.open) {
        club.myJoined = true;
        club.members.add(MotoClubMember(userId: 'me', name: '나', joinedAt: DateTime.now()));
      } else {
        club.myPendingApproval = true;
      }
    } catch (_) {}
    notifyListeners();
  }

  // ── 동호회 게시글 추가 ──
  void addClubPost(String clubId, MotoClubPost post) {
    try {
      final club = clubs.firstWhere((c) => c.clubId == clubId);
      club.posts.insert(0, post);
    } catch (_) {}
    notifyListeners();
  }

  // ── 동호회 개설 ──
  void createClub(MotoClub club) {
    clubs.insert(0, club);
    notifyListeners();
  }

  // ── 매물 좋아요 ──
  void toggleListingLike(String listingId) {
    try {
      final l = listings.firstWhere((l) => l.listingId == listingId);
      l.isFavorite = !l.isFavorite;
      l.likeCount += l.isFavorite ? 1 : -1;
    } catch (_) {}
    notifyListeners();
  }

  // ── 매물 댓글 추가 ──
  void addListingComment(String listingId, MotoListingComment comment) {
    try {
      final l = listings.firstWhere((l) => l.listingId == listingId);
      l.comments.add(comment);
    } catch (_) {}
    notifyListeners();
  }

  // ── 게시글 추가 ──
  void addPost(MotoCommunityPost post) { posts.insert(0, post); notifyListeners(); }

  // ── 매물 추가 ──
  void addListing(MotoListing listing) { listings.insert(0, listing); notifyListeners(); }
}
