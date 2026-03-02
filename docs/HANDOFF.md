# Fangeul — Session Handoff

BASE_COMMIT: 361cd0b (main)
HANDOFF_COMMIT: 미커밋 (워크트리 작업 중)
BRANCH: feature/sprint2-data-analytics (worktree: .worktrees/sprint2-data-analytics)

---

## 프로젝트 상태 (누적)

### 완료된 마일스톤
- Phase 1~4: Core 엔진 + 데이터 레이어 + UI 완료
- Phase 5: 플로팅 버블 전체 구현 + 리뷰 수정 + MEDIUM/UX 수정
- Sprint 1 MVP UX: 간편모드 높이 43% + 팩 자동 복원 + 복사 confetti/진동 + OEM 배터리 대응
- Sprint 2 Task 5~7: 상황태그 + K-pop 캘린더 + 분석 계측 (2026-03-02)

### 활성 작업
Sprint 2 워크트리에서 Task 5+6+7 구현 완료. **커밋/머지 대기.**

### 보류/백로그
- 3차 패널 토론 결과: v1.2(마이아이돌 + 템플릿 문구)를 MVP에 통합 → 별도 구현 계획 필요
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- Phase 6: 수익화 (감성 컬러 팩 IAP)

## 작업 요약

Sprint 2 "데이터 + 분석" 3개 태스크 구현:
1. **상황 태그(Task 5)**: Phrase entity에 situation 필드 추가, 4개 JSON 태깅, GetPhrasesBySituationUseCase + provider
2. **K-pop 캘린더(Task 6)**: 69개 이벤트 JSON, KpopEvent entity, CalendarRepository + DataSource, GetTodayEventsUseCase, todaySuggestedPhrasesProvider
3. **분석 계측(Task 7)**: AnalyticsService 추상 인터페이스 + NoOp 구현, 이벤트 상수, 6곳 계측 삽입

패널 토론 3회 진행 — "금주의 문구 & 캘린더 수집 시스템" 설계서 리뷰. 최종 합의: v1.2를 MVP에 포함(마이아이돌 + 템플릿 + 5그룹 파일럿), 대시보드/R2는 출시 후 1~2주.

## 완료된 작업

- [x] Task 5: Phrase.situation 필드 + 4개 JSON 태깅 + GetPhrasesBySituationUseCase + provider + 테스트 6개
- [x] Task 6: kpop_events.json(69이벤트) + KpopEvent freezed entity + CalendarRepository + DataSource + GetTodayEventsUseCase + calendar_providers + 테스트 14개
- [x] Task 7: AnalyticsService interface + NoOpAnalyticsService + AnalyticsEvents 상수 + analyticsServiceProvider + 6곳 계측(app_open, bubble_session_start/end, phrase_copy, phrase_favorite, filter_change) + 테스트 7개

## 진행 중인 작업

없음. 워크트리에서 커밋/머지 대기.

## 워크트리 상태

```
경로: .worktrees/sprint2-data-analytics
브랜치: feature/sprint2-data-analytics
테스트: 280개 pass (기존 252 + 신규 28)
분석: No issues found
포맷: 0 changed
```

## 신규 파일

```
lib/services/analytics_service.dart          — AnalyticsService 추상 인터페이스
lib/services/noop_analytics_service.dart     — NoOp 구현 (디버그 출력)
lib/services/analytics_events.dart           — 이벤트/파라미터 상수
lib/presentation/providers/analytics_providers.dart — analyticsServiceProvider
lib/presentation/providers/calendar_providers.dart  — todayEvents + todaySuggestedPhrases
lib/core/entities/kpop_event.dart            — KpopEvent freezed entity
lib/core/repositories/calendar_repository.dart — CalendarRepository interface
lib/core/usecases/get_today_events_usecase.dart — GetTodayEventsUseCase
lib/core/usecases/get_phrases_by_situation_usecase.dart — GetPhrasesBySituationUseCase
lib/data/datasources/calendar_local_datasource.dart — 캘린더 JSON 로드 + 캐시
lib/data/repositories/calendar_repository_impl.dart — CalendarRepository 구현
assets/calendar/kpop_events.json             — 상위 10그룹 69개 이벤트
test/services/analytics_service_test.dart    — NoOp + Recording + 상수 테스트
test/core/entities/kpop_event_test.dart      — KpopEvent fromJson 테스트
test/core/usecases/get_today_events_usecase_test.dart — 날짜 매칭 테스트
test/core/usecases/get_phrases_by_situation_usecase_test.dart — situation 필터 테스트
test/data/datasources/calendar_local_datasource_test.dart — DataSource 테스트
```

## 수정된 파일

```
lib/core/entities/phrase.dart                — situation 필드 추가
lib/main.dart                                — app_open 이벤트 + UncontrolledProviderScope
lib/presentation/providers/bubble_providers.dart — session start/end 이벤트
lib/presentation/providers/favorite_phrases_provider.dart — phrase_favorite 이벤트
lib/presentation/providers/compact_phrase_filter_provider.dart — filter_change 이벤트
lib/presentation/providers/phrase_providers.dart — situation usecase provider
lib/presentation/widgets/compact_phrase_tile.dart — phrase_copy 이벤트 (bubble)
lib/presentation/widgets/phrase_card.dart     — phrase_copy 이벤트 (main)
assets/phrases/basic_love.json               — situation 태깅
assets/phrases/birthday_pack.json            — situation 태깅
assets/phrases/comeback_pack.json            — situation 태깅
assets/phrases/daily_pack.json               — situation 태깅
pubspec.yaml                                 — assets/calendar/ 추가
```

## 분석 계측 삽입 지점

| 이벤트 | 위치 | 파라미터 |
|--------|------|----------|
| `app_open` | `main.dart` | — |
| `bubble_session_start` | `BubbleNotifier.show()` | — |
| `bubble_session_end` | `BubbleNotifier.hide()` | `duration_sec` |
| `phrase_copy` | `CompactPhraseTile._copy()`, `PhraseCard` copy button | `source`, `situation` |
| `phrase_favorite` | `FavoritePhrasesNotifier.toggle()` | `action` (add/remove) |
| `filter_change` | `CompactPhraseFilterNotifier.selectFavorites/selectPack()` | `filter_type`, `pack_id` |

## 패널 토론 결과 (3차 최종)

토론 기록: `docs/discussions/2026-03-02-weekly-phrases-system-review.md`

### 확정된 MVP 범위 (v1.1+v1.2 통합)

| 구성요소 | MVP | 출시 후 |
|----------|-----|---------|
| 정적 캘린더 + 상황태그 | **완료** | — |
| 분석 계측 | **완료** | — |
| 마이 아이돌 선택 UI (5그룹) | 미착수 | — |
| 템플릿 문구 렌더링 | 미착수 | — |
| 5그룹 데이터 (앱 번들) | 미착수 | — |
| 관리 대시보드 | — | MVP+1~2주 |
| R2 동기화 | — | MVP+1~2주 |

### 추정 잔여 일정
- 마이아이돌 + 템플릿 + groups.json + 통합 테스트: **5~7일**
- 7일 cap (초과 시 v1.1만 출시)

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| Firebase 미포함, NoOp 폴백 | google-services.json 없이 빌드 성공 보장. Firebase 추가 시 provider override로 교체 |
| AnalyticsService → services/ 레이어 | core/ 순수 Dart 규칙 유지. services/는 플랫폼 서비스 레이어 |
| main.dart UncontrolledProviderScope | app_open 이벤트를 runApp 전에 기록하기 위해 ProviderContainer 직접 생성 |
| 템플릿 방식 이름 삽입 | 법적 안전 + 비용 절감. 유저가 이름 선택, 앱은 템플릿만 제공 |
| v1.2 MVP 통합 | 첫인상 임팩트 극대화. 정적 캘린더만으로는 차별화 체감 약함 |
| DAU 5K gate → 30그룹 확장에만 적용 | 5그룹 파일럿은 PMF 검증 도구, gate 무관 |

## 다음 단계

### 1순위: 워크트리 커밋/머지
- `.worktrees/sprint2-data-analytics` 변경사항 커밋
- main에 머지 또는 PR 생성

### 2순위: MVP 통합 구현 계획 수립
- 마이 아이돌 선택 UI + groups.json lite (5그룹)
- 템플릿 문구 시스템 (`{{group_name}}` 치환)
- 통합 테스트 + 안정화
- 세밀한 구현 계획 작성 필요

### 3순위: Phase 6 수익화
- 감성 컬러 팩 IAP
- 보상형 광고 "팬 패스"

## 참고 컨텍스트

- 패널 토론: `docs/discussions/2026-03-02-weekly-phrases-system-review.md` (1차~3차)
- 설계서: `docs/fangeul-weekly-phrases-system.md` (3차 합의로 일부 대체됨)
- 인프라: VPS(자동매매봇 운영) + 로컬 GPU서버 + DB/웹겸용서버 → 대시보드 배포 가능

## 세션 히스토리

| 세션 | 요약 |
|------|------|
| P1~P3 | Core 엔진 + 데이터 레이어 완료 |
| P4 | UI 화면 구현 (홈, 변환기, 문구, 설정) |
| P5-구현 | Phase 5 플로팅 버블 16 tasks 구현 |
| P5-리뷰 | C1~C3/H1~H4 리뷰 수정 → 215 tests |
| P5.1-MEDIUM | M1/M3/M4/M5 수정 |
| P5.2-UX | 팩 문구 탐색 + AsyncNotifier 전환 + 버블/키보드 UX 수정 → 247 tests |
| Sprint 1 | MVP UX 기반 다듬기 — 높이/팩복원/confetti/배터리 + 3건 리뷰 수정 → 252 tests |
| **Sprint 2 (이번)** | 상황태그 + K-pop 캘린더 + 분석 계측 + 패널 토론 3회 → 280 tests |
