# Fangeul — Session Handoff

BASE_COMMIT: 88a7c9d (main, Phase B 완료)
HANDOFF_COMMIT: 737209b
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
- Phase 6 수익화 설계: 전문가 패널 토론 + Claude×Codex 교차 리뷰 완료 (2026-03-04)
- Phase 6 수익화 구현: 18 tasks + 2라운드 Claude×Codex 교차 리뷰 수정 완료 (2026-03-04)
- 멀티모드 키보드 + 패널 개선 + 버블 버그 수정 (2026-03-04)
- **i18n 인프라 (7개 언어) + Firebase Remote Config 통합 (2026-03-05)**

### 활성 작업
없음. 이번 세션 작업 모두 완료, main 커밋됨.

### 보류/백로그
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- 리뷰 연기 이슈: I1(IdolSelectScreen setState→Riverpod), I6(즐겨찾기 템플릿 메타데이터)
- todaySuggestedPhrases에 memberName 미전달 (멤버 템플릿 "오늘" 추천 미포함 — known limitation)
- 관리 대시보드 + R2 동기화 (출시 후 1~2주)
- share_card_painter.dart UiStrings 잔류 (BuildContext 없음, Phase 7에서 처리)
- Provider 내 UiStrings 잔류 (BuildContext 없음, Phase 7에서 처리)

---

## 작업 요약

Flutter l10n(ARB) 기반 i18n 인프라 구축 — 126개 UI 키를 7개 언어(ko, en, id, th, pt, es, vi)로 번역. 27개 위젯/화면 파일을 `UiStrings` → `L.of(context)` 마이그레이션. Firebase Remote Config 서비스 구현(7개 수익화 파라미터 서버 제어). 3인 리뷰어(Claude×2 + Codex) 번역 품질 검수. 89파일, +6158줄. 627 tests pass.

## 완료된 작업

### Track A: i18n 인프라 (Flutter ARB)
- [x] `pubspec.yaml`에 `flutter_localizations` + `intl` 추가, `flutter.generate: true` 설정
- [x] `l10n.yaml` 생성 — template: app_ko.arb, output class: L
- [x] 7개 ARB 파일 생성 (ko, en, id, th, pt, es, vi) — 126개 키, 16개 파라미터 키 포함
- [x] `lib/app.dart`에 l10n delegates + locale 설정
- [x] 27개 위젯/화면 파일 `UiStrings.xxx` → `L.of(context).xxx` 마이그레이션
- [x] 14개 테스트 파일에 l10n delegates 추가
- [x] 3인 번역 검수 (Claude A: EN/ID/TH, Claude B: PT/ES/VI, Codex: 전체) — 6건 수정 적용

### Track B: Firebase Remote Config
- [x] Firebase 의존성 추가 (`firebase_core`, `firebase_remote_config`, `firebase_analytics`)
- [x] Android gradle 설정 (google-services plugin)
- [x] `RemoteConfigValues` 엔티티 생성 (순수 Dart, 7개 필드)
- [x] `RemoteConfigService` 추상 인터페이스 + `NoopRemoteConfigService` + `FirebaseRemoteConfigService`
- [x] `remote_config_providers.dart` — keepAlive provider + overrideWithValue 패턴
- [x] `CheckHoneymoonUseCase` — static const → 생성자 주입 파라미터
- [x] `MonetizationProvider` — 6개 static const → ref.read(remoteConfigValuesProvider)
- [x] `ConversionTriggerProvider` — 하드코딩 → config 값 참조
- [x] `main.dart` — Firebase.initializeApp() + configService 초기화 + provider override
- [x] `google-services.json` gitignore에 추가
- [x] 디버그 APK 빌드 성공 검증

### 번역 품질 수정 (3인 합의)
- [x] EN: `favLimitIapButton` "Color Packs" → "Color Vibe Packs" (브랜드 일관성)
- [x] TH: `idolMemberLabel` → "ไบแอส" (K-pop 용어), `homeGreeting` 띄어쓰기
- [x] VI: Color Vibe 패키지명에 "cảm xúc" 추가 (브랜드 일관성)
- [x] PT/ES: `shopTitle` → "Pacotes/Paquetes Color Vibe" (브랜드명 보존)
- [x] ID: `miniTabRecent` → "Terakhir" (의미 정확성)

## 진행 중인 작업
없음.

## 핵심 교훈

- ★ l10n 마이그레이션 시 `const` 키워드 제거 필수 — `L.of(context).xxx`는 런타임 값이므로 `const Text(l.xxx)` 컴파일 에러. 위젯 트리 전체에서 `const` 제거 필요 (2026-03-05)
- ★ `firebase_analytics` 버전 매칭 주의 — `^11.6.1` 미존재, `^11.6.0` 사용 (2026-03-05)
- ★ Flutter l10n: `flutter.generate: true` 시 gen-l10n 출력이 `lib/l10n/`에 생성됨 (`.dart_tool/`이 아님) — import 경로 `package:fangeul/l10n/app_localizations.dart` (2026-03-05)
- ★ 테스트에서 `L.of(context)` 사용 위젯은 MaterialApp에 반드시 `localizationsDelegates: L.localizationsDelegates, supportedLocales: L.supportedLocales, locale: const Locale('ko')` 추가 (2026-03-05)
- ★ 3인 번역 리뷰(Claude×2 + Codex) — K-pop 용어/브랜드명 일관성 같은 도메인 지식 이슈를 효과적 포착 (2026-03-05)

## 다음 단계

### 1순위: Firebase 콘솔 설정 + 학습
- Firebase Remote Config 콘솔에서 7개 매개변수 추가 (honeymoonDays, defaultSlotLimit, dailyAdLimit, adCooldownMinutes, unlockDurationHours, dailyTtsLimit, conversionTriggerAdCount)
- Firebase Analytics 이벤트 계측 학습 (사용자 요청 — 백엔드 개발자로서 앱 분석 스킬 부족)
- 에뮬레이터에서 로케일별 동작 확인 (ko→en→id→th→pt→es→vi + 미지원 로케일 fallback)

### 2순위: Phase 7 릴리즈 준비
- Crashlytics 연동
- ProGuard/R8 설정 + 릴리즈 빌드 검증
- Play Store 리스팅 + 스크린샷

### 3순위: 실기기 통합 테스트
- AdMob 실제 광고 단위 ID 연결
- IAP Play Console 설정 + 테스트 결제
- 플로팅 버블 + 수익화 교차 동작 확인

### 4순위: 백로그 정리
- share_card_painter.dart + Provider 파일 UiStrings → l10n 전환 (BuildContext 전달 방법 설계)
- LOW 이슈 (L3, L4, L5)
- IdolSelectScreen setState→Riverpod (I1)
- 즐겨찾기 템플릿 메타데이터 (I6)

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| ARB 7개 언어 = assets/phrases 번역 언어와 동일 | 문구+UI 언어 일치로 UX 통일 |
| L.of(context) 패턴, UiStrings 유지 | Provider 등 context 없는 곳은 UiStrings 유지, 점진적 전환 |
| RemoteConfigService 추상화 | NoOp → Firebase 전환 용이, 테스트 격리 |
| 생성자 주입 (UseCase 파라미터) | 기존 테스트 기본값으로 동작 보장, RC 미연결 시에도 안전 |
| google-services.json gitignore | API 키 포함 — 각 개발자가 Firebase 콘솔에서 개별 다운로드 |

## 커밋 히스토리 (이번 세션)

```
951d633 feat: i18n infrastructure (7 languages) + Firebase Remote Config
```

## 수정한 파일

```
신규 (23개):
  l10n.yaml                                          — l10n 설정
  lib/l10n/app_ko.arb                                — 한국어 (126키 템플릿)
  lib/l10n/app_en.arb                                — English
  lib/l10n/app_id.arb                                — Bahasa Indonesia
  lib/l10n/app_th.arb                                — ภาษาไทย
  lib/l10n/app_pt.arb                                — Português
  lib/l10n/app_es.arb                                — Español
  lib/l10n/app_vi.arb                                — Tiếng Việt
  lib/l10n/app_localizations*.dart (8개)              — gen-l10n 출력
  lib/core/entities/remote_config_values.dart         — RC 엔티티 (순수 Dart)
  lib/services/remote_config_service.dart             — 추상 인터페이스
  lib/services/noop_remote_config_service.dart        — NoOp 구현
  lib/services/firebase_remote_config_service.dart    — Firebase 구현
  lib/presentation/providers/remote_config_providers.dart — Riverpod provider
  test/core/entities/remote_config_values_test.dart   — RC 엔티티 테스트
  test/services/noop_remote_config_service_test.dart  — NoOp 서비스 테스트

수정 (lib — 30+개):
  pubspec.yaml                                       — 의존성 추가
  lib/app.dart                                       — l10n delegates + locale
  lib/main.dart                                      — Firebase init + RC provider override
  lib/core/usecases/check_honeymoon_usecase.dart     — 생성자 주입
  lib/presentation/providers/monetization_provider.dart — RC 값 읽기
  lib/presentation/providers/conversion_trigger_provider.dart — RC 값 참조
  lib/presentation/screens/*.dart (7개)               — UiStrings → L.of(context)
  lib/presentation/widgets/*.dart (20개)              — UiStrings → L.of(context)
  android/settings.gradle                            — google-services plugin
  android/app/build.gradle                           — google-services plugin

수정 (test — 14개):
  test/presentation/**/*_test.dart (14개)            — l10n delegates 추가
  test/core/usecases/check_honeymoon_usecase_test.dart — 커스텀 파라미터 케이스
```

## 참고 컨텍스트

- **Firebase 프로젝트**: Tiger Room 계정 Default Account for Firebase에 Fangeul 프로젝트 생성됨
- **google-services.json**: `android/app/google-services.json`에 배치 완료 (gitignored)
- **사용자 학습 요청**: Firebase Analytics 이벤트 계측, Remote Config 콘솔 설정을 차근차근 가르쳐달라고 요청함
- **번역 QA 프로세스**: 3인 병렬 리뷰(Claude Agent A + B + Codex CLI `--sandbox read-only`)가 효과적이었음

## 리뷰 연기 이슈 (post-MVP)

| ID | 내용 | 심각도 | 이유 |
|----|------|--------|------|
| I1 | IdolSelectScreen에서 setState 사용 | LOW | 순수 ephemeral UI 상태 |
| I6 | 즐겨찾기 템플릿 메타데이터 손실 | LOW | ko 텍스트는 정상 표시 |
| I10 | todaySuggestedPhrases 멤버 미지원 | LOW | MVP known limitation |
| I11 | share_card_painter.dart UiStrings 잔류 | LOW | BuildContext 없음, Phase 7 |
| I12 | Provider 파일 UiStrings 잔류 | LOW | BuildContext 없음, Phase 7 |

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
| **i18n+Firebase RC** | 7개 언어 i18n + Firebase Remote Config + 3인 번역 QA → 627 tests |
