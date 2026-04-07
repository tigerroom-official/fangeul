# Banner Ad Day 7 → Day 0 (Onboarding Guard + RC) Migration

**Date**: 2026-04-06
**Decision**: Expert Panel 만장일치 Day 7 폐지 + Codex 교차 리뷰 확인
**Option**: B (온보딩 가드 + Remote Config `banner_delay_days`)

---

## 배경

- 현재: 설치 후 7일간 배너 숨김 (`daysSince < 7`)
- 문제: 유틸리티 앱 Day 7 리텐션 12~15% → 설치자의 85%+가 배너 한 번 못 보고 이탈
- 외부 ASO 전문가 + 패널 5인 만장일치: Day 7은 과도한 보호, 수익 자해

## 설계

### 가드 조건 변경

**Before:**
```dart
if (daysSince < 7 || isUnlocked || sessionHidden || hasPurchase) return;
```

**After:**
```dart
if (!onboardingDone || daysSince < rcBannerDelayDays || isUnlocked || sessionHidden || hasPurchase) return;
```

- RC `banner_delay_days` 기본값 0 → `daysSince < 0`은 항상 false → 온보딩 가드만 작동
- 문제 시 Firebase Console에서 값을 7로 올리면 코드 변경 없이 원래 동작 복원

### 변경 파일

| # | 파일 | 변경 내용 |
|---|------|----------|
| 1 | `lib/core/entities/remote_config_values.dart` | `bannerDelayDays` 필드 추가 (int, default 0) |
| 2 | `lib/services/firebase_remote_config_service.dart` | `setDefaults`에 `banner_delay_days` 추가 + 값 읽기 |
| 3 | `lib/services/noop_remote_config_service.dart` | NoOp에서도 기본값 반환 확인 |
| 4 | `lib/presentation/providers/onboarding_providers.dart` | `isOnboardingDoneProvider` 신규 생성 (SharedPreferences 기반) |
| 5 | `lib/presentation/widgets/banner_ad_widget.dart` | 2곳(line 78 `_tryLoadAdIfNeeded`, line 119 `build`) 가드 조건 교체 |
| 6 | `test/presentation/widgets/banner_ad_widget_test.dart` | Day 7 경계 테스트 → 온보딩+RC 기반으로 재작성 |
| 7 | `.claude/rules/00-project.md` | 광고 정책: "Day 7부터" → "온보딩 완료 후 즉시" |

### 새 Provider: `isOnboardingDoneProvider`

```dart
@Riverpod(keepAlive: true)
bool isOnboardingDone(IsOnboardingDoneRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('onboarding_done') ?? false;
}
```

- `keepAlive: true` — 앱 실행 중 dispose 방지
- SharedPreferences는 이미 main.dart에서 초기화 후 override됨

### RemoteConfigValues 변경

```dart
RemoteConfigValues({
  // ... 기존 7개 필드
  this.bannerDelayDays = 0,  // 추가
});
final int bannerDelayDays;
```

### 유지되는 기존 조건

- `isUnlocked` (보상형 테마 체험 중) → 배너 숨김 유지
- `sessionHidden` (보상형 시청으로 세션 배너 제거) → 유지
- `hasPurchase` (IAP 구매) → 배너 숨김 유지

## 테스트 계획

### 삭제할 테스트
- "should hide when install date < 7 days"
- "should show when exactly Day 7"

### 추가/변경할 테스트
- "should hide when onboarding not done" (RC 0)
- "should show when onboarding done and RC 0"
- "should hide when onboarding done but daysSince < rcBannerDelayDays"
- "should show when onboarding done and daysSince >= rcBannerDelayDays"
- 기존 보상형/세션/IAP 숨김 테스트 → onboarding=true 전제로 유지

## 롤백 전략

- Firebase Console에서 `banner_delay_days` = 7 → 원래 동작 복원
- 앱 업데이트 불필요, 즉시 적용 (RC fetch interval 1시간)

## 검증 기준

- 성공: Day 1~7 배너 노출 수 > 0, Day 7 리텐션 하락 없음 (±2%)
- 실패 시그널: 1성 리뷰 "광고" 키워드 급증, Day 1 리텐션 5%+ 하락
