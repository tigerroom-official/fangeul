# Fangeul — Session Handoff

BASE_COMMIT: 194795a (main, Crashlytics/Analytics + 버블 UX 통일)
HANDOFF_COMMIT: aa6fd6d
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
- Phase B: 멤버 레벨 개인화 완료 + Codex 리뷰 수정 (2026-03-04)
- Phase 6 수익화 설계+구현: 18 tasks + 2라운드 Claude×Codex 교차 리뷰 (2026-03-04)
- 멀티모드 키보드 + 패널 개선 + 버블 버그 수정 (2026-03-04)
- i18n 인프라 (7개 언어) + Firebase Remote Config 통합 (2026-03-05)
- Firebase Crashlytics/Analytics 통합 + 버블 UX 대폭 개선 (2026-03-05)
- **로케일 자동 감지 + 문구 번역 표시 + edge-to-edge 내비바 수정 (2026-03-05)**

### 활성 작업
없음. 이번 세션 작업 모두 완료, main 커밋됨.

### 보류/백로그
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- 리뷰 연기 이슈: I1(IdolSelectScreen setState→Riverpod), I6(즐겨찾기 템플릿 메타데이터)
- todaySuggestedPhrases에 memberName 미전달 (멤버 템플릿 "오늘" 추천 미포함 — known limitation)
- 관리 대시보드 + R2 동기화 (출시 후 1~2주)
- share_card_painter.dart UiStrings 잔류 (BuildContext 없음, Phase 7에서 처리)
- Provider 내 UiStrings 잔류 (BuildContext 없음, Phase 7에서 처리)
- P1: 핸들 좌측 멤버 이름 노출 (버블 UX 패널 후속)

---

## 작업 요약

로케일 하드코딩(ko) 제거 → 폰 시스템 언어 자동 감지(en fallback). 간편모드 팩 문구 카드에 사용자 언어 번역 표시 추가. 페이지 인디케이터 SafeArea 적용. 미니 컨버터 edge-to-edge 내비바 색상 불일치 수정 (AnnotatedRegion 오버라이드 + resumed 시 재적용). 5파일 변경, 627 tests pass.

## 완료된 작업

- [x] `app.dart` — `locale: const Locale('ko')` 하드코딩 제거 → 시스템 언어 자동 따름
- [x] `l10n.yaml` — `preferred-supported-locales: [en, ko]` → 미지원 언어 en fallback
- [x] `compact_phrase_list.dart` `_PhraseCard` — `phrase.translations[locale]` 번역 표시 추가 (한국어면 미표시, en fallback)
- [x] `compact_phrase_list.dart` 페이지 인디케이터 — `SafeArea` + `bottom: 8` (시스템 핸들 가림 수정)
- [x] `mini_converter_screen.dart` — `_applyEdgeToEdge()` 메서드 추출, `initState` + `didChangeAppLifecycleState(resumed)` 양쪽 호출 (캐시 엔진 재진입 수정)
- [x] `mini_converter_screen.dart` — `AnnotatedRegion<SystemUiOverlayStyle>` 추가, `FangeulApp`의 불투명 내비바 색상 오버라이드
- [x] `mini_converter_screen.dart` — 시트 높이에 `viewPadding.bottom` 추가 (내비바 영역까지 배경 채움)

## 진행 중인 작업
없음.

## 핵심 교훈

- ★ 캐시 FlutterEngine에서 `AnnotatedRegion`은 위젯 트리 가장 가까운 것이 우선 → 부모(`FangeulApp`)의 불투명 내비바 설정을 자식(`MiniConverterScreen`)에서 투명으로 오버라이드 가능 (2026-03-05)
- ★ Flutter l10n: `preferred-supported-locales` 첫 번째 항목이 fallback 언어 — `[en, ko]`로 설정해야 미지원 언어에서 영어 UI (2026-03-05)
- ★ `locale:` 파라미터를 MaterialApp에 지정하지 않으면 폰 시스템 언어 자동 감지 (2026-03-05)

## 다음 단계

### 1순위: UX 디테일 논의 (사용자 요청)
1. 설정에 언어 변경 기능 — 폰 시스템 언어와 별개로 앱 내 언어 선택
2. 팝업 `···` 메뉴에 "리뷰하기"/"문의하기" 추가 여부
3. 버블 버튼 디자인 변경 — 현재 '한' 텍스트 → 캐릭터/심볼 이미지로

### 2순위: Firebase 콘솔 설정 + 학습
- Firebase Remote Config 콘솔에서 7개 매개변수 추가
- Firebase Analytics 이벤트 계측 학습
- 에뮬레이터에서 로케일별 동작 확인

### 3순위: Phase 7 릴리즈 준비
- ProGuard/R8 설정 + 릴리즈 빌드 검증
- Play Store 리스팅 + 스크린샷

### 4순위: 백로그 정리
- P1: 핸들 좌측 멤버 이름 노출 (버블 UX)
- share_card_painter.dart + Provider 파일 UiStrings → l10n
- LOW 이슈 (L3, L4, L5), I1, I6

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| 미지원 언어 en fallback (ko 아님) | 타겟이 글로벌 K-pop 팬 — 한국어 UI는 대부분 외국인에게 부적절 |
| AnnotatedRegion 오버라이드 (SystemChrome 대신) | FangeulApp의 AnnotatedRegion이 매 리빌드마다 SystemChrome 설정 덮어씀 |

## 커밋 히스토리 (이번 세션)

```
8c82d4a fix: locale auto-detect, phrase translation display, edge-to-edge nav bar
```

## 수정한 파일

```
l10n.yaml                                          — preferred-supported-locales [en, ko]
lib/app.dart                                       — locale 하드코딩 제거
lib/l10n/app_localizations.dart                    — gen-l10n 재생성 (en 첫번째)
lib/presentation/screens/mini_converter_screen.dart — AnnotatedRegion + _applyEdgeToEdge + viewPadding
lib/presentation/widgets/compact_phrase_list.dart  — 번역 표시 + SafeArea 인디케이터
```

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
| Phase B 멤버 | 멤버 개인화 7 tasks + Codex 리뷰 Critical 수정 → 383 tests |
| Phase 6 설계 | 전문가 패널 5토픽 토론 + Claude×Codex 교차 리뷰 → 수익화 합의 문서 |
| Phase 6 구현 | 18 tasks + 2라운드 교차 리뷰 19건 수정 → 573 tests |
| 키보드+패널+버블 | 멀티모드 키보드 + 패널 UX 개선 + 버블 버그 4건 수정 → 616 tests |
| i18n+Firebase RC | 7개 언어 i18n + Firebase Remote Config + 3인 번역 QA → 627 tests |
| Crashlytics+버블UX | Firebase Crashlytics/Analytics + 버블 헤더 UX 통일 (패널 3차 4:0) → 627 tests |
| **로케일+번역+내비바** | 시스템 로케일 자동 감지 + 문구 번역 표시 + edge-to-edge 내비바 수정 → 627 tests |
