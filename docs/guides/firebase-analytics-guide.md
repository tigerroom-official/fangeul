# Firebase Analytics 커스텀 이벤트 실무 가이드 — Fangeul

> 앱 분석 경험이 부족한 백엔드 개발자를 위한 Firebase Analytics 커스텀 이벤트 설계/구현/분석 매뉴얼.
> Fangeul Flutter Android 앱(`com.tigerroom.fangeul`) 기준 작성.

---

## 목차
1. [Firebase Analytics 기초](#1-firebase-analytics-기초)
2. [커스텀 이벤트 설계 원칙](#2-커스텀-이벤트-설계-원칙)
3. [Fangeul 추천 커스텀 이벤트 목록](#3-fangeul-추천-커스텀-이벤트-목록)
4. [구현 방법 (Flutter 코드)](#4-구현-방법-flutter-코드)
5. [Firebase Console에서 분석하기](#5-firebase-console에서-분석하기)
6. [DebugView로 실시간 확인](#6-debugview로-실시간-확인)
7. [실전 인사이트 예시](#7-실전-인사이트-예시)

---

## 1. Firebase Analytics 기초

### 자동 수집 이벤트 vs 커스텀 이벤트

Firebase Analytics는 두 종류의 이벤트를 다룬다.

**자동 수집 이벤트** — 코드 작성 없이 SDK가 알아서 수집:
| 이벤트 | 의미 |
|--------|------|
| `first_open` | 앱 최초 실행 (설치 후 처음) |
| `session_start` | 세션 시작 (30분 비활성 후 재진입 포함) |
| `screen_view` | 화면 전환 |
| `app_update` | 앱 업데이트 후 첫 실행 |
| `os_update` | OS 업데이트 후 첫 실행 |
| `user_engagement` | 앱이 포그라운드에 있는 동안 자동 집계 |

이 이벤트만으로는 "문구를 몇 번 복사했나", "보상형 광고를 끝까지 봤나" 같은 비즈니스 메트릭을 알 수 없다.

**커스텀 이벤트** — 비즈니스 로직에 맞춰 우리가 직접 정의하고 호출:
```dart
analyticsService.logEvent('phrase_copy', {'source': 'main', 'situation': 'concert'});
```

Fangeul에는 현재 26개 커스텀 이벤트가 `lib/services/analytics_events.dart`에 정의되어 있다.

### 이벤트 파라미터 제약

| 항목 | 제한 |
|------|------|
| 이벤트당 파라미터 수 | 최대 **25개** |
| 파라미터 이름 길이 | 최대 **40자** (영문) |
| 파라미터 문자열 값 | 최대 **100자** |
| 파라미터 숫자 값 | int 또는 double |
| 프로젝트 내 고유 이벤트 이름 수 | 최대 **500개** (자동 포함) |
| 이벤트 이름 길이 | 최대 **40자** |

> 파라미터 값이 100자를 초과하면 잘린다. pack_id처럼 짧은 식별자를 쓰는 게 안전하다.

### 사용자 속성 (User Properties)

이벤트는 "행동"을 기록하고, 사용자 속성은 "사용자에게 라벨을 붙이는 것"이다.

```dart
analyticsService.setUserProperty('idol_group', 'BTS');
```

설정하면 이후 모든 이벤트에 이 사용자의 속성이 함께 태깅된다. Firebase Console에서 "BTS 팬의 평균 문구 복사 횟수"처럼 세그먼트 분석이 가능해진다.

제약:
- 프로젝트당 최대 **25개** 사용자 속성
- 이름 최대 24자, 값 최대 36자
- `firebase_`, `google_`, `ga_`로 시작하는 이름은 예약어 (사용 불가)
- Console에서 사전에 "사용자 속성 등록"을 해야 분석 가능

### 데이터 반영 딜레이

Firebase Analytics는 **배치 처리** 방식이다.

| 환경 | 반영 시간 |
|------|----------|
| DebugView (디버그 모드) | 실시간 (수 초 이내) |
| Analytics 대시보드 (프로덕션) | **최대 24시간** (보통 4~8시간) |
| BigQuery 내보내기 | **다음 날** (일 단위 배치) |

핵심: 프로덕션에서 이벤트를 보낸 직후 대시보드에 나타나지 않는 건 정상이다. 개발/테스트 중에는 반드시 DebugView를 사용한다.

### DebugView 실시간 확인 방법 (요약)

```bash
# 1. 디바이스를 디버그 모드로 설정
adb shell setprop debug.firebase.analytics.app com.tigerroom.fangeul

# 2. 앱 실행 (flutter run 또는 직접 실행)

# 3. Firebase Console > Analytics > DebugView에서 실시간 확인

# 4. 테스트 끝나면 해제
adb shell setprop debug.firebase.analytics.app .none.
```

자세한 내용은 [6장](#6-debugview로-실시간-확인)에서 다룬다.

---

## 2. 커스텀 이벤트 설계 원칙

### 이벤트 네이밍 규칙

**Firebase 규칙**: snake_case, 영문 소문자 + 숫자 + 밑줄, 영문자로 시작, 40자 이내.

**Fangeul 네이밍 패턴**: `명사_동사` 또는 `도메인_행동`

```
좋은 예:
  phrase_copy          — 문구(명사) + 복사(동사)
  ad_rewarded_complete — 광고_보상형(도메인) + 완료(동사)
  iap_start_purchase   — IAP(도메인) + 구매시작(동사)
  fav_limit_reached    — 즐겨찾기제한(도메인) + 도달(동사)

나쁜 예:
  copy                 — 뭘 복사했는지 모름
  userClickedBuyButton — camelCase, 너무 장황
  data_12              — 의미 불명
```

### 어떤 것을 추적해야 하는가

모든 사용자 행동을 추적하려고 하면 노이즈만 늘어난다. 아래 4가지 카테고리에 집중한다.

#### (1) 핵심 행동 (Key Actions)
앱의 핵심 가치를 대변하는 행동. "사용자가 이 앱을 왜 쓰는가?"에 대한 답.

- **문구 열람/복사** — 앱의 1번 존재 이유
- **TTS 재생** — 발음 학습 니즈
- **변환기 사용** — 영한 변환, 로마자 발음
- **즐겨찾기** — 개인화 깊이 지표
- **버블 사용** — 차별화 기능 채택률

#### (2) 수익 관련
돈이 어디서 나오는가, 어디서 새는가.

- **보상형 광고**: 시작 → 완료 → 실패 (완료율 = 광고 품질/유저 의도 지표)
- **IAP 구매 퍼널**: 샵 진입 → 상품 노출 → 구매 탭 → 완료/실패
- **배너 노출**: 노출 횟수 (eCPM 추정용)

#### (3) 리텐션 관련
사용자가 돌아오는가?

- **일일 방문**: app_open (자동) + 커스텀 세션 추적
- **스트릭**: 연속 사용일수 마일스톤
- **일일카드 열람/완료**: 습관 형성 지표

#### (4) 전환 관련
무료 유저가 유료 유저로 바뀌는 경로.

- **온보딩 완료율**: 첫 인상에서 이탈하지 않았는가
- **허니문 종료**: Day 14 — 제한 시작 시점 (honeymoon_ended)
- **제한 도달**: 즐겨찾기 5슬롯 포화, TTS 5회 소진
- **전환 트리거**: 팝업 표시 → CTA 클릭
- **IAP 전환**: 전환 트리거 → 샵 → 구매

### 파라미터 설계 팁

1. **식별용 파라미터는 짧게**: `pack_id: "daily_cheering"` (O) vs `pack_id: "일일 응원 문구 팩 v2"` (X)
2. **열거형이면 정해진 값만 사용**: `action: "add"` 또는 `"remove"` — 자유 텍스트 금지
3. **숫자로 넘길 수 있으면 숫자로**: `streak_count: 7` — 나중에 평균/분위수 분석 가능
4. **Console에서 분석하려면 사전 등록 필수**: 파라미터를 Console에 "이벤트 파라미터 보고서"에 등록하지 않으면 집계 불가 (BigQuery로는 등록 없이 쿼리 가능)

---

## 3. Fangeul 추천 커스텀 이벤트 목록

### 현재 구현 상태

아래 표에서 **구현 완료** 이벤트는 이미 코드에서 `logEvent()`가 호출되고 있다. **미구현(추천)** 이벤트는 아직 코드에 없지만 비즈니스 인사이트를 위해 추가를 권장한다.

### 3.1 핵심 기능 사용

| 이벤트명 | 파라미터 | 목적 | 상태 |
|---------|---------|------|------|
| `app_open` | -- | 앱 시작, DAU 추적 | 구현 완료 (`main.dart`) |
| `phrase_copy` | `source` (main/bubble), `situation` | 가장 많이 복사되는 문구/상황 | 구현 완료 (`phrase_card.dart`, `compact_phrase_tile.dart`) |
| `phrase_favorite` | `action` (add/remove) | 즐겨찾기 패턴 (추가 vs 제거 비율) | 구현 완료 (`favorite_phrases_provider.dart`) |
| `filter_change` | `filter_type` (favorites/pack/my_idol/today), `pack_id` | 탐색 패턴 (어떤 필터를 주로 쓰는가) | 구현 완료 (`compact_phrase_filter_provider.dart`) |
| `calendar_event_view` | `event_type`, `artist` | 캘린더 기능 가치 검증 | 정의 완료 (호출부 확인 필요) |
| `bubble_session_start` | -- | 버블 기능 채택률 | 구현 완료 (`bubble_providers.dart`) |
| `bubble_session_end` | `duration_sec` | 버블 세션 길이 (인게이지먼트 깊이) | 구현 완료 (`bubble_providers.dart`) |
| `phrase_view` | `pack_id`, `phrase_id`, `lang` | 문구 열람 빈도 (복사 안 하고 본 것도 추적) | **미구현 (추천)** |
| `tts_play` | `phrase_id`, `lang` | TTS 사용 빈도, 인기 문구 | **미구현 (추천)** |
| `converter_use` | `mode` (eng_to_kor/kor_to_eng/romanize), `input_length` | 변환기 모드별 선호도 | **미구현 (추천)** |
| `phrase_share` | `pack_id`, `target` (clipboard/sns) | 공유 행동 (바이럴 지표) | **미구현 (추천)** |

### 3.2 수익 퍼널

| 이벤트명 | 파라미터 | 목적 | 상태 |
|---------|---------|------|------|
| `ad_banner_impression` | -- | 배너 노출 횟수 (eCPM 역추산) | 정의 완료 |
| `ad_rewarded_start` | -- | 보상형 광고 시작 | 정의 완료 |
| `ad_rewarded_complete` | -- | 보상형 시청 완료율 | 정의 완료 |
| `ad_rewarded_failed` | -- | 보상형 실패 (네트워크/재고 부족) | 정의 완료 |
| `fan_pass_activated` | `unlock_duration_min` | 테마 체험 활성화 빈도 | 정의 완료 |
| `fan_pass_expired` | -- | 체험 만료 후 재전환 기회 | 정의 완료 |
| `iap_view_shop` | -- | 샵 화면 진입 빈도 | 정의 완료 |
| `iap_start_purchase` | `sku_id` | 구매 시작 (어떤 SKU가 인기인가) | 정의 완료 |
| `iap_purchase_success` | `sku_id`, `revenue` | 구매 완료 (매출) | 정의 완료 |
| `iap_purchase_failed` | `sku_id` | 구매 실패 (결제 이탈) | 정의 완료 |
| `iap_restore_purchase` | -- | 구매 복원 (CS 빈도) | 정의 완료 |
| `fav_limit_reached` | -- | 즐겨찾기 제한 도달 (마찰점) | 정의 완료 |
| `tts_limit_reached` | -- | TTS 제한 도달 (마찰점) | 정의 완료 |
| `conversion_trigger_shown` | `days_since_install` | 전환 팝업 표시 (노출 빈도) | 정의 완료 |
| `conversion_trigger_clicked` | -- | 전환 CTA 클릭 (전환 의도) | 정의 완료 |
| `honeymoon_ended` | `days_since_install` | 허니문 종료 시점 | 정의 완료 |
| `dday_gift_activated` | -- | D-day 선물 활성화 (리텐션 이벤트) | 정의 완료 |
| `theme_picker_open` | `source` (settings/bubble/limit_dialog) | 테마 피커 진입 경로 | **미구현 (추천)** |
| `iap_view_item` | `sku_id` | 개별 IAP 상품 조회 | **미구현 (추천)** |
| `rewarded_to_iap` | `sku_id` | 보상형 시청 후 IAP 전환 (핵심 퍼널) | **미구현 (추천)** |

### 3.3 리텐션/참여

| 이벤트명 | 파라미터 | 목적 | 상태 |
|---------|---------|------|------|
| `onboarding_complete` | `idol_selected` (bool) | 온보딩 완료율, 아이돌 선택 여부 | **미구현 (추천)** |
| `onboarding_skip` | `step` | 온보딩 이탈 단계 | **미구현 (추천)** |
| `daily_card_view` | `card_date` | 일일카드 열람 빈도 | **미구현 (추천)** |
| `daily_card_complete` | `streak_count` | 일일카드 완료 (습관 형성) | **미구현 (추천)** |
| `streak_milestone` | `streak_count` (7/14/30/100) | 스트릭 마일스톤 도달 | **미구현 (추천)** |
| `idol_select` | `idol_name` | 아이돌 선택/변경 | **미구현 (추천)** |
| `member_select` | `member_name` | 멤버 선택/변경 | **미구현 (추천)** |
| `theme_change` | `palette_name`, `is_custom` (bool) | 테마 변경 빈도/선호 팔레트 | **미구현 (추천)** |

### 3.4 추천 사용자 속성

| 속성명 | 값 예시 | 용도 |
|--------|--------|------|
| `idol_group` | `"BTS"`, `"BLACKPINK"` | 팬덤별 세그먼트 분석 |
| `preferred_lang` | `"ko"`, `"en"`, `"id"` | 언어별 행동 패턴 |
| `is_premium` | `"true"`, `"false"` | IAP 구매자 vs 무료 사용자 |
| `days_since_install` | `"7"`, `"30"` | 사용 기간별 세그먼트 (주기적 갱신) |

> 주의: 사용자 속성 값은 문자열만 지원한다. 숫자도 `"7"` 처럼 문자열로 전달해야 한다.

---

## 4. 구현 방법 (Flutter 코드)

### 현재 아키텍처

Fangeul은 추상 인터페이스 + DI 패턴으로 Analytics를 분리하고 있다.

```
lib/services/
├── analytics_service.dart              ← 추상 인터페이스 (logEvent, setUserProperty)
├── analytics_events.dart               ← 이벤트 이름 + 파라미터 키 상수
├── firebase_analytics_service.dart     ← Firebase 구현체
└── noop_analytics_service.dart         ← 개발/테스트용 (debugPrint)

lib/presentation/providers/
└── analytics_providers.dart            ← Riverpod DI (기본값 NoOp, main.dart에서 Firebase override)
```

### 4.1 AnalyticsService 추상 인터페이스

`lib/services/analytics_service.dart`:
```dart
abstract interface class AnalyticsService {
  Future<void> logEvent(String name, [Map<String, Object>? params]);
  Future<void> setUserProperty(String name, String value);
}
```

이 인터페이스 덕분에:
- 테스트에서 `NoOpAnalyticsService`를 주입하여 Firebase 의존성 없이 테스트
- 프로덕션에서 `FirebaseAnalyticsService`를 주입
- 향후 Mixpanel, Amplitude 등 다른 분석 도구로 교체 가능

### 4.2 Firebase 구현체

`lib/services/firebase_analytics_service.dart`:
```dart
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService([FirebaseAnalytics? instance])
      : _analytics = instance ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    await _analytics.logEvent(name: name, parameters: params);
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}
```

### 4.3 Provider DI 설정

`lib/presentation/providers/analytics_providers.dart`:
```dart
@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  return NoOpAnalyticsService(); // 기본값 = 개발용 NoOp
}
```

`lib/main.dart`에서 프로덕션 구현체를 override:
```dart
final analyticsService = FirebaseAnalyticsService();

final container = ProviderContainer(
  overrides: [
    analyticsServiceProvider.overrideWithValue(analyticsService),
    // ... 기타 overrides
  ],
);

// 앱 시작 이벤트 기록
container.read(analyticsServiceProvider).logEvent(AnalyticsEvents.appOpen);
```

### 4.4 이벤트 로깅 — Provider에서 vs 위젯에서

Fangeul에서는 두 가지 위치에서 이벤트를 기록한다.

**Provider(Notifier) 내부에서 로깅** — 비즈니스 로직과 함께:
```dart
// lib/presentation/providers/favorite_phrases_provider.dart
Future<bool> toggle(String phraseKo) async {
  // ... 즐겨찾기 토글 로직 ...

  ref.read(analyticsServiceProvider).logEvent(
    AnalyticsEvents.phraseFavorite,
    {AnalyticsParams.action: isRemoving ? 'remove' : 'add'},
  );
  return true;
}
```

**위젯에서 로깅** — UI 행동(버튼 탭 등)과 함께:
```dart
// lib/presentation/widgets/phrase_card.dart
onPressed: () {
  Clipboard.setData(ClipboardData(text: phrase.ko));
  ref.read(analyticsServiceProvider).logEvent(
    AnalyticsEvents.phraseCopy,
    {
      AnalyticsParams.source: 'main',
      if (phrase.situation != null)
        AnalyticsParams.situation: phrase.situation!,
    },
  );
},
```

**어디에 넣을지 판단 기준**:
| 기준 | Provider | Widget |
|------|----------|--------|
| 상태 변경을 동반하는 행동 | O (toggle, record 등) | |
| 단순 UI 행동 (복사, 탭) | | O |
| 여러 위젯에서 같은 행동 | O (중복 방지) | |
| 같은 행동이지만 출처 구분 필요 | | O (`source: 'main'` vs `'bubble'`) |

> Riverpod 규칙 준수: Widget에서는 `ref.read()`로 이벤트 핸들러 내에서만 호출. `ref.watch()`는 `build()` 메서드에서만 사용.

### 4.5 이벤트/파라미터 상수 관리

모든 이벤트 이름과 파라미터 키는 `lib/services/analytics_events.dart`에 상수로 관리한다.

```dart
class AnalyticsEvents {
  AnalyticsEvents._();
  static const appOpen = 'app_open';
  static const phraseCopy = 'phrase_copy';
  // ... 26개
}

class AnalyticsParams {
  AnalyticsParams._();
  static const packId = 'pack_id';
  static const source = 'source';
  // ... 11개
}
```

새 이벤트를 추가할 때는:
1. `AnalyticsEvents`에 상수 추가 (이름은 snake_case, 40자 이내)
2. 필요한 파라미터가 있으면 `AnalyticsParams`에 키 추가
3. Provider 또는 Widget에서 `ref.read(analyticsServiceProvider).logEvent(...)` 호출
4. DebugView로 확인

### 4.6 새 이벤트 추가 예시 — converter_use

현재 구현되어 있지 않은 `converter_use` 이벤트를 추가하는 예시.

**Step 1**: `analytics_events.dart`에 상수 추가
```dart
class AnalyticsEvents {
  // ... 기존 이벤트들 ...

  /// 변환기 사용.
  static const converterUse = 'converter_use';
}

class AnalyticsParams {
  // ... 기존 파라미터들 ...

  static const mode = 'mode';
  static const inputLength = 'input_length';
}
```

**Step 2**: `converter_providers.dart`의 `convert()` 메서드에 로깅 추가
```dart
void convert(String input, ConvertMode mode) {
  if (input.isEmpty) {
    state = const ConverterState.initial();
    return;
  }

  try {
    final output = switch (mode) { /* ... */ };

    state = ConverterState.success(input: input, output: output, mode: mode);

    // 이벤트 로깅 추가
    ref.read(analyticsServiceProvider).logEvent(
      AnalyticsEvents.converterUse,
      {
        AnalyticsParams.mode: mode.name,         // 'engToKor', 'korToEng', 'romanize'
        AnalyticsParams.inputLength: input.length, // 숫자 파라미터
      },
    );
  } catch (e) {
    state = ConverterState.error(e.toString());
  }
}
```

**Step 3**: DebugView에서 이벤트 확인 (6장 참고)

### 4.7 사용자 속성 설정 예시

아이돌 선택 시 사용자 속성을 설정하면, 이후 모든 이벤트에 이 정보가 태깅된다.

```dart
// 아이돌 선택 완료 시
ref.read(analyticsServiceProvider).setUserProperty('idol_group', 'BTS');

// IAP 구매 완료 시
ref.read(analyticsServiceProvider).setUserProperty('is_premium', 'true');
```

---

## 5. Firebase Console에서 분석하기

### 5.1 기본 대시보드

**경로**: Firebase Console > Analytics > 대시보드

기본 대시보드에서 바로 볼 수 있는 지표:

| 지표 | 의미 | Fangeul에서의 해석 |
|------|------|-------------------|
| **활성 사용자** (DAU/MAU) | 일간/월간 활성 사용자 수 | 앱 성장 추이의 기본 지표 |
| **세션 수** | 총 세션 수 | 재방문 빈도 |
| **세션당 평균 시간** | 한 번 열면 얼마나 쓰는가 | 인게이지먼트 깊이 |
| **리텐션** | D1, D7, D30 잔존율 | K-pop 앱 D7 목표: 25%+ |
| **국가/지역** | 사용자 분포 | 한국 vs 동남아 비율 확인 |

### 5.2 이벤트 대시보드

**경로**: Firebase Console > Analytics > 이벤트

이벤트 목록이 발생 횟수 순으로 정렬된다. 커스텀 이벤트도 여기에 나타난다.

#### 이벤트 클릭 시 보이는 것:
- **이벤트 수**: 기간 내 총 발생 횟수
- **사용자 수**: 해당 이벤트를 발생시킨 고유 사용자 수
- **사용자당 이벤트**: 평균 빈도 (= 이벤트 수 / 사용자 수)

#### 파라미터 분석 (중요)

Firebase Console에서 파라미터를 분석하려면 **사전 등록이 필수**다.

**등록 방법**:
1. Firebase Console > Analytics > 이벤트
2. 해당 이벤트 클릭
3. "매개변수 보고 관리" 클릭
4. "커스텀 정의 추가" 클릭
5. 파라미터 이름 입력 (예: `source`) + 유형(텍스트/숫자) 선택
6. 저장

등록 후 데이터가 쌓이기 시작한다 (등록 이전 데이터는 대시보드에서 못 봄. BigQuery에는 있음).

**Fangeul 필수 등록 파라미터 목록**:

| 이벤트 | 파라미터 | 유형 | 등록 이유 |
|--------|---------|------|----------|
| `phrase_copy` | `source` | 텍스트 | main vs bubble 비율 |
| `phrase_copy` | `situation` | 텍스트 | 인기 상황 카테고리 |
| `phrase_favorite` | `action` | 텍스트 | add vs remove 비율 |
| `filter_change` | `filter_type` | 텍스트 | 필터별 사용 빈도 |
| `filter_change` | `pack_id` | 텍스트 | 인기 팩 |
| `bubble_session_end` | `duration_sec` | 숫자 | 평균 세션 길이 |
| `iap_start_purchase` | `sku_id` | 텍스트 | SKU별 구매 시도 |
| `iap_purchase_success` | `sku_id` | 텍스트 | SKU별 매출 |
| `iap_purchase_success` | `revenue` | 숫자 | 매출액 |
| `conversion_trigger_shown` | `days_since_install` | 숫자 | 전환 트리거 시점 |
| `calendar_event_view` | `event_type` | 텍스트 | 이벤트 유형 |
| `calendar_event_view` | `artist` | 텍스트 | 인기 아티스트 |
| `fan_pass_activated` | `unlock_duration_min` | 숫자 | 해금 시간 분포 |

### 5.3 퍼널 분석

#### 전환 이벤트 설정 (Mark as Conversion)

특정 이벤트를 "전환"으로 표시하면, 전환 보고서와 Google Ads 연동에 활용된다.

**설정 방법**:
1. Firebase Console > Analytics > 이벤트
2. 해당 이벤트 우측 토글 "전환으로 표시" 활성화

**Fangeul 추천 전환 이벤트**:
- `iap_purchase_success` — 가장 중요한 비즈니스 전환
- `ad_rewarded_complete` — 광고 수익 전환
- `onboarding_complete` — 사용자 활성화 전환

#### 커스텀 퍼널: 테마 IAP 구매 퍼널

```
theme_picker_open → iap_view_shop → iap_start_purchase → iap_purchase_success
```

이 퍼널로 알 수 있는 것:
- 테마 피커를 연 사용자 중 몇 %가 샵에 진입하나?
- 샵 진입 후 구매 시도까지 몇 %가 도달하나?
- 구매 시도 중 완료율은?
- 각 단계별 이탈 원인은? (가격? UX? 결제 실패?)

#### 커스텀 퍼널: 허니문 → 전환 퍼널

```
app_open → honeymoon_ended → fav_limit_reached → conversion_trigger_shown → conversion_trigger_clicked → iap_purchase_success
```

이 퍼널로 알 수 있는 것:
- 허니문 종료 후 즐겨찾기 제한을 경험하는 비율
- 제한 경험 후 전환 팝업까지 도달하는 비율
- 팝업 클릭 후 실제 구매까지의 전환율
- 전체 무료→유료 전환율 (FTUE에서 구매까지)

#### Firebase Console에서 퍼널 만들기

**경로**: Firebase Console > Analytics > 퍼널

1. "새 퍼널 만들기" 클릭
2. 단계(Step) 추가: 각 단계에 이벤트 이름 입력
3. "열린 퍼널" vs "닫힌 퍼널" 선택
   - **열린 퍼널**: 중간 단계를 건너뛸 수 있음 (추천 — 실제 유저는 선형 경로를 따르지 않음)
   - **닫힌 퍼널**: 반드시 순서대로 거쳐야 함
4. 기간 설정 후 분석

### 5.4 사용자 세그먼트 (잠재고객)

**경로**: Firebase Console > Analytics > 잠재고객 (Audiences)

"잠재고객"은 특정 조건을 만족하는 사용자 그룹이다. 한 번 만들면 이후 데이터에 자동 적용된다.

#### 예시: "파워 유저"
```
조건:
  - 최근 7일 이내 활동한 사용자
  AND
  - phrase_copy 이벤트 7회 이상
  AND
  - phrase_favorite 이벤트 (action=add) 5회 이상
```

이 세그먼트가 전체 사용자의 몇 %인지, 이들의 리텐션은 어떤지 비교할 수 있다.

#### 예시: "전환 가능 유저"
```
조건:
  - fav_limit_reached 이벤트 1회 이상
  AND
  - iap_purchase_success 이벤트 없음 (아직 미구매)
  AND
  - ad_rewarded_complete 이벤트 1회 이상 (보상형은 써봤음)
```

이 세그먼트의 크기가 크면 전환 트리거 UX를 강화할 신호다.

#### 예시: "이탈 위험 유저"
```
조건:
  - 최근 14일 이내 활동한 사용자
  AND
  - 최근 7일 이내 활동하지 않은 사용자
```

이 그룹에 푸시 알림이나 D-day 이벤트를 집중할 수 있다.

#### 잠재고객 활용처
- **Analytics 보고서 필터**: "파워 유저의 인기 팩은?"
- **Remote Config 타겟팅**: "전환 가능 유저에게만 할인 배너 표시"
- **Google Ads 리마케팅**: "이탈 위험 유저에게 광고 재노출"
- **A/B 테스트**: "파워 유저에게만 새 기능 테스트"

### 5.5 BigQuery 연동 (고급)

Firebase Analytics는 집계된 데이터만 Console에 보여주지만, **BigQuery로 내보내면 원시(raw) 이벤트 데이터**에 접근할 수 있다.

#### 설정 방법
1. Firebase Console > 프로젝트 설정 > 통합
2. BigQuery 연동 활성화
3. Analytics 데이터 내보내기 활성화
4. 데이터셋 위치 선택 (asia-northeast3 = 서울)

#### 원시 데이터 구조

내보내진 테이블: `analytics_<앱ID>.events_YYYYMMDD`

각 행은 하나의 이벤트이며, 다음 정보를 포함:
- `event_name`: 이벤트 이름
- `event_params`: 파라미터 배열 (key-value)
- `user_properties`: 사용자 속성
- `device`: 기기 정보
- `geo`: 지역 정보
- `event_timestamp`: 이벤트 발생 시각 (마이크로초)

#### SQL 쿼리 예시

**인기 팩 TOP 5** (phrase_copy의 pack_id 파라미터 집계):
```sql
SELECT
  (SELECT value.string_value
   FROM UNNEST(event_params)
   WHERE key = 'pack_id') AS pack_id,
  COUNT(*) AS copy_count,
  COUNT(DISTINCT user_pseudo_id) AS unique_users
FROM `project.analytics_XXXXX.events_*`
WHERE event_name = 'phrase_copy'
  AND _TABLE_SUFFIX BETWEEN '20260301' AND '20260331'
GROUP BY pack_id
ORDER BY copy_count DESC
LIMIT 5;
```

**보상형 광고 완료율** (시작 대비 완료 비율):
```sql
WITH starts AS (
  SELECT COUNT(DISTINCT user_pseudo_id) AS start_users
  FROM `project.analytics_XXXXX.events_*`
  WHERE event_name = 'ad_rewarded_start'
    AND _TABLE_SUFFIX = '20260315'
),
completes AS (
  SELECT COUNT(DISTINCT user_pseudo_id) AS complete_users
  FROM `project.analytics_XXXXX.events_*`
  WHERE event_name = 'ad_rewarded_complete'
    AND _TABLE_SUFFIX = '20260315'
)
SELECT
  s.start_users,
  c.complete_users,
  ROUND(c.complete_users / s.start_users * 100, 1) AS completion_rate_pct
FROM starts s, completes c;
```

**스트릭 7일 유저의 IAP 전환율**:
```sql
WITH streak_users AS (
  SELECT DISTINCT user_pseudo_id
  FROM `project.analytics_XXXXX.events_*`
  WHERE event_name = 'streak_milestone'
    AND (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'streak_count') >= 7
),
purchasers AS (
  SELECT DISTINCT user_pseudo_id
  FROM `project.analytics_XXXXX.events_*`
  WHERE event_name = 'iap_purchase_success'
)
SELECT
  COUNT(*) AS streak_7_users,
  COUNTIF(p.user_pseudo_id IS NOT NULL) AS converted,
  ROUND(COUNTIF(p.user_pseudo_id IS NOT NULL) / COUNT(*) * 100, 1) AS conversion_pct
FROM streak_users s
LEFT JOIN purchasers p USING (user_pseudo_id);
```

> BigQuery는 월 1TB 쿼리까지 무료다. Fangeul 규모(DAU 10K)에서는 충분하다.

---

## 6. DebugView로 실시간 확인

### DebugView란?

백엔드로 비유하면 `tail -f app.log`와 같다. 개발 중 이벤트가 Firebase에 제대로 전송되는지 실시간으로 확인하는 도구다.

프로덕션 대시보드(24시간 딜레이)와 달리, DebugView는 **수 초 내**에 이벤트를 보여준다.

### 전체 흐름

```
[1] adb 명령어로 디버그 모드 활성화
              ↓
[2] 앱 실행 (flutter run 또는 실기기에서 직접 실행)
              ↓
[3] Firebase Console > Analytics > DebugView
              ↓
[4] 실시간 이벤트 타임라인 확인
              ↓
[5] 테스트 완료 후 디버그 모드 해제
```

### Step 1: 디버그 모드 활성화

```bash
# 에뮬레이터 또는 USB 연결된 실기기
adb shell setprop debug.firebase.analytics.app com.tigerroom.fangeul
```

이 명령어가 하는 일:
- 앱이 이벤트를 배치로 모아두지 않고 **즉시** Firebase 서버에 전송하도록 변경
- Firebase Console의 DebugView에 이 디바이스가 "디버그 디바이스"로 표시됨

### Step 2: 앱 실행

```bash
# 에뮬레이터에서 디버그 빌드
flutter run

# 또는 이미 설치된 앱을 직접 실행해도 됨
```

> 주의: `adb shell setprop` 실행 후 앱을 **재시작**해야 적용된다. 이미 실행 중이면 앱을 종료 후 다시 실행.

### Step 3: Firebase Console에서 확인

1. https://console.firebase.google.com 접속
2. Fangeul 프로젝트 선택
3. 왼쪽 메뉴 > **Analytics** > **DebugView**
4. 디바이스 목록에서 자신의 디바이스 선택
5. 이벤트 타임라인이 실시간으로 표시됨

#### DebugView 화면 구성
- **왼쪽**: 이벤트 타임라인 (시간순)
- **가운데**: 선택한 이벤트의 파라미터
- **오른쪽**: 사용자 속성 목록

#### 확인 방법
1. 앱에서 문구를 복사한다
2. DebugView에 `phrase_copy` 이벤트가 나타나는지 확인
3. 이벤트를 클릭해서 `source`, `situation` 파라미터 값이 정확한지 확인
4. 즐겨찾기를 토글하고 `phrase_favorite` + `action` 파라미터 확인

### Step 4: 디버그 모드 해제

```bash
adb shell setprop debug.firebase.analytics.app .none.
```

> 해제하지 않으면 프로덕션 앱에서도 즉시 전송 모드가 유지되어 배터리/데이터를 소모한다. 테스트 끝나면 반드시 해제.

### 테스트 체크리스트

출시 전에 아래 이벤트가 모두 DebugView에서 확인되어야 한다.

**핵심 기능**:
- [ ] 앱 시작 → `app_open`
- [ ] 문구 복사(메인) → `phrase_copy` + `source: main`
- [ ] 문구 복사(버블) → `phrase_copy` + `source: bubble`
- [ ] 즐겨찾기 추가 → `phrase_favorite` + `action: add`
- [ ] 즐겨찾기 제거 → `phrase_favorite` + `action: remove`
- [ ] 필터 전환 → `filter_change` + `filter_type`
- [ ] 버블 띄우기 → `bubble_session_start`
- [ ] 버블 닫기 → `bubble_session_end` + `duration_sec`

**수익화**:
- [ ] 보상형 광고 시작 → `ad_rewarded_start`
- [ ] 보상형 완료 → `ad_rewarded_complete`
- [ ] 샵 진입 → `iap_view_shop`
- [ ] 즐겨찾기 제한 도달 → `fav_limit_reached`

### 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| DebugView에 디바이스가 안 보임 | setprop 후 앱 미재시작 | 앱 종료 후 재시작 |
| | adb 연결 안 됨 | `adb devices`로 확인 |
| | 패키지명 오타 | `com.tigerroom.fangeul` 정확히 입력 |
| 이벤트가 안 나타남 | Firebase 미초기화 | `google-services.json` 확인 |
| | NoOp 구현체 사용 중 | `main.dart` override 확인 |
| | `debugPrint`만 나옴 | NoOp이 주입된 것. FirebaseAnalyticsService override 확인 |
| 파라미터가 안 보임 | 파라미터를 안 넘김 | 코드에서 logEvent 두 번째 인자 확인 |
| 이벤트가 매우 느리게 나타남 | 네트워크 지연 | Wi-Fi 확인. VPN 해제 |

---

## 7. 실전 인사이트 예시

출시 후 데이터가 쌓이면 아래와 같은 질문에 답할 수 있다.

### Q: "어떤 문구 팩이 가장 인기있는가?"

**방법**: `filter_change` 이벤트의 `pack_id` 파라미터 분포 확인
- Console > 이벤트 > `filter_change` > `pack_id` 파라미터
- 또는 `phrase_copy` 이벤트에 `pack_id`를 추가하면 "복사까지 이어지는 팩"을 직접 측정 가능

**액션**: 인기 팩에 문구를 추가하거나, 비인기 팩은 개선/제거

### Q: "보상형 광고 시청 후 IAP 전환율은?"

**방법**: 퍼널 분석
```
ad_rewarded_complete → iap_view_shop → iap_purchase_success
```
- 보상형 완료 사용자 중 샵에 진입하는 비율 = "테마 체험이 IAP 관심을 유발하는가?"
- 샵 진입 후 구매 비율 = "가격/상품 매력도"

**액션**: 전환율이 낮으면
- 보상형 → 샵 낮음: 체험 시간이 너무 길거나(24h → 12h 실험), 프리미엄 테마 차별화 부족
- 샵 → 구매 낮음: 가격 조정, 번들 프로모션, 상품 설명 개선

### Q: "허니문 14일이 적절한가?"

**방법**: `honeymoon_ended` 이벤트의 `days_since_install` 분포 + D14 이후 리텐션
- Remote Config로 A/B 테스트: A그룹 14일 vs B그룹 10일
- 비교 지표: D30 리텐션, IAP 전환율, ARPU

**액션**: 10일이 전환율 높으면서 리텐션 차이 없으면 10일로 단축

### Q: "버블 사용자 vs 비사용자의 리텐션 차이는?"

**방법**: 잠재고객 2개 생성
- "버블 사용자": `bubble_session_start` 1회 이상
- "비사용자": `bubble_session_start` 0회

두 그룹의 D7, D30 리텐션 비교.

**액션**: 버블 사용자 리텐션이 높으면, 온보딩에서 버블 사용을 적극 유도

### Q: "스트릭 7일 유저의 ARPU는?"

**방법**:
- BigQuery에서 `streak_milestone` (count >= 7) 유저 집합과 `iap_purchase_success` 유저 집합을 조인
- 스트릭 7일+ 유저의 IAP 전환율 및 평균 매출 계산

**액션**: 스트릭 유저의 ARPU가 높으면, 스트릭 유지를 위한 푸시/보상 강화

### Q: "동남아(ID/TH/VN) vs 한국 유저의 행동 차이는?"

**방법**: Console > 이벤트 > 필터 > 국가별
- 한국: `iap_purchase_success` 비율
- 동남아: `ad_rewarded_complete` 비율

**액션**: 한국=IAP 중심, 동남아=광고 중심이면 Remote Config으로 지역별 수익화 전략 분리 (예: 동남아 배너 빈도 높이기, 한국 IAP 프로모션 강화)

### Q: "즐겨찾기 제한이 IAP 전환에 효과적인가?"

**방법**: 퍼널
```
fav_limit_reached → conversion_trigger_shown → conversion_trigger_clicked → iap_purchase_success
```

- `fav_limit_reached`는 많이 발생하는데 `conversion_trigger_clicked`가 적으면 → 전환 팝업 UX 개선 필요
- `conversion_trigger_clicked`는 많은데 `iap_purchase_success`가 적으면 → 가격/상품 문제

**액션**: 퍼널 단계별 이탈률을 보고 가장 큰 병목을 해결

---

## 부록: 현재 코드 구조 & 파일 위치

### 파일 맵

```
lib/services/
├── analytics_service.dart              ← 추상 인터페이스
├── analytics_events.dart               ← 26개 이벤트 + 11개 파라미터 상수
├── firebase_analytics_service.dart     ← Firebase 구현체
├── noop_analytics_service.dart         ← 개발/테스트용 NoOp
├── ad_service.dart                     ← AdMob (배너+보상형)
├── iap_service.dart                    ← IAP 구매 플로우
└── iap_products.dart                   ← SKU 정의 (8개)

lib/presentation/providers/
├── analytics_providers.dart            ← AnalyticsService DI
├── monetization_provider.dart          ← 수익화 상태 (허니문/광고/IAP/TTS)
├── iap_provider.dart                   ← IAP 서비스 연동
├── favorite_phrases_provider.dart      ← 즐겨찾기 (logEvent 호출)
├── bubble_providers.dart               ← 버블 (logEvent 호출)
├── compact_phrase_filter_provider.dart ← 필터 (logEvent 호출)
├── converter_providers.dart            ← 변환기 (logEvent 미구현)
├── tts_provider.dart                   ← TTS (logEvent 미구현)
├── conversion_trigger_provider.dart    ← 전환 트리거 조건
├── session_state_provider.dart         ← 세션 상태 (배너 숨김 등)
└── dday_gift_provider.dart             ← D-day 선물

lib/presentation/widgets/
├── phrase_card.dart                    ← 문구 카드 (logEvent 호출: phrase_copy)
└── compact_phrase_tile.dart            ← 간편 타일 (logEvent 호출: phrase_copy)

lib/main.dart                           ← Firebase 초기화 + provider override + app_open
```

### 이벤트 로깅 위치 요약

| 이벤트 | 호출 위치 | 상태 |
|--------|----------|------|
| `app_open` | `main.dart:58` | 구현 완료 |
| `bubble_session_start` | `bubble_providers.dart:60` | 구현 완료 |
| `bubble_session_end` | `bubble_providers.dart:103` | 구현 완료 |
| `phrase_copy` | `phrase_card.dart:98`, `compact_phrase_tile.dart:211` | 구현 완료 |
| `phrase_favorite` | `favorite_phrases_provider.dart:64` | 구현 완료 |
| `filter_change` | `compact_phrase_filter_provider.dart:82,93,107,118` | 구현 완료 |
| 나머지 20개 이벤트 | `analytics_events.dart`에 정의만 됨 | 호출부 구현 필요 |

### 데이터 흐름

```
[사용자 행동 (탭, 복사, 필터 전환)]
         ↓
[Widget의 onPressed / Provider의 메서드]
         ↓
[ref.read(analyticsServiceProvider).logEvent(이벤트명, 파라미터)]
         ↓
[AnalyticsService 구현체]
  ├── NoOpAnalyticsService: debugPrint (개발)
  └── FirebaseAnalyticsService: firebase_analytics SDK (프로덕션)
         ↓
[Firebase 서버]
         ↓
[Firebase Console 대시보드 / DebugView / BigQuery]
```
