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
- MVP 통합: 마이아이돌 + 템플릿 문구 + 온보딩 + 크로스엔진 연동 (2026-03-03)
- **PhrasesScreen 마이아이돌 개인화 + MyIdolNotifier race condition 수정 (2026-03-03)**

### 활성 작업
없음.

### 보류/백로그
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- Phase 6: 수익화 (감성 컬러 팩 IAP + 보상형 팬 패스 + 배너 조건부)
- 리뷰 연기 이슈: I1(IdolSelectScreen setState→Riverpod), I6(즐겨찾기 템플릿 메타데이터), I7~I9(minor)
- Phase B: 멤버 레벨 개인화 (설계서 완료: `docs/plans/2026-03-03-phrases-myidol-design.md` §3)
- 관리 대시보드 + R2 동기화 (출시 후 1~2주)

---

## 작업 요약

MyIdolNotifier race condition 수정 + PhrasesScreen에 마이아이돌 개인화 칩 추가. 태그 필터 뷰 템플릿 노출 버그 발견/수정. 337 tests pass.

## 완료된 작업

- [x] MyIdolNotifier race condition 수정 — `await future` 추가 (12eb8a5)
- [x] 태그 필터 뷰 `{{group_name}}` 노출 버그 수정 (77049e6)
- [x] UI 문자열 상수 추가: `phrasesMyIdolEmpty`, `phrasesMyIdolChip()` (ad7f69e)
- [x] TagFilterChips에 myIdol 칩 파라미터 추가 + 11개 테스트 (03edc01)
- [x] PhrasesScreen sentinel 기반 필터 + 기본 랜딩 + 8개 테스트 (a964586)
- [x] 코드 리뷰 수정: `_resolveTemplates` isFree 필터 + dartdoc (a32caaa)
- [x] 브레인스토밍 → 설계서 → 구현 계획서 작성

## 진행 중인 작업

없음. 모든 작업 머지 완료.

## 핵심 교훈

- ★ Riverpod AsyncNotifier의 `build()` future `.then()` 콜백은 수동 `state` 설정 후에도 실행됨 — `cancel()`이 호출되지 않음. `select()`/`clear()` 전에 `try { await future; } catch (_) {}` 필수 (2026-03-03)
- ★ `GetPhrasesByTagUseCase`는 `isTemplate` 필터 없음 → PhrasesScreen `_buildFilteredPhrases`에서 직접 `!isTemplate` 필터 필수. 3단계 필터링에 태그 뷰 경로 포함 필요 (2026-03-03)
- ★ PhrasesScreen sentinel 패턴: `null`=auto(hasIdol→myIdol, !hasIdol→전체), `__my_idol__`=명시, `__all__`=명시전체. "전체" 탭 시 idol 유저는 `__all__` 저장 (null은 myIdol로 재해석됨) (2026-03-03)

## 다음 단계

### 1순위: Phase 6 수익화
- 감성 컬러 팩 IAP (퍼플 드림, 골든 아워 등)
- 보상형 광고 "팬 패스" (4h 해금, 3회/일)
- 전환 퍼널 구현 (7일 무료 → Day4 보상형 → IAP 트리거)
- 상세: `docs/discussions/2026-02-28-bubble-monetization.md`

### 2순위: Phase B 멤버 레벨 개인화
- 설계 완료: `docs/plans/2026-03-03-phrases-myidol-design.md` §3
- `my_idol_member_name` SharedPreferences 키 추가
- `{{member_name}}` 템플릿 + 멤버 칩
- IdolSelectScreen 멤버명 입력 필드

### 3순위: Phase 7 릴리즈 준비
- Play Store 리스팅 + 스크린샷
- Firebase Analytics 연동 (NoOp → real)
- 크래시 리포팅 (Crashlytics)

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| 하이브리드 B+C UX (개인화 기본 랜딩) | 모드 전환 없음(B 단점 제거) + 화면 분할 없음(C 단점 제거). 팬이 앱 열면 즉시 아이돌 문구 |
| sentinel 값 방식 (freezed 대신) | 기존 StateProvider<String?> 유지, 변경 최소화. freezed는 오버엔지니어링 |
| 멤버 레벨 = Phase B 분리 | 그룹 레벨 먼저 완성 후 확장. 별도 키(`my_idol_member_name`)로 무파괴 추가 가능 |
| `_resolveTemplates`에 isFree 필터 추가 | `_flattenPacks`과 일관성. 유료 팩 템플릿 노출 방지 |

## 커밋 히스토리

```
12eb8a5 fix: MyIdolNotifier race condition — await build() before state set
a32caaa fix: add isFree filter to _resolveTemplates + dartdoc for phrasesMyIdolEmpty
a964586 feat: add myIdol personalized phrases to PhrasesScreen
03edc01 feat: add myIdol chip support to TagFilterChips
ad7f69e feat: add PhrasesScreen myIdol UI string constants
77049e6 fix: filter template phrases from tag-filtered view in PhrasesScreen
7b453dd chore: session handoff - MVP 통합 완료 (마이아이돌+템플릿+온보딩, 314 tests)
```

## 수정한 파일

```
신규:
  docs/plans/2026-03-03-phrases-myidol-design.md    — PhrasesScreen 마이아이돌 설계서
  docs/plans/2026-03-03-phrases-myidol-plan.md      — 구현 계획서
  test/presentation/screens/phrases_screen_myidol_test.dart  — 9개 테스트
  test/presentation/widgets/tag_filter_chips_test.dart       — 11개 테스트

수정:
  lib/presentation/screens/phrases_screen.dart      — sentinel 필터 + myIdol 문구 빌드 + 태그 뷰 템플릿 버그 수정
  lib/presentation/widgets/tag_filter_chips.dart    — myIdol 칩 파라미터 4개 추가
  lib/presentation/constants/ui_strings.dart        — phrasesMyIdolEmpty, phrasesMyIdolChip() 추가
  lib/presentation/providers/my_idol_provider.dart  — select()/clear() race condition 수정
  test/presentation/providers/my_idol_provider_test.dart — race condition 테스트 3개 추가
```

## 리뷰 연기 이슈 (post-MVP)

| ID | 내용 | 심각도 | 이유 |
|----|------|--------|------|
| I1 | IdolSelectScreen에서 setState 사용 | LOW | 순수 ephemeral UI 상태 |
| I6 | 즐겨찾기 템플릿 메타데이터 손실 | LOW | ko 텍스트는 정상 표시 |
| I7 | myIdolDisplayNameProvider auto-dispose | LOW | 크로스엔진 lifecycle invalidate로 커버 |
| I8 | HomeScreen Consumer-in-ConsumerWidget 중복 | LOW | 코스메틱 |
| I9 | _buildMyIdolPhrases isFree 미확인 | DONE | a32caaa에서 수정 |

## 참고 컨텍스트

- PhrasesScreen 설계서: `docs/plans/2026-03-03-phrases-myidol-design.md`
- 구현 계획서: `docs/plans/2026-03-03-phrases-myidol-plan.md`
- MVP 통합 설계서: `docs/plans/2026-03-03-mvp-integration-design.md`
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
| Sprint 1 | MVP UX 기반 다듬기 → 252 tests |
| Sprint 2 | 상황태그 + K-pop 캘린더 + 분석 계측 → 280 tests |
| MVP 통합 | 마이아이돌 + 템플릿 문구 + 온보딩 + 교차리뷰 → 314 tests |
| **이번 세션** | MyIdolNotifier race fix + PhrasesScreen 아이돌 칩 + 태그 뷰 버그 수정 → 337 tests |
