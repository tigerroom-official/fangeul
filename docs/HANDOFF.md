# Fangeul — Session Handoff

BASE_COMMIT: 88a7c9d (main)
HANDOFF_COMMIT: (pending commit — Phase 6 수익화 설계 문서)
BRANCH: main

---

## 프로젝트 상태 (누적)

### 완료된 마일스톤
- Phase 1~4: Core 엔진 + 데이터 레이어 + UI 완료
- Phase 5: 플로팅 버블 전체 구현 + 리뷰 수정 + MEDIUM/UX 수정
- Sprint 1 MVP UX: 간편모드 높이 43% + 팩 자동 복원 + 복사 confetti/진동 + OEM 배터리 대응
- Sprint 2: 상황태그 + K-pop 캘린더(69이벤트) + 분석 계측(NoOp) (2026-03-02)
- MVP 통합: 마이아이돌 + 템플릿 문구 + 온보딩 + 크로스엔진 연동 (2026-03-03)
- PhrasesScreen 마이아이돌 개인화 + MyIdolNotifier race condition 수정 (2026-03-03)
- **Phase B: 멤버 레벨 개인화 완료 + Codex 리뷰 수정 (2026-03-04)**
- **Phase 6 수익화 설계: 전문가 패널 토론 + Claude×Codex 교차 리뷰 완료 (2026-03-04)**

### 활성 작업
없음. Phase 6 설계 완료, 구현 계획 수립 대기.

### 보류/백로그
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- 리뷰 연기 이슈: I1(IdolSelectScreen setState→Riverpod), I6(즐겨찾기 템플릿 메타데이터)
- todaySuggestedPhrases에 memberName 미전달 (멤버 템플릿 "오늘" 추천 미포함 — known limitation)
- 관리 대시보드 + R2 동기화 (출시 후 1~2주)

---

## 작업 요약

Phase 6 수익화 설계: 5명 전문가 패널 토론(5개 토픽) + Claude×Codex 병렬 교차 리뷰. UVP를 "팬 정체성 인프라"로 재정의, 경험 깊이 제한(슬롯+TTS) 전략, D-day 선물 정책, 퍼널 Day7 보상형→Day14 IAP 재설계. 교차 리뷰에서 IAP 수익 계산 오류(일간→월간 설치) 등 5건 Critical 수정.

## 완료된 작업

### Phase B 구현 (9 커밋)
- [x] Task 1: resolveTemplatePhrase `{{member_name}}` 확장 + needsMemberName 헬퍼 (64e4dbc)
- [x] Task 1 fix: isTemplate 가드 추가 (5c331d9)
- [x] Task 2: MyIdolNotifier selectMember/clearMember + myIdolMemberNameProvider (ac66a6b)
- [x] Task 2 fix: group 미설정 시 selectMember 스킵 가드 (4237fc0)
- [x] Task 3: 멤버 전용 템플릿 JSON 6개 추가 (7e45c45)
- [x] Task 4: UI Strings 멤버 관련 문자열 추가 (1a18f00)
- [x] Task 5: IdolSelectScreen 멤버명 입력 필드 + 확인 플로우 (965abce)
- [x] Task 6: PhrasesScreen 멤버 칩 + `__my_member__` sentinel (2de4160)
- [x] Task 7: 버블 compact_phrase_filter 멤버 통합 (326fe20)

### Codex 리뷰 수정 (1 커밋)
- [x] Critical: _buildMyIdolPhrases 멤버 템플릿 누출 수정 (0b0a50d)
- [x] Important: stale sentinel — isMemberSelected에 hasMember 가드 (0b0a50d)
- [x] Important: myIdolMemberPrefsKey 상수 추출 (3곳 중복 제거) (0b0a50d)
- [x] Important: myIdolMemberNameProvider 반응성 제약 dartdoc (0b0a50d)
- [x] 회귀 테스트: unresolved `{{member_name}}` 방지 (0b0a50d)

## 핵심 교훈

- ★ `_buildMyIdolPhrases` 필터 조건 `|| memberName == null`은 반대 로직 — 멤버 템플릿은 항상 그룹 뷰에서 제외해야 함. `!needsMemberName(p)` 단독 사용 (2026-03-04)
- ★ sentinel 기반 선택 시 `hasMember` 가드 없으면 멤버 제거 후에도 빈 멤버 뷰에 갇힘 — `isMemberSelected = hasMember && (...)` 필수 (2026-03-04)
- ★ SharedPreferences 키를 여러 파일에서 사용하면 상수로 추출 필수 — `myIdolMemberPrefsKey` 패턴 (2026-03-04)
- ★ `myIdolMemberNameProvider`는 그룹 ID만 watch → 멤버만 변경 시 갱신 안 됨. 현재 플로우(select+selectMember 동시 호출)에서는 문제없지만, "멤버만 변경" 시나리오 추가 시 invalidation 필요 (2026-03-04)
- ★ Codex 독립 리뷰: 내부 리뷰에서 놓친 Critical 버그(조건식 반전) 발견. 병렬 리뷰의 가치 재확인 (2026-03-04)

## 다음 단계

### 1순위: Phase 6 구현 계획
- 수익화 설계 문서 기반 상세 구현 계획 수립 (writing-plans)
- P0(1주차): 광고+제한+네이밍 / P1(2주차): IAP+퍼널+TTS

### 2순위: Phase 6 구현
- 배너/보상형 광고 (AdMob), 즐겨찾기 3슬롯, TTS 5회/일, 허니문 플래그
- 감성 컬러 팩 IAP (₩990/₩1,900/₩3,900), 전환 트리거, D-day 선물
- `flutter_secure_storage` + HMAC 서명 (모든 보상/제한 상태)

### 3순위: Phase 7 릴리즈 준비
- Play Store 리스팅 + 스크린샷
- Firebase Analytics 연동 (NoOp → real)
- 크래시 리포팅 (Crashlytics)

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| 멤버 템플릿은 그룹 뷰에서 항상 제외 | memberName null 시 `{{member_name}}` 원문 노출 방지 |
| isMemberSelected에 hasMember 가드 | 멤버 제거 후 stale sentinel 방지 |
| myIdolMemberPrefsKey 공개 상수 | 3곳(provider, screen, tests) 키 중복 제거 |
| todaySuggestedPhrases 멤버 미지원 | MVP 범위 — known limitation으로 남김 |

## 커밋 히스토리 (Phase B)

```
0b0a50d fix: resolve Codex review findings — member template leak + stale sentinel
326fe20 feat: support member name in bubble myIdol phrases
2de4160 feat: add member chip and filter to PhrasesScreen
965abce feat: add member name input to IdolSelectScreen
1a18f00 feat: add member personalization UI strings
7e45c45 feat: add 6 member template phrases with {{member_name}}
4237fc0 fix: add group prerequisite guard to selectMember + test
ac66a6b feat: add member name support to MyIdolNotifier
5c331d9 fix: add isTemplate guard to needsMemberName + edge case test
64e4dbc feat: extend resolveTemplatePhrase with {{member_name}} support
```

## 수정한 파일

```
신규:
  docs/plans/2026-03-03-phase-b-member-personalization-plan.md — 구현 계획서
  test/presentation/screens/idol_select_screen_test.dart       — 위젯 테스트 (멤버 입력 플로우)
  test/presentation/screens/phrases_screen_myidol_test.dart    — 멤버 필터/치환 테스트 (17개)

수정:
  assets/phrases/my_idol_pack.json                   — 멤버 전용 템플릿 6개 추가
  lib/presentation/constants/ui_strings.dart         — 멤버 관련 UI 문자열 6개
  lib/presentation/providers/my_idol_provider.dart   — selectMember/clearMember + myIdolMemberNameProvider + 상수 추출
  lib/presentation/providers/my_idol_provider.g.dart — 코드 생성
  lib/presentation/providers/template_phrase_provider.dart  — {{member_name}} 치환 + needsMemberName + filterAndResolveTemplates 확장
  lib/presentation/providers/compact_phrase_filter_provider.dart — 버블 멤버 통합
  lib/presentation/screens/idol_select_screen.dart   — 멤버명 입력 + 확인 플로우
  lib/presentation/screens/phrases_screen.dart       — 멤버 칩 + __my_member__ sentinel + Codex 버그 수정
  lib/presentation/widgets/tag_filter_chips.dart     — 멤버 칩 파라미터 4개
  test/presentation/providers/my_idol_provider_test.dart           — 멤버 테스트 7개 추가
  test/presentation/providers/template_phrase_provider_test.dart   — 멤버 치환/필터 테스트 추가
  test/presentation/providers/compact_phrase_filter_provider_test.dart — 버블 멤버 테스트
  test/presentation/widgets/tag_filter_chips_test.dart             — 멤버 칩 테스트
```

## 리뷰 연기 이슈 (post-MVP)

| ID | 내용 | 심각도 | 이유 |
|----|------|--------|------|
| I1 | IdolSelectScreen에서 setState 사용 | LOW | 순수 ephemeral UI 상태 |
| I6 | 즐겨찾기 템플릿 메타데이터 손실 | LOW | ko 텍스트는 정상 표시 |
| I10 | todaySuggestedPhrases 멤버 미지원 | LOW | MVP known limitation |

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
| PhrasesScreen 아이돌 | MyIdolNotifier race fix + 아이돌 칩 + 태그 뷰 버그 수정 → 337 tests |
| **Phase B 멤버** | 멤버 개인화 7 tasks + Codex 리뷰 Critical 수정 → 383 tests |
| **Phase 6 설계** | 전문가 패널 5토픽 토론 + Claude×Codex 교차 리뷰 → 수익화 합의 문서 |
