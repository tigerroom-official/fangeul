# Fangeul — Session Handoff

BASE_COMMIT: b26c14e (main)
HANDOFF_COMMIT: (이 커밋에서 갱신)
BRANCH: main

---

## 프로젝트 상태 (누적)

### 완료된 마일스톤
- Phase 1~4: Core 엔진 + 데이터 레이어 + UI 완료
- Phase 5: 플로팅 버블 전체 구현 + 리뷰 수정 + MEDIUM/UX 수정
- Sprint 1 MVP UX: 간편모드 높이 43% + 팩 자동 복원 + 복사 confetti/진동 + OEM 배터리 대응
- Sprint 2: 상황태그 + K-pop 캘린더(69이벤트) + 분석 계측(NoOp) (2026-03-02)
- **MVP 통합: 마이아이돌 + 템플릿 문구 + 온보딩 + 크로스엔진 연동 (2026-03-03)**

### 활성 작업
없음. MVP 통합 머지 완료.

### 보류/백로그
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- Phase 6: 수익화 (감성 컬러 팩 IAP + 보상형 팬 패스 + 배너 조건부)
- 리뷰 연기 이슈: I1(IdolSelectScreen setState→Riverpod), I6(즐겨찾기 템플릿 메타데이터), I7~I9(minor)
- 관리 대시보드 + R2 동기화 (출시 후 1~2주)

---

## 작업 요약

MVP 통합 — 마이 아이돌 선택(5그룹 파일럿) + 템플릿 문구(`{{group_name}}` 치환) + 온보딩 플로우 + 오늘 필터 + 크로스엔진 동기화. 18개 피처 커밋, 3라운드 교차 리뷰(Claude self + Codex GPT-5.3). 314 tests pass.

## 완료된 작업

- [x] groups.json lite (5그룹: BTS, BLACKPINK, Stray Kids, aespa, SEVENTEEN)
- [x] Phrase.isTemplate 필드 + my_idol_pack.json (10개 템플릿 문구)
- [x] IdolGroup freezed entity + MyIdolNotifier provider (SharedPreferences 저장)
- [x] 템플릿 문구 해결 로직 (`resolveTemplatePhrase()`)
- [x] CompactPhraseFilter.myIdol / .today sealed class 케이스 추가
- [x] filteredCompactPhrasesProvider에 myIdol/today 분기 + 템플릿 치환
- [x] IdolSelectScreen (온보딩 + 설정 재사용)
- [x] 온보딩 플로우: main.dart initialRoute → IdolSelectScreen → /home
- [x] HomeScreen 마이 아이돌 인사말
- [x] todaySuggestedPhrases 아이돌 그룹 필터링
- [x] PackFilterChips에 마이아이돌/오늘 칩 추가
- [x] compact_phrase_list에 전체 칩 와이어링 + 수직 리스트/스와이퍼 분기
- [x] 크로스엔진 동기화 (myIdol provider + lifecycle invalidate)
- [x] 설정 화면 마이 아이돌 타일
- [x] 라우터 갱신 (onboarding/idol-select + settings/idol-select)
- [x] 리뷰 수정 Round 1: knownPackIds 누락 + 칩 와이어링 + 오늘 칩 UI
- [x] 리뷰 수정 Round 2: 템플릿 노출 방지(3단계 필터링) + 빈상태 메시지 + 온보딩 시점
- [x] 테스트 23개 추가: myIdol/today 칩 위젯 12개 + 필터 provider 11개

## 진행 중인 작업

없음.

## 핵심 교훈

- ★ 템플릿 문구(`isTemplate: true`)는 3단계에서 필터링 필수: (1) phrases_screen `_flattenPacks`, (2) compact_phrase_list 칩 목록, (3) provider `_buildPackPhrases`. 하나라도 빠지면 `{{group_name}}` 원본이 사용자에게 노출됨 (2026-03-03)
- ★ `onboarding_done` 플래그는 온보딩 완료/스킵 시점에만 설정. main.dart에서 조기 설정하면 앱 킬 시 온보딩 재진입 불가 (2026-03-03)
- ★ 즐겨찾기에 저장된 템플릿 문구는 치환된 ko 텍스트만 보존됨 — roman/context 등 메타데이터는 원본 팩에서 ko 키로 lookup 실패 (원본은 `{{group_name}} ...`). MVP 한계로 수용, 향후 즐겨찾기 구조 개선 필요 (2026-03-03)
- ★ PackFilterChips에 새 칩 추가 시 `extraChips` 카운트와 `itemBuilder` 인덱스 오프셋 모두 갱신 필수 — 불일치 시 팩 칩이 누락되거나 잘못된 팩에 매핑 (2026-03-03)

## 리뷰 연기 이슈 (post-MVP)

| ID | 내용 | 심각도 | 이유 |
|----|------|--------|------|
| I1 | IdolSelectScreen에서 setState 사용 | LOW | 순수 ephemeral UI 상태(선택 하이라이트, 커스텀 입력 토글). 비즈니스 로직 아님 |
| I6 | 즐겨찾기 템플릿 메타데이터 손실 | LOW | ko 텍스트는 정상 표시. roman/context 누락은 UX 영향 미미 |
| I7 | myIdolDisplayNameProvider auto-dispose | LOW | 크로스엔진에서 lifecycle invalidate로 커버 |
| I8 | HomeScreen Consumer-in-ConsumerWidget 중복 | LOW | 코스메틱 리팩토링 |
| I9 | _buildMyIdolPhrases isFree 미확인 | LOW | my_idol_pack은 항상 free |

## 다음 단계

### 1순위: Phase 6 수익화
- 감성 컬러 팩 IAP (퍼플 드림, 골든 아워 등)
- 보상형 광고 "팬 패스" (4h 해금, 3회/일)
- 전환 퍼널 구현 (7일 무료 → Day4 보상형 → IAP 트리거)
- 상세: `docs/discussions/2026-02-28-bubble-monetization.md`

### 2순위: Phase 7 릴리즈 준비
- Play Store 리스팅 + 스크린샷
- Firebase Analytics 연동 (NoOp → real)
- 크래시 리포팅 (Crashlytics)

### 3순위: 출시 후 운영
- 관리 대시보드 + R2 동기화 (MVP+1~2주)
- 30그룹 확장 (DAU 5K gate)
- LOW 이슈 잔여 처리

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| 템플릿 방식 이름 삽입 | 법적 안전 + 비용 절감. 유저가 이름 선택, 앱은 템플릿만 제공 |
| v1.2 MVP 통합 | 첫인상 임팩트 극대화. 마이아이돌 없이는 "또 다른 한국어 앱" |
| 5그룹 파일럿 (BTS/BP/SKZ/aespa/SVT) | PMF 검증 도구, DAU gate 무관. 데이터량 최소화 |
| onboarding_done 지연 설정 | 앱 킬 대응 — 완료/스킵 확인 후에만 플래그 set |
| 템플릿 3단계 필터링 | `{{group_name}}` 원문 노출은 치명적 UX 결함 |
| setState 허용 (IdolSelectScreen) | ephemeral UI state만 — 프로젝트 규칙 엄격 적용 시 과도한 오버엔지니어링 |

## 커밋 히스토리

```
b26c14e merge: MVP 통합 — 마이아이돌 + 템플릿 문구 + 온보딩 (feature/mvp-integration)
fa85a88 fix: 교차리뷰 Round 2 수정 — 템플릿 노출 방지 + 빈상태 메시지 + 온보딩 시점
0373d98 test: myIdol/today 칩 위젯 + 필터 provider 테스트 추가
f0f1bff fix: 리뷰 수정 — knownPackIds 누락 + 칩 와이어링 + 오늘 칩 UI
dd0373e docs: add MVP integration design, plan, and panel discussion
5ace8e9 chore: fix dart format + suppress freezed @JsonKey analyzer warning
fc09f11 feat: add today filter for bubble context-aware phrases
280c50a feat: add myIdol provider to cross-engine sync
fd0d42c feat: add my idol filter chip to PackFilterChips
7744e14 feat: filter todaySuggestedPhrases by my idol group
48414cb feat: add my idol greeting on home app bar
c1620b8 feat: add idol selection UI (onboarding + settings)
e2f8782 feat: add myIdol filter case + template resolution in compact phrases
4d1e437 feat: add template phrase resolution logic
acbbb84 feat: add IdolGroup entity + MyIdolNotifier provider
948e3f7 docs: allow idol name template insertion in rules
ed48aae feat: add my_idol template phrase pack (10 phrases)
65a029a feat: add isTemplate field to Phrase entity
400f9e0 feat: add groups.json lite (5 pilot groups)
```

## 수정한 파일 (MVP 통합)

```
신규:
  assets/groups/groups.json                          — 5그룹 파일럿 데이터
  assets/phrases/my_idol_pack.json                   — 10개 템플릿 문구
  lib/core/entities/idol_group.dart                  — IdolGroup freezed entity
  lib/presentation/providers/my_idol_provider.dart   — MyIdolNotifier + display name
  lib/presentation/providers/template_phrase_provider.dart — resolveTemplatePhrase
  lib/presentation/screens/idol_select_screen.dart   — 아이돌 선택 UI
  docs/plans/2026-03-03-mvp-integration-design.md    — 설계서
  docs/plans/2026-03-03-mvp-integration-plan.md      — 구현 계획서
  test/presentation/providers/my_idol_provider_test.dart
  test/presentation/providers/template_phrase_provider_test.dart

수정:
  lib/core/entities/phrase.dart                      — isTemplate 필드 추가
  lib/data/datasources/phrase_local_datasource.dart  — knownPackIds에 my_idol_pack 추가
  lib/main.dart                                      — 온보딩 라우트 + onboarding_done 조기설정 제거
  lib/presentation/constants/ui_strings.dart          — 20개 문자열 상수 추가
  lib/presentation/providers/calendar_providers.dart  — myIdol 그룹 필터링
  lib/presentation/providers/compact_phrase_filter_provider.dart — myIdol/today 케이스 + 템플릿 필터
  lib/presentation/router/app_router.dart            — 온보딩/설정 라우트
  lib/presentation/screens/home_screen.dart          — 마이아이돌 인사말
  lib/presentation/screens/phrases_screen.dart       — 템플릿 문구 필터링
  lib/presentation/screens/settings_screen.dart      — 마이아이돌 타일
  lib/presentation/widgets/compact_phrase_list.dart  — 칩 와이어링 + 수직 리스트
  lib/presentation/widgets/pack_filter_chips.dart    — myIdol/today 칩 추가
  test/presentation/widgets/pack_filter_chips_test.dart — 12개 테스트 추가
  test/presentation/providers/compact_phrase_filter_provider_test.dart — 11개 테스트 추가
```

## 참고 컨텍스트

- 패널 토론: `docs/discussions/2026-03-02-mvp-launch-review.md`
- 설계서: `docs/plans/2026-03-03-mvp-integration-design.md`
- 구현 계획: `docs/plans/2026-03-03-mvp-integration-plan.md`
- 수익화 토론: `docs/discussions/2026-02-28-bubble-monetization.md`

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
| Sprint 2 | 상황태그 + K-pop 캘린더 + 분석 계측 + 패널 토론 3회 → 280 tests |
| **MVP 통합 (이번)** | 마이아이돌 + 템플릿 문구 + 온보딩 + 교차리뷰 3라운드 → 314 tests |
