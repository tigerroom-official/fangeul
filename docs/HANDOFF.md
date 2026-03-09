# Fangeul — Session Handoff

BASE_COMMIT: 6b6e33b (이전 핸드오프)
HANDOFF_COMMIT: 09c8cae
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
- 로케일 자동 감지 + 문구 번역 표시 + edge-to-edge 내비바 수정 (2026-03-05)
- 설정 화면: 언어 변경 + 리뷰/문의 메뉴 + overflow 수정 + 스플래시 깜빡임 수정 + AGP 업그레이드 (2026-03-06)
- 로케일별 번역 표시 수정 + 컨버터 힌트 탭별 전환 + 스마트 기본 필터 + v1.0.0 (2026-03-06)
- AdMob 광고 배치 + 팬 컬러 테마 커스터마이징 13 tasks (2026-03-07)
- 최애색(Choeae Color) UX 오버홀 — 15 tasks + 5 review fixes (2026-03-07)
- HSL→HCT 엔진 교체 P0 완료 (2026-03-07)
- 테마 커스터마이징 전면 업그레이드 (2026-03-08): 2D HCT 피커, 슬롯, 3-SKU IAP, brightnessOverride, chroma 85%, 804 tests
- **보상형 광고 피벗 (2026-03-09)**: TTS/즐겨찾기 시간제 해금 폐지 → 프리미엄 테마 24h 체험 전용
- **IAP UI 마무리 (2026-03-09)**: subtitle 설명 추가, 번들 "추천" 뱃지, Codex 리뷰 수정
- **즐겨찾기 제한 UX 개선 (2026-03-09)**: 다이얼로그 직접적 메시지, SnackBar CTA 개선, 버블 해결 경로 추가, Codex 리뷰 반영, 812 tests

### 활성 작업
없음. main 브랜치에 전체 작업 머지 완료.

### 보류/백로그 — MVP 출시 후
- **v1.1 기능**: 한글 퍼즐(Wordle 스타일), 한글 카드 컬렉션(가챠)
- **v1.1+ 기능**: 푸시 알림(firebase_messaging), 구독 모델
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- 리뷰 연기 이슈: I1(IdolSelectScreen setState→Riverpod), I6(즐겨찾기 템플릿 메타데이터)
- todaySuggestedPhrases에 memberName 미전달 (멤버 템플릿 "오늘" 추천 미포함)
- share_card_painter.dart + Provider 내 UiStrings 잔류 (BuildContext 없음)
- P1: 핸들 좌측 멤버 이름 노출 (버블 UX)
- **P1: 버블 딥링크** — openMainApp 시 ThemePickerSheet 자동 오픈 (intent extra `open_theme_picker`)
- Play Integrity API (서버사이드 검증)
- AdMob SSV (Server-Side Verification)
- converter_screen 배너 = 리텐션 데이터로 결정 (v1.1)
- 즐겨찾기 포화/TTS 한도 FanPassButton 트리거 (v1.1)
- IAP "테마 슬롯 3개" → "최애 테마 3개 저장" 문구 리프레이밍 (P2)
- P2: "팬글 서포터" 리프레이밍 — IAP를 "응원" 프레이밍으로 (Phase 7.1)

---

## 작업 요약

보상형 광고 피벗(테마 24h 체험 전용) + IAP UI subtitle/추천 뱃지 + Codex 리뷰 수정 + 즐겨찾기 제한 UX 전면 개선(다이얼로그 메시지 직접화, SnackBar CTA "무제한 해금", 버블 "앱에서 해금" + openMainApp, IAP subtitle에 "즐겨찾기 무제한" 명시) + 7개 언어 l10n 업데이트 + Codex 리뷰 3건 수정. 812 tests pass.

## 완료된 작업

- [x] 보상형 광고 피벗: TTS/즐겨찾기 시간제 해금 폐지 → 테마 24h 체험 전용 (8efe944)
- [x] Codex 리뷰 수정: trial palette 접근 가드, RC TTS limit, debug 패널 rename (8c764b6)
- [x] IAP subtitle 추가 + 번들 "추천" 뱃지 (7ad8604)
- [x] l10n 생성 파일 포함 + VI "concert" 미번역 수정 (a1ec520)
- [x] 즐겨찾기 제한 다이얼로그 메시지 직접화: "아무 테마 상품 하나만 구매하면 즐겨찾기 무제한! ₩990부터" (e3d717f)
- [x] 즐겨찾기 제한 SnackBar CTA: "테마 커스터마이징 보기" → "즐겨찾기 무제한 해금" (e3d717f)
- [x] 버블 즐겨찾기 제한: SnackBar에 "앱에서 해금" 버튼 + MethodChannel openMainApp (e3d717f)
- [x] IAP subtitle에 "즐겨찾기 무제한" 명시 — 구매→혜택 연결 (e3d717f)
- [x] `barrierDismissible: false` — 첫 다이얼로그 실수 닫힘 방지 (e3d717f, Codex 지적)
- [x] ID/TH/VI 번역 품질: 구매→해금 인과 연결 동사 추가 (e3d717f, Codex 지적)
- [x] 7개 언어 l10n 업데이트 (ko/en/es/id/pt/th/vi)
- [x] 테마 오버홀 잔여 커밋 정리 (ff5177c)
- [x] 812 tests pass + flutter analyze clean

## 진행 중인 작업
없음.

## 핵심 교훈

- ★ 즐겨찾기 제한 UX: "왜 테마를 사야 즐겨찾기가 풀리는지" 명시적으로 전달해야 함 — CTA "테마 보기"는 무관하게 느껴짐. "즐겨찾기 무제한 해금"이 직접적
- ★ IAP subtitle에 부가 혜택(즐겨찾기 무제한) 명시 → 구매 동기와 혜택을 한눈에 연결
- ★ `barrierDismissible: false`: 설명형 첫 다이얼로그는 바깥 터치로 닫히면 안 됨 — seen 플래그가 영구 저장되어 재표시 불가
- ★ 동남아 번역(ID/TH/VI)에서 구매→해금 인과관계 동사 누락 쉬움 — 각 언어별 "~하면 ~된다" 구조 확인 필수
- ★ 보상형 광고 피벗: 기능 해금(즐겨찾기/TTS)에 시간제 해금 적용 → 사용자 혼란+가치 희석. IAP 직행이 명확

## 다음 단계

### 1순위: Phase 7 릴리즈 BLOCK 항목 (출시 필수)
1. **릴리즈 서명 설정** — keystore 생성 + signingConfigs.release
2. **프로덕션 AdMob ID** — placeholder 교체
3. **ProGuard/R8 활성화** — minifyEnabled + shrinkResources
4. **Google Play Console** — 앱 등록 + IAP 상품 가격 설정

### 2순위: 출시 후 빠른 개선
- P1: 버블 딥링크 — openMainApp → ThemePickerSheet 자동 오픈 (intent extra)
- P1: 핸들 좌측 멤버 이름 노출
- PaletteRegistry 20-25개 확장 (웜톤/쿨톤 균형)
- 프리뷰 UI — 실제 화면 미리보기
- share_card_painter.dart UiStrings → l10n
- Firebase Analytics 이벤트 대시보드 구성

### 3순위: v1.1 로드맵
- IAP "테마 슬롯 3개" → "최애 테마 3개 저장" 리프레이밍 (P2)
- P2: "팬글 서포터" 리프레이밍
- 한글 퍼즐 (Wordle 스타일)
- 한글 카드 컬렉션 (가챠)
- 푸시 알림 (firebase_messaging)
- 구독 모델 (Phase 7+)

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| 보상형 → 테마 24h 체험 전용 | TTS/즐겨찾기 시간제 해금은 사용자 혼란+가치 희석 → IAP 직행이 명확 |
| CTA "즐겨찾기 무제한 해금" | "테마 보기"는 구매→혜택 연결 불명확 → 혜택 직접 언급 |
| `barrierDismissible: false` | seen 플래그 영구 저장 → 실수 닫힘 시 재표시 불가 |
| IAP subtitle에 "즐겨찾기 무제한" | 테마에 관심 없는 유저도 구매 동기 획득 |
| 버블 → "앱에서 해금" | 소형 윈도우에서 ThemePickerSheet 부적절 → 메인앱 전환이 현실적 |

## 참고 컨텍스트

- 보상형 광고 피벗: `docs/discussions/2026-03-08-rewarded-ad-strategy-pivot.md`
- 테마 커스터마이징 오버홀 계획: `docs/plans/2026-03-07-choeae-color-ux-overhaul.md`
- Surface 계층 + 슬롯 패널: `docs/discussions/2026-03-08-theme-surface-hierarchy-slots.md`
- IAP 3-SKU 구조 패널: `docs/discussions/2026-03-08-theme-iap-structure-panel.md`
- 밝기 독립 패널: `docs/discussions/2026-03-08-theme-brightness-independence-panel.md`
- 글자색 hex+WCAG 패널: `docs/discussions/2026-03-08-text-color-hex-2d-picker-wcag-panel.md`
- HCT 피커 UX 재설계: `docs/discussions/2026-03-07-picker-ux-redesign.md`
- 최애색 시스템 근본 재설계: `docs/discussions/2026-03-07-theme-ux-supplementary.md`

## 커밋 히스토리 (이번 세션)

```
ff5177c feat: theme overhaul — 2D HCT picker, slots, brightness override, IAP section
e3d717f feat: favorite limit UX — dialog, SnackBar CTA, bubble action, Codex fixes
a1ec520 fix: include generated l10n files + fix VI untranslated "concert"
7ad8604 feat: IAP UI polish — subtitle descriptions + "추천" badge for bundle
8c764b6 fix: apply Codex review — trial palette access, RC TTS limit, debug panel rename
8efe944 feat: pivot rewarded ads to 24h theme trial only (TTS/favorites = IAP-only unlock)
8838e1b docs: add panel discussions and plans from theme overhaul sessions
fca759d chore: session handoff — 테마 오버홀 완료 (2D HCT 피커, 슬롯, 3-SKU, chroma 85%)
```

## 수정한 파일

```
63 files changed, 5434 insertions(+), 599 deletions(-)

주요 신규:
 lib/presentation/widgets/favorite_limit_dialog.dart (NEW — 즐겨찾기 제한 다이얼로그)
 lib/presentation/widgets/favorite_limit_feedback.dart (NEW — 즐겨찾기 제한 피드백 유틸)

주요 수정:
 lib/presentation/widgets/theme_picker_sheet.dart (IAP subtitle + 추천 뱃지)
 lib/presentation/widgets/compact_phrase_list.dart (즐겨찾기 제한 피드백 연동)
 lib/presentation/widgets/compact_phrase_tile.dart (즐겨찾기 제한 피드백 연동)
 lib/presentation/widgets/phrase_card.dart (즐겨찾기 제한 피드백 연동)
 lib/presentation/providers/monetization_provider.dart (hasAnyIap + 보상형 피벗)
 lib/presentation/providers/favorite_phrases_provider.dart (IAP 무제한 연동)
 lib/presentation/providers/tts_provider.dart (보상형 피벗)
 lib/l10n/app_*.arb (7개 언어 × favLimit/IAP subtitle 키)
 .claude/rules/00-project.md (수익화 규칙 업데이트)
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
| Crashlytics+버블UX | Firebase Crashlytics/Analytics + 버블 헤더 UX 통일 → 627 tests |
| 로케일+번역+내비바 | 시스템 로케일 자동 감지 + 문구 번역 표시 + edge-to-edge 내비바 수정 → 627 tests |
| 설정+UX수정 | 언어 변경/리뷰/문의 메뉴 + overflow 수정 + 스플래시 깜빡임 수정 + AGP 업그레이드 → 627 tests |
| 번역+필터+실기기 | 로케일별 번역 수정 + 스마트 필터 + 간편모드 번역 + 실기기 테스트 → 624 tests |
| AdMob+테마 | AdMob 배치 + 팬 컬러 테마 커스터마이징 13 tasks → 641 tests |
| 최애색+HCT | 최애색 UX 오버홀 15 tasks + HSL→HCT P0 엔진 교체 + Codex 4-domain 리뷰 → 741 tests |
| 테마 오버홀 | 2D HCT 피커 + 슬롯 + 3-SKU IAP + brightnessOverride + chroma 85% + hex 크래시 수정 → 804 tests |
| **보상형피벗+즐겨찾기UX** | 보상형→테마 체험 전용 + IAP subtitle/추천 + 즐겨찾기 UX 개선 + Codex 리뷰 → 812 tests |
