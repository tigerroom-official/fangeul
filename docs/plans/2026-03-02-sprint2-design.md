# Sprint 2 설계서 — 데이터 + 분석

> **날짜**: 2026-03-02
> **근거**: MVP 출시 리뷰 패널 토론 (2026-03-02) P0 #4~#7

## Task 5: 상황 태그 (Situation Tags)

### 현재 상태
- 80개 문구, 4개 팩 (`basic_love`, `daily_pack`, `birthday_pack`, `comeback_pack`)
- `Phrase` entity에 `tags` 필드 존재 (`["love", "daily"]` 등)
- 팩별 필터는 있으나 **상황별 서페이싱 없음**

### 설계
- `Phrase` entity에 `situation` 필드 추가 (nullable String)
- 값: `birthday` / `comeback` / `concert` / `daily` / `support` / `null`
- JSON 스키마에 `situation` 필드 추가, 기존 80개 문구에 적절히 태깅
- `GetPhrasesBySituationUseCase` 추가 — 캘린더 매칭에 사용

### 태깅 매핑
| 팩 | 기본 situation |
|----|---------------|
| `basic_love` | `support` (응원) + `daily` 혼합 |
| `daily_pack` | `daily` |
| `birthday_pack` | `birthday` |
| `comeback_pack` | `comeback` |

개별 문구는 tags + context 기반으로 세분화.

## Task 6: K-pop 캘린더 파이프라인

### 현재 상태
- 캘린더 데이터/코드 전무
- `DailyCard` entity 존재하나 캘린더 연동 없음

### 설계
- `assets/calendar/kpop_events.json` — 수동 큐레이션 이벤트 데이터
- `KpopEvent` entity (`core/entities/`)
- `KpopCalendarRepository` — 이벤트 로드 + 날짜 매칭
- `GetTodayEventsUseCase` — 오늘/이번 주 이벤트 반환
- `todayEventsProvider` + `todaySuggestedPhrasesProvider` — 이벤트 → situation → 문구 서페이싱

### 이벤트 JSON 스키마
```json
{
  "events": [
    {
      "date": "2026-03-09",
      "type": "birthday",
      "artist": "민윤기",
      "group": "BTS",
      "situation": "birthday"
    }
  ]
}
```

### MVP 범위
- 상위 10개 그룹의 멤버 생일 + 최근 컴백 (약 100개 이벤트)
- 날짜 매칭: 오늘 이벤트 → situation 태그 → 해당 문구 서페이싱
- 월 1회 수동 갱신 (앱 업데이트 시 assets 교체)

## Task 7: 분석 계측 (Analytics)

### 현재 상태
- Firebase 미설정, analytics 코드 없음

### 설계
- 추상 `AnalyticsService` 인터페이스 → `FirebaseAnalyticsService` 구현
- `google-services.json` 없으면 `NoOpAnalyticsService` 폴백
- **이벤트 스키마:**

| 이벤트 | 파라미터 | 시점 |
|--------|---------|------|
| `app_open` | — | 앱 시작 |
| `bubble_session_start` | — | 버블 활성화 |
| `bubble_session_end` | `duration_sec` | 버블 비활성화 |
| `phrase_copy` | `pack_id`, `situation`, `source` (bubble/main) | 복사 성공 |
| `phrase_favorite` | `action` (add/remove) | 즐겨찾기 토글 |
| `filter_change` | `type` (favorites/pack), `pack_id` | 필터 변경 |
| `onboarding_step` | `step_name` | 온보딩 단계 |
| `calendar_event_view` | `event_type`, `artist` | 캘린더 이벤트 조회 |

### 의존성
- `firebase_core`, `firebase_analytics` 패키지 추가
- `google-services.json` 필요 (Firebase Console에서 생성)
- `google-services.json` 없으면 빌드 에러 방지를 위해 조건부 초기화
