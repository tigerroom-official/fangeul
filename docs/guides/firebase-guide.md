# Firebase 가이드 — Fangeul 프로젝트

> 백엔드 개발자를 위한 Firebase Remote Config + Analytics 실전 가이드.
> 앱 분석이 처음이라도 이 문서를 따라하면 콘솔 설정부터 데이터 확인까지 할 수 있습니다.

---

## 목차
1. [Firebase 콘솔 기본 개념](#1-firebase-콘솔-기본-개념)
2. [Remote Config 설정](#2-remote-config-설정)
3. [Analytics 이해하기](#3-analytics-이해하기)
4. [Fangeul 이벤트 맵](#4-fangeul-이벤트-맵)
5. [콘솔에서 데이터 보기](#5-콘솔에서-데이터-보기)
6. [DebugView로 실시간 테스트](#6-debugview로-실시간-테스트)
7. [A/B 테스트 (나중에)](#7-ab-테스트-나중에)
8. [트러블슈팅](#8-트러블슈팅)

---

## 1. Firebase 콘솔 기본 개념

### Firebase 콘솔이란?
- URL: https://console.firebase.google.com
- 백엔드의 "관리자 대시보드"와 비슷한 개념
- 앱 코드 변경 없이 설정값 변경, 사용자 행동 분석, 크래시 모니터링 등 가능

### 우리 프로젝트 위치
- **프로젝트**: Tiger Room 계정 → Fangeul
- **앱**: Android (`com.tigerroom.fangeul`)
- `google-services.json`이 앱을 Firebase 프로젝트에 연결하는 열쇠

### 핵심 서비스 3가지
| 서비스 | 백엔드 비유 | 역할 |
|--------|-----------|------|
| **Remote Config** | 환경변수 서버 | 앱 재배포 없이 설정값 변경 |
| **Analytics** | 로그 수집 서버 | 사용자 행동 이벤트 수집 + 대시보드 |
| **Crashlytics** | 에러 모니터링 | 크래시 로그 수집 (Phase 7) |

---

## 2. Remote Config 설정

### 개념
- **서버 환경변수**와 같다. `.env` 파일을 서버에서 관리하는 것과 비슷
- 앱이 시작될 때 Firebase 서버에서 최신 값을 받아옴
- 네트워크 실패 시 → 앱에 하드코딩된 기본값 사용 (안전)

### 코드 구조 (이미 구현됨)
```
lib/core/entities/remote_config_values.dart    ← 값 모델 (기본값 포함)
lib/services/remote_config_service.dart        ← 추상 인터페이스
lib/services/firebase_remote_config_service.dart ← Firebase 구현체
lib/services/noop_remote_config_service.dart   ← 테스트용 NoOp
```

### 🔧 콘솔 설정 단계 (직접 해야 함)

#### Step 1: Remote Config 페이지 열기
1. https://console.firebase.google.com 접속
2. Fangeul 프로젝트 선택
3. 왼쪽 메뉴 → **실행** 섹션 → **Remote Config** 클릭

#### Step 2: 매개변수 7개 추가
"매개변수 추가" 버튼을 누르고, 아래 표대로 하나씩 추가:

| 매개변수 이름 | 기본값 | 설명 | 데이터 유형 |
|--------------|--------|------|------------|
| `honeymoon_days` | `14` | 허니문 기간 (일). Day 0~13 무제한 | 숫자 |
| `default_slot_limit` | `5` | 즐겨찾기 슬롯 제한 (허니문 후) | 숫자 |
| `daily_ad_limit` | `3` | 보상형 광고 일일 상한 | 숫자 |
| `ad_cooldown_minutes` | `5` | 광고 간 쿨다운 (분) | 숫자 |
| `unlock_duration_hours` | `4` | 팬 패스 해금 시간 (시간) | 숫자 |
| `daily_tts_limit` | `5` | TTS 일일 재생 제한 | 숫자 |
| `conversion_trigger_ad_count` | `3` | IAP 전환 트리거 광고 횟수 | 숫자 |

#### Step 3: 게시
- 모든 매개변수 추가 후 **"변경사항 게시"** 클릭
- 이때부터 앱이 이 값을 받아감 (최대 1시간 내, 앱 재시작 시 즉시)

#### Step 4: 검증
- 앱에서 Remote Config 값이 제대로 오는지 확인하려면:
  - 앱 실행 → 디버그 로그에서 `[RC]` 태그 확인
  - 또는 콘솔 "최근 가져오기" 탭에서 디바이스 fetch 이력 확인

### 언제 값을 바꾸나?
- **출시 후 튜닝**: "광고 3회가 너무 적다" → `daily_ad_limit: 4`로 변경 → 게시 → 끝
- **A/B 테스트**: "허니문 14일 vs 7일 중 어느 쪽이 전환율 높을까?" → 조건별 값 설정
- **긴급 대응**: "광고 서버 장애" → `daily_ad_limit: 0`으로 일시 비활성화

### 조건 (Conditions) — 나중에 활용
- **국가별**: 한국은 `daily_ad_limit: 2`, 동남아는 `5`
- **앱 버전별**: v1.0은 `honeymoon_days: 14`, v1.1은 `10`
- **사용자 세그먼트별**: Analytics에서 만든 오디언스 타겟팅

---

## 3. Analytics 이해하기

### 백엔드 로그 vs 앱 Analytics

| 개념 | 백엔드 | 앱 Analytics |
|------|--------|-------------|
| 로그 남기기 | `logger.info("user_login", {userId})` | `analytics.logEvent("app_open")` |
| 로그 보기 | ELK/Grafana 대시보드 | Firebase Analytics 대시보드 |
| 실시간 확인 | `tail -f app.log` | DebugView (실시간 이벤트 스트림) |
| 집계 | SQL 쿼리 | 자동 대시보드 + BigQuery 연동 |

### 자동 수집 이벤트 (코드 불필요)
Firebase가 알아서 수집하는 것들:
- `first_open` — 앱 첫 실행
- `session_start` — 세션 시작
- `screen_view` — 화면 전환
- `app_update` — 앱 업데이트
- `os_update` — OS 업데이트

### 커스텀 이벤트 (우리가 추가한 것)
자동 수집만으론 "문구를 몇 번 복사했나", "광고를 몇 번 봤나" 같은 비즈니스 메트릭을 모름.
→ 커스텀 이벤트 26개 정의 (`lib/services/analytics_events.dart`)

### 이벤트 구조
```
이벤트 = 이름 + 파라미터(선택)

예시:
  이벤트: "phrase_copy"
  파라미터: { source: "bubble", situation: "concert" }
```

- **이벤트 이름**: 행동 자체 (뭘 했나)
- **파라미터**: 맥락 정보 (어디서, 어떤 것을)

### 사용자 속성 (User Property)
- 이벤트와 다르게, 사용자에게 **라벨**을 붙이는 것
- 예: `setUserProperty("idol_group", "BTS")` → 이 유저는 BTS 팬
- Analytics 대시보드에서 "BTS 팬은 평균 몇 번 문구를 복사하나?" 같은 세그먼트 분석 가능

---

## 4. Fangeul 이벤트 맵

### 핵심 행동 이벤트

| 이벤트 | 의미 | 파라미터 | KPI 연관 |
|--------|------|---------|---------|
| `app_open` | 앱 시작 | — | DAU |
| `bubble_session_start` | 버블 띄움 | — | 버블 사용률 |
| `bubble_session_end` | 버블 닫음 | `duration_sec` | 세션 길이 |
| `phrase_copy` | 문구 복사 | `source`, `situation` | 핵심 행동 |
| `phrase_favorite` | 즐겨찾기 토글 | `action` (add/remove) | 인게이지먼트 |
| `filter_change` | 필터 전환 | `filter_type`, `pack_id` | 탐색 패턴 |
| `calendar_event_view` | 캘린더 조회 | `event_type`, `artist` | 캘린더 가치 |

### 수익화 이벤트

| 이벤트 | 의미 | 파라미터 | 퍼널 단계 |
|--------|------|---------|----------|
| `ad_banner_impression` | 배너 노출 | — | 인지 |
| `ad_rewarded_start` | 보상형 시작 | — | 관심 |
| `ad_rewarded_complete` | 보상형 완료 | — | 행동 |
| `ad_rewarded_failed` | 보상형 실패 | — | 이탈 |
| `fan_pass_activated` | 팬 패스 해금 | `unlock_duration_min` | 가치 경험 |
| `fan_pass_expired` | 팬 패스 만료 | — | 재전환 기회 |
| `fav_limit_reached` | 슬롯 포화 | — | 마찰점 |
| `tts_limit_reached` | TTS 제한 도달 | — | 마찰점 |
| `conversion_trigger_shown` | 전환 팝업 표시 | `days_since_install` | 전환 시도 |
| `conversion_trigger_clicked` | 전환 CTA 클릭 | — | 전환 |
| `iap_view_shop` | 샵 진입 | — | 구매 의도 |
| `iap_start_purchase` | 구매 시작 | `sku_id` | 구매 시도 |
| `iap_purchase_success` | 구매 완료 | `sku_id`, `revenue` | 매출 |
| `iap_purchase_failed` | 구매 실패 | `sku_id` | 이탈 |
| `iap_restore_purchase` | 구매 복원 | — | CS |
| `honeymoon_ended` | 허니문 종료 | `days_since_install` | 전환 시작 |
| `dday_gift_activated` | D-day 선물 | — | 리텐션 |

### 수익화 퍼널 시각화
```
[앱 사용] → [허니문 종료] → [제한 경험] → [보상형 광고] → [슬롯 포화] → [전환 트리거] → [IAP 구매]
   │            │               │              │               │              │
   │         honeymoon      fav_limit      ad_rewarded     fav_limit    conversion    iap_purchase
   │         _ended         _reached       _complete       _reached     _trigger      _success
app_open                   tts_limit                                    _shown
                           _reached
```

---

## 5. 콘솔에서 데이터 보기

### Analytics 대시보드 (출시 후)
1. Firebase 콘솔 → **Analytics** → **대시보드**
2. 기본 제공:
   - **활성 사용자**: DAU / WAU / MAU
   - **이벤트**: 각 이벤트 발생 횟수
   - **사용자 인게이지먼트**: 평균 세션 시간
   - **리텐션**: D1, D7, D30 리텐션

### 이벤트 상세 보기
1. **Analytics** → **이벤트**
2. `phrase_copy` 클릭 → 발생 횟수, 사용자 수, 파라미터별 분포
3. `ad_rewarded_complete` → 하루 평균 시청 횟수, 시간대별 분포

### 주요 확인 포인트 (출시 후 1주)

| 확인 항목 | 어디서 보나 | 건강한 수치 |
|-----------|-----------|-----------|
| DAU | 대시보드 > 활성 사용자 | 출시 첫 주 100+ |
| 문구 복사율 | 이벤트 > phrase_copy / 사용자 | DAU 대비 30%+ |
| 버블 사용률 | 이벤트 > bubble_session_start / 사용자 | DAU 대비 20%+ |
| 보상형 완료율 | ad_rewarded_complete / ad_rewarded_start | 70%+ |
| 전환율 | iap_purchase_success / conversion_trigger_shown | 3~5% |

---

## 6. DebugView로 실시간 테스트

### DebugView란?
- `tail -f` 같은 것. 실시간으로 이벤트가 들어오는 걸 보는 도구
- **개발/테스트 시 필수** — "내가 보낸 이벤트가 제대로 찍히나?" 확인

### 설정 방법

#### 1단계: 디바이스를 디버그 모드로 설정
```bash
# 에뮬레이터 또는 실기기에서 (adb 필요)
adb shell setprop debug.firebase.analytics.app com.tigerroom.fangeul
```

#### 2단계: 앱 실행
- 일반적으로 앱 실행하면 됨
- 이벤트가 실시간으로 Firebase에 전송됨 (보통 배치로 모아서 보내지만, 디버그 모드는 즉시)

#### 3단계: 콘솔에서 확인
1. Firebase 콘솔 → **Analytics** → **DebugView**
2. 디바이스가 연결되면 이벤트 타임라인이 실시간으로 표시
3. 각 이벤트 클릭하면 파라미터 값도 확인 가능

#### 4단계: 디버그 모드 해제
```bash
adb shell setprop debug.firebase.analytics.app .none.
```

### 테스트 체크리스트
- [ ] 앱 시작 → `app_open` 이벤트 확인
- [ ] 문구 복사 → `phrase_copy` + `source` 파라미터 확인
- [ ] 즐겨찾기 추가 → `phrase_favorite` + `action: add` 확인
- [ ] 버블 띄우기/닫기 → `bubble_session_start/end` + `duration_sec` 확인

---

## 7. A/B 테스트 (나중에)

> Phase 7 이후에 활용. 지금은 개념만 이해하면 됨.

### 개념
- Remote Config + Analytics의 조합
- "A 그룹은 허니문 14일, B 그룹은 10일" → 어느 쪽이 전환율 높은지 데이터로 판단
- Firebase가 자동으로 사용자를 나누고, 결과를 통계적으로 분석

### 활용 시나리오
1. `honeymoon_days`: 14일 vs 10일 → D14 리텐션 비교
2. `daily_ad_limit`: 3회 vs 5회 → ARPU 비교
3. `conversion_trigger_ad_count`: 2회 vs 3회 → IAP 전환율 비교

---

## 8. 트러블슈팅

### "콘솔에 데이터가 안 보여요"
- Analytics 데이터는 **최대 24시간 지연**됨 (배치 처리)
- 실시간 확인은 **DebugView** 사용
- `google-services.json`이 올바른 프로젝트 것인지 확인

### "Remote Config 값이 안 바뀌어요"
- `minimumFetchInterval`이 1시간 → 앱 재시작해도 1시간 내에는 캐시 사용
- 개발 중에는 `minimumFetchInterval`을 줄일 수 있지만, 릴리즈에서는 1시간 유지 (할당량 초과 방지)
- 콘솔에서 **"변경사항 게시"**를 눌렀는지 확인 (저장 ≠ 게시)

### "DebugView에 디바이스가 안 나와요"
- `adb shell setprop` 명령어 실행 후 **앱 재시작** 필요
- 에뮬레이터 사용 시 `adb devices`로 연결 확인
- 패키지명 오타 확인: `com.tigerroom.fangeul`

### "firebase_analytics 빌드 에러"
- `firebase_analytics: ^11.6.0` 사용 (11.6.1은 미존재)
- `google-services.json`이 `android/app/` 에 있는지 확인
- `android/app/build.gradle`에 `id 'com.google.gms.google-services'` 있는지 확인

---

## 부록: 코드 구조 요약

```
lib/services/
├── analytics_service.dart              ← 추상 인터페이스
├── analytics_events.dart               ← 26개 이벤트 + 11개 파라미터 상수
├── noop_analytics_service.dart         ← 개발/테스트용 (디버그 콘솔 출력)
├── firebase_analytics_service.dart     ← Firebase 구현체
├── remote_config_service.dart          ← RC 추상 인터페이스
├── firebase_remote_config_service.dart ← RC Firebase 구현체
└── noop_remote_config_service.dart     ← RC 테스트용

lib/presentation/providers/
├── analytics_providers.dart            ← AnalyticsService DI
└── remote_config_providers.dart        ← RemoteConfigService DI

lib/main.dart                           ← Firebase 초기화 + provider override
```

### 데이터 흐름
```
[사용자 행동]
    ↓
[Widget/Provider에서 logEvent() 호출]
    ↓
[AnalyticsService 구현체]
    ├── NoOp: debugPrint (개발)
    └── Firebase: firebase_analytics SDK → Firebase 서버 (프로덕션)
    ↓
[Firebase Analytics 대시보드에서 확인]
```
