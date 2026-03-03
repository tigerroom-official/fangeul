import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/core/repositories/monetization_repository.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';
import 'package:fangeul/data/repositories/monetization_repository_impl.dart';

part 'monetization_provider.g.dart';

/// FlutterSecureStorage 인스턴스 Provider.
///
/// 테스트에서 mock으로 override 가능.
@Riverpod(keepAlive: true)
FlutterSecureStorage monetizationStorage(MonetizationStorageRef ref) =>
    const FlutterSecureStorage();

/// 수익화 상태를 관리하는 중앙 Notifier.
///
/// 허니문, 보상형 광고, IAP, D-day 해금, TTS 제한 등
/// 모든 수익화 관련 상태를 [MonetizationState]로 통합 관리한다.
/// SecureStorage + HMAC 기반으로 변조를 방어한다.
@Riverpod(keepAlive: true)
class MonetizationNotifier extends _$MonetizationNotifier {
  late MonetizationRepository _repository;

  /// 일일 보상형 광고 시청 제한.
  static const int dailyAdLimit = 3;

  /// 광고 시청 간 쿨다운 (5분, 밀리초).
  static const int cooldownMs = 5 * 60 * 1000;

  /// 보상형 해금 지속 시간 (4시간, 밀리초).
  static const int unlockDurationMs = 4 * 60 * 60 * 1000;

  /// 허니문 종료 후 기본 즐겨찾기 슬롯 제한.
  static const int defaultSlotLimit = 3;

  /// 일일 TTS 재생 제한.
  static const int dailyTtsLimit = 5;

  @override
  Future<MonetizationState> build() async {
    final storage = ref.read(monetizationStorageProvider);
    _repository = MonetizationRepositoryImpl(
      MonetizationLocalDataSource(storage),
    );
    return _repository.load();
  }

  /// 상태를 업데이트하고 lastTimestamp를 갱신한 뒤 저장소에 기록한다.
  Future<void> _updateState(MonetizationState newState) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final updated = newState.copyWith(
      lastTimestamp:
          now > newState.lastTimestamp ? now : newState.lastTimestamp,
    );
    state = AsyncData(updated);
    try {
      await _repository.save(updated);
    } catch (e) {
      debugPrint('[MonetizationNotifier] save failed — $e');
    }
  }

  /// 날짜를 'yyyy-MM-dd' 형식의 문자열로 변환한다.
  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// 설치 날짜를 설정한다 (최초 1회만).
  ///
  /// 이미 설정되어 있으면 무시한다.
  Future<void> ensureInstallDate() async {
    try {
      await future;
    } catch (_) {}
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.installDate != null) return;

    final now = DateTime.now();
    await _updateState(current.copyWith(installDate: _formatDate(now)));
  }

  /// 보상형 광고 시청을 기록한다.
  ///
  /// 일일 제한(3회) 도달 또는 쿨다운(5분) 미경과 시 false 반환.
  /// 날짜가 바뀌었으면 카운트를 자동 리셋한다.
  Future<bool> recordAdWatch() async {
    try {
      await future;
    } catch (_) {}
    var current = state.valueOrNull;
    if (current == null) return false;

    final now = DateTime.now();
    final todayStr = _formatDate(now);

    // 날짜 변경 시 카운트 리셋
    if (current.adLastResetDate != todayStr) {
      current = current.copyWith(
        adWatchCount: 0,
        adLastResetDate: todayStr,
      );
    }

    // 일일 제한 확인
    if (current.adWatchCount >= dailyAdLimit) {
      return false;
    }

    // 쿨다운 확인
    final elapsed = now.millisecondsSinceEpoch - current.lastAdWatchTimestamp;
    if (current.lastAdWatchTimestamp > 0 && elapsed < cooldownMs) {
      return false;
    }

    await _updateState(current.copyWith(
      adWatchCount: current.adWatchCount + 1,
      lastAdWatchTimestamp: now.millisecondsSinceEpoch,
      adLastResetDate: todayStr,
    ));
    return true;
  }

  /// 보상형 해금을 활성화한다.
  ///
  /// 만료 시각은 현재 + 4시간 또는 자정 중 빠른 쪽으로 설정.
  Future<void> activateRewardedUnlock() async {
    try {
      await future;
    } catch (_) {}
    final current = state.valueOrNull;
    if (current == null) return;

    final now = DateTime.now();
    final expiry = computeUnlockExpiry(now: now);
    await _updateState(current.copyWith(unlockExpiresAt: expiry));
  }

  /// 해금 만료 타임스탬프를 계산한다.
  ///
  /// min(현재 + 4시간, 다음 자정) 밀리초 반환.
  int computeUnlockExpiry({required DateTime now}) {
    final fourHoursLater = now.millisecondsSinceEpoch + unlockDurationMs;
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final midnightMs = nextMidnight.millisecondsSinceEpoch;
    return fourHoursLater < midnightMs ? fourHoursLater : midnightMs;
  }

  /// 구매 완료된 팩을 추가한다 (중복 무시).
  Future<void> addPurchasedPack(String packId) async {
    try {
      await future;
    } catch (_) {}
    final current = state.valueOrNull;
    if (current == null) return;

    if (current.purchasedPackIds.contains(packId)) return;

    await _updateState(current.copyWith(
      purchasedPackIds: [...current.purchasedPackIds, packId],
    ));
  }

  /// 허니문 기간을 종료한다.
  ///
  /// honeymoonActive를 false로, favoriteSlotLimit를 기본 제한(3)으로 설정.
  Future<void> endHoneymoon() async {
    try {
      await future;
    } catch (_) {}
    final current = state.valueOrNull;
    if (current == null) return;

    await _updateState(current.copyWith(
      honeymoonActive: false,
      favoriteSlotLimit: defaultSlotLimit,
    ));
  }

  /// 날짜가 변경되었으면 광고 시청 횟수와 TTS 재생 횟수를 리셋한다.
  Future<void> checkDailyReset({DateTime? now}) async {
    try {
      await future;
    } catch (_) {}
    final current = state.valueOrNull;
    if (current == null) return;

    final today = now ?? DateTime.now();
    final todayStr = _formatDate(today);

    var updated = current;
    bool needsUpdate = false;

    if (current.adLastResetDate != todayStr) {
      updated = updated.copyWith(
        adWatchCount: 0,
        adLastResetDate: todayStr,
      );
      needsUpdate = true;
    }

    if (current.ttsLastResetDate != todayStr) {
      updated = updated.copyWith(
        ttsPlayCount: 0,
        ttsLastResetDate: todayStr,
      );
      needsUpdate = true;
    }

    if (needsUpdate) {
      await _updateState(updated);
    }
  }

  /// D-day 해금을 활성화한다 (24시간).
  ///
  /// 중복 이벤트 또는 시간 조작 감지 시 false 반환.
  Future<bool> activateDdayUnlock({
    required String date,
    required String eventId,
  }) async {
    try {
      await future;
    } catch (_) {}
    final current = state.valueOrNull;
    if (current == null) return false;

    final key = '${date}_$eventId';

    // 중복 확인
    if (current.ddayUnlockedDates.contains(key)) {
      return false;
    }

    // 시간 조작 감지
    final now = DateTime.now().millisecondsSinceEpoch;
    if (current.lastTimestamp > 0 && now < current.lastTimestamp) {
      debugPrint('[MonetizationNotifier] time manipulation detected');
      return false;
    }

    // 24시간 해금
    final expiryMs = now + (24 * 60 * 60 * 1000);
    await _updateState(current.copyWith(
      ddayUnlockedDates: [...current.ddayUnlockedDates, key],
      unlockExpiresAt: expiryMs,
    ));
    return true;
  }

  /// 타임스탬프의 단조증가를 검증한다.
  ///
  /// 현재 저장된 lastTimestamp보다 과거 값이면 false (시간 조작 의심).
  Future<bool> validateTimestamp({required int timestamp}) async {
    try {
      await future;
    } catch (_) {}
    final current = state.valueOrNull;
    if (current == null) return false;

    return timestamp >= current.lastTimestamp;
  }

  /// TTS 재생 횟수를 기록한다.
  ///
  /// 날짜가 바뀌었으면 카운트를 자동 리셋한다.
  Future<void> recordTtsPlay() async {
    try {
      await future;
    } catch (_) {}
    var current = state.valueOrNull;
    if (current == null) return;

    final now = DateTime.now();
    final todayStr = _formatDate(now);

    // 날짜 변경 시 카운트 리셋
    if (current.ttsLastResetDate != todayStr) {
      current = current.copyWith(
        ttsPlayCount: 0,
        ttsLastResetDate: todayStr,
      );
    }

    await _updateState(current.copyWith(
      ttsPlayCount: current.ttsPlayCount + 1,
      ttsLastResetDate: todayStr,
    ));
  }

  /// 일일 광고 시청 제한에 도달했는지 확인한다.
  bool get isAdLimitReached {
    final current = state.valueOrNull;
    if (current == null) return false;
    return current.adWatchCount >= dailyAdLimit;
  }

  /// 일일 TTS 재생 제한에 도달했는지 확인한다.
  bool get isTtsLimitReached {
    final current = state.valueOrNull;
    if (current == null) return false;
    return current.ttsPlayCount >= dailyTtsLimit;
  }

  /// 보상형 해금이 현재 활성 상태인지 확인한다.
  bool get isUnlockActive {
    final current = state.valueOrNull;
    if (current == null) return false;
    return current.unlockExpiresAt > DateTime.now().millisecondsSinceEpoch;
  }
}

/// 허니문 기간 활성 여부 편의 Provider.
@riverpod
bool isHoneymoon(IsHoneymoonRef ref) {
  final asyncState = ref.watch(monetizationNotifierProvider);
  return asyncState.valueOrNull?.honeymoonActive ?? true;
}

/// 보상형 해금 활성 여부 편의 Provider.
@riverpod
bool isRewardedUnlockActive(IsRewardedUnlockActiveRef ref) {
  final asyncState = ref.watch(monetizationNotifierProvider);
  final monetizationState = asyncState.valueOrNull;
  if (monetizationState == null) return false;
  return monetizationState.unlockExpiresAt >
      DateTime.now().millisecondsSinceEpoch;
}

/// 즐겨찾기 슬롯 제한 편의 Provider.
@riverpod
int favoriteSlotLimit(FavoriteSlotLimitRef ref) {
  final asyncState = ref.watch(monetizationNotifierProvider);
  return asyncState.valueOrNull?.favoriteSlotLimit ?? 0;
}
