# Fangeul — Session Handoff

BASE_COMMIT: 8cc2d80 (이전 핸드오프)
HANDOFF_COMMIT: (미커밋 — v1.0.0+13 AAB 빌드 완료)
BRANCH: main

---

## 프로젝트 상태 (누적)

### 완료된 마일스톤
- Phase 1~6: Core 엔진 + 데이터 + UI + 버블 + 수익화 전체 완료
- **v1.0.0+10 프로덕션 출시 완료** — Play Store 공개
- **v1.0.0+13 배너 정책 변경 빌드** — Play Console 업로드 완료, 검토 대기
- GitHub Pages 랜딩페이지 + Google Search Console
- 키보드 전면 리팩토링 (Gboard 방식) + 숫자/특수문자 토글 + 커서 편집

### 활성 작업
- **v1.0.0+13 Play Store 검토 대기** — 배너 정책 변경 포함
- 검토 완료 후 프로덕션 공개

### 보류/백로그 — 출시 후
- **v1.1 TTS**: 카드 문구 탭에서 한글 TTS 재생 (GPU 서버 자체 생성)
- **v1.1 기능**: 한글 퍼즐(Wordle 스타일), 한글 카드 컬렉션(가챠)
- **v1.1+ 기능**: 푸시 알림(firebase_messaging), 구독 모델
- IAP subtitle에 "광고 제거" 문구 추가 검토 (전환율 데이터 보고 판단)
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- 리뷰 연기 이슈: I1(IdolSelectScreen setState→Riverpod), I6(즐겨찾기 템플릿 메타데이터)
- P1: 핸들 좌측 멤버 이름 노출 (버블 UX)
- P1: 버블 딥링크 — openMainApp → ThemePickerSheet 자동 오픈
- Play Integrity API / AdMob SSV
- PaletteRegistry 20-25개 확장
- IAP "팬글 서포터" 리프레이밍 (Phase 7.1)

---

## 작업 요약

배너 광고 정책 전면 변경: Day 7 지연 → 온보딩 완료 후 즉시 노출 (RC `banner_delay_days` 기본 0). 보상형 시청/세션 기반 배너 숨김 완전 제거 → IAP 구매 시만 배너 숨김. `sessionBannerHiddenProvider` 코드 완전 삭제. Firebase Console `unlock_duration_hours` 4→24 수정, `banner_delay_days=0` 추가. 전문가 패널 2회 + Codex 교차 리뷰 2회로 검증.

## 완료된 작업

- [x] 배너 Day 7 → Day 0 전환 — `daysSince < 7` → `!onboardingDone || daysSince < rcBannerDelayDays`
- [x] `isOnboardingDoneProvider` 신규 생성 (SharedPreferences 기반, keepAlive)
- [x] `RemoteConfigValues.bannerDelayDays` 필드 추가 (기본 0)
- [x] `FirebaseRemoteConfigService`에 `banner_delay_days` defaults + 읽기 추가
- [x] `idol_select_screen.dart`에 `ref.invalidate(isOnboardingDoneProvider)` 추가
- [x] 배너에서 `isUnlocked`/`sessionHidden` 조건 완전 제거 — IAP만 배너 숨김
- [x] `sessionBannerHiddenProvider` 코드 완전 삭제 (provider, 테스트, import)
- [x] `fan_pass_button.dart`에서 `sessionBannerHidden.hide()` 호출 제거
- [x] 배너 테스트 11개 재작성 (온보딩+RC 기반)
- [x] `00-project.md` 광고 정책 업데이트 (2곳)
- [x] stale "Day 7" 주석 정리 (phrases_screen, settings_screen)
- [x] Firebase Console: `banner_delay_days=0` 추가, `unlock_duration_hours` 4→24 수정
- [x] v1.0.0+13 AAB 빌드 + Play Console 업로드

## 핵심 교훈

- ★ 유틸리티 앱 Day 7 리텐션 12~15% → Day 7 배너 지연은 85%+ 유저에게 배너 한 번 못 보여주고 이탈시킴 (수익 자해)
- ★ Day X부터 갑자기 배너 나타나면 "업데이트 후 광고 넣었네" 1성 리뷰 → 처음부터 있으면 "원래 이런 앱"으로 수용
- ★ 보상형 시청 시 배너 24h 숨김 = 수익 자기 잠식. DAU 10K 기준 월 $300 손실. 보상형 시청 동기는 테마 체험이지 배너 숨김이 아님
- ★ 테마 체험(₩990 IAP의 미리보기)에서 배너 제거는 과잉 — 구독 모델($5+/월)에서나 기대하는 수준
- ★ "IAP 구매 시 배너 제거"가 오히려 추가 구매 동기로 작용 (sunk cost 없이 얻는 보너스)
- ★ Firebase RC `banner_delay_days`로 배너 시점을 원격 제어 가능 — 앱 업데이트 없이 즉시 롤백
- ★ Firebase Console의 RC 값이 코드 기본값과 불일치할 수 있음 (unlock_duration_hours 4 vs 24) — 피벗 후 Console 값 업데이트 필수

## 핵심 결정사항

| 결정 | 이유 | 근거 |
|------|------|------|
| 배너 Day 7 → Day 0 (온보딩 후) | Day 7 리텐션 12~15%, 85%+ 유저 이탈 | 전문가 패널 만장일치 + ASO 전문가 조언 |
| RC `banner_delay_days` 도입 | 문제 시 앱 업데이트 없이 즉시 롤백 | Codex 리뷰 + 패널 4:0:1 |
| 보상형 시청 시 배너 숨김 제거 | DAU 10K 기준 월 $300 누수, 시청 동기는 테마 | 2차 패널 만장일치 |
| sessionBannerHidden 완전 삭제 | 미사용 코드 혼란 방지, 재활용 시 재구현 | 사용자 결정 |
| IAP subtitle 광고 제거 문구 보류 | 전환율 데이터 없이 판단 불가, 서프라이즈 효과 | 데이터 드리븐 판단 유보 |

## 다음 단계

### 1순위: v1.0.0+13 검토 완료 대기
- Play Store 검토 통과 확인
- 일본 vs 동남아 배너 리텐션 비교 모니터링

### 2순위: v1.1 TTS 구현
1. **TTS 음성 생산** — GPU 서버에서 Qwen/오픈소스 TTS로 전체 문구 음성 생성
2. **Cloudflare R2 업로드** — mp3/ogg 파일 CDN 캐싱
3. **카드 문구 탭 TTS UI** — 재생 버튼 + just_audio 재생

### 3순위: 출시 후
- Firebase Analytics 대시보드 구성
- 배너 수익 데이터 → IAP subtitle "광고 제거" 문구 추가 여부 결정
- 스크린샷 갱신 (숫자 키보드, 최신 UI)

## 참고 컨텍스트

- 배너 정책 패널 토론: 이번 세션 대화 (2026-04-06)
- 보상형 피벗 토론: `docs/discussions/2026-03-08-rewarded-ad-strategy-pivot.md`
- 스펙 문서: `docs/superpowers/specs/2026-04-06-banner-day0-migration-design.md`
- 랜딩페이지: `tigerroom-official.github.io/fangeul/`

## 변경 파일 목록 (이번 세션)

| 파일 | 변경 |
|------|------|
| `lib/core/entities/remote_config_values.dart` | `bannerDelayDays` 필드 추가 |
| `lib/services/firebase_remote_config_service.dart` | `banner_delay_days` defaults + 읽기 |
| `lib/presentation/providers/onboarding_providers.dart` | **신규** — `isOnboardingDoneProvider` |
| `lib/presentation/providers/onboarding_providers.g.dart` | 자동 생성 |
| `lib/presentation/providers/session_state_provider.dart` | `SessionBannerHidden` 삭제 |
| `lib/presentation/providers/session_state_provider.g.dart` | 재생성 |
| `lib/presentation/widgets/banner_ad_widget.dart` | 가드 조건 전면 교체 |
| `lib/presentation/widgets/fan_pass_button.dart` | `sessionBannerHidden.hide()` 제거 |
| `lib/presentation/screens/idol_select_screen.dart` | `ref.invalidate` 추가 |
| `lib/presentation/screens/phrases_screen.dart` | stale 주석 수정 |
| `lib/presentation/screens/settings_screen.dart` | stale 라벨 수정 |
| `test/presentation/widgets/banner_ad_widget_test.dart` | 11개 테스트 재작성 |
| `test/presentation/widgets/fan_pass_test.dart` | session banner 테스트 삭제 |
| `test/presentation/providers/session_state_provider_test.dart` | session banner 테스트 삭제 |
| `.claude/rules/00-project.md` | 광고 정책 업데이트 (2곳) |
| `pubspec.yaml` | 1.0.0+12 → 1.0.0+13 |
| `docs/superpowers/specs/2026-04-06-banner-day0-migration-design.md` | **신규** — 스펙 문서 |

## 세션 히스토리

| 세션 | 요약 |
|------|------|
| P1~P3 | Core 엔진 + 데이터 레이어 완료 |
| P4 | UI 화면 구현 (홈, 변환기, 문구, 설정) |
| P5 | 플로팅 버블 전체 구현 + 리뷰 수정 |
| Sprint 1~2 | MVP UX + 상황태그 + K-pop 캘린더 |
| MVP 통합 | 마이아이돌 + 템플릿 + 온보딩 |
| Phase B~6 | 멤버 개인화 + 수익화 설계+구현 |
| i18n~설정 | 7개 언어 + Firebase + 버블 UX + 설정 |
| AdMob~테마 | 광고 + 팬 컬러 + HCT + 슬롯 + IAP |
| 릴리즈준비 | ProGuard + 서명 + UX 수정 + v1.0.0+4 |
| 크래시+스토어 | BadPaddingException + 에셋 + v1.0.0+5 |
| 프로덕션 출시 | IAP bypass + 키보드 리팩토링 + 랜딩페이지 + v1.0.0+10 |
| **배너 정책 변경** | Day 7→Day 0 + 보상형 배너숨김 제거 + sessionBanner 삭제 + v1.0.0+13 |
