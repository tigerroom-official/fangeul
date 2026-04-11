# Fangeul — Session Handoff

BASE_COMMIT: 7c9e55c (이전 핸드오프)
HANDOFF_COMMIT: ac98bef
BRANCH: main

---

## 프로젝트 상태 (누적)

### 완료된 마일스톤
- Phase 1~6: Core 엔진 + 데이터 + UI + 버블 + 수익화 전체 완료
- v1.0.0+10 프로덕션 출시
- v1.1.0+19 TTS 재생 + Analytics 출시
- v1.1.1+20 버블 아이콘 간격 수정 출시
- **v1.1.2+21 프로덕션 검토 중** — IAP 에러 다이얼로그 + AppConstants + TTS persist + Flutter 3.41.6

### 활성 작업
- v1.1.2+21 Play Store 검토 대기
- R2 mp3 볼륨 노멀라이즈 업로드 완료 (CDN 퍼지 필요)

### 보류/백로그
- **팬 미션**: 데일리 문구 타이핑 챌린지 + K-pop 캘린더 연동 (설계 완료)
- **키보드 키 하이라이트**: 변환 결과 자모 해당 키 하이라이트 (설계 완료)
- **InAppReview requestReview()**: DAU 쌓인 후 적절한 타이밍에 자동 표시
- **Firebase Analytics screen_view**: GoRouter observer 추가
- **유저 속성**: language, idol, IAP status setUserProperty
- **K-pop 데이터 확장**: kpopatlas.com API 크롤 → R2/Firebase 호스팅
- **IAP subtitle 다국어**: "+ TTS 무제한" 추가
- 기존 백로그: 푸시 알림, 구독 모델, Play Integrity API, PaletteRegistry 확장

---

## 이번 세션 작업 요약

### IAP 결제 에러 다이얼로그
- `rootNavigatorKey` + `MaterialApp.builder`로 앱 최상위 리스너 (`_IapErrorListener`)
- `IapService._onError` 필드 — stream error + buyPack 실패 → `iapErrorProvider` → 다이얼로그
- `ThemePickerSheet.initState`에서 stale error 클리어
- Material 3 다이얼로그: 에러 아이콘 + 안내 문구 + 문의하기(launchUrl) + 확인(OK)
- 8개 언어 arb: iapErrorTitle/Body/Contact

### AppConstants 중앙화
- `lib/presentation/constants/app_constants.dart` — 모든 URL, 이메일, 패키지 ID
- settings_screen, app.dart, iap_error_dialog, tts_service에서 하드코딩 제거

### TTS Played IDs 영속화
- `sessionPlayedIds` (메모리) → `TtsPlayedIds` (SharedPreferences + Riverpod Notifier)
- 앱 재시작 후에도 오늘 들은 문구 유지
- 날짜 변경 시 자동 클리어 (`build()`에서 date 체크)
- `shell_scaffold` + `mini_converter_screen` resume 시 invalidate

### 일일 카운터 리셋
- `main.dart`에서 `checkDailyReset()` 호출 (앱 시작 시)
- `monetizationNotifierProvider` resume 시 invalidate

### AndroidManifest <queries>
- `mailto:` + `https:` intent query 추가 (Android 11+ 패키지 가시성)

### Flutter 업그레이드
- 3.41.2 → 3.41.6 (surface deadlock 수정)
- in_app_purchase_android 0.4.0+8 → 0.4.0+10

### TTS 뱃지 개선
- 빨간 뱃지(0회) 제거 → 항상 primaryContainer
- 디버그 패널: TTS count/reset/max + IAP Error 3s 테스트 칩

### mp3 볼륨 노멀라이즈
- 전체 90개 mp3: -29dB → -20dB (EBU R128 loudnorm)
- `tts_mp3_up/` 폴더 → R2 덮어씌우기 완료

---

## 핵심 교훈

- ★ `rootNavigatorKey.currentContext` ≠ Navigator 아래 context: `MaterialApp.builder`에서 `showDialog` 안 됨. `_IapErrorListener` ConsumerWidget으로 감싸서 해결
- ★ `showDialog`는 Navigator 아래 context 필요: GoRouter `navigatorKey`를 GlobalKey로 설정 → `rootNavigatorKey.currentContext`로 접근
- ★ 디버그 칩에서 `Future.delayed` + `ref.read` → 설정 화면 dispose 후 `ref` 무효. `ProviderScope.containerOf(context)` 사용
- ★ `sessionPlayedIds` 메모리 Set → 앱 재시작 시 리셋 → SharedPreferences 영속화 필수
- ★ `canPlayTtsProvider` 죽은 코드 — `playTtsProvider`가 직접 gating하므로 제거
- ★ 에뮬레이터 Gmail 구버전(2020) cold start 크래시 — 코드 문제 아님, Gmail 업데이트로 해결
- ★ 하드코딩 URL/이메일 → `AppConstants` 중앙화 (팀 관리 구조)
- ★ mp3 볼륨 -29dB은 저사양 스피커에서 안 들림 → EBU R128 노멀라이즈 -20dB
- ★ `<queries>` 없이 `canLaunchUrl` → Android 11+에서 false 반환 (url_launcher README 필수 참조)

## 다음 세션

### 1순위
- v1.1.2+21 검토 완료 확인
- Firebase Analytics 대시보드 — 이벤트 유입 확인

### 2순위
- 팬 미션 구현 ("오늘의 팬 미션" — 문구 타이핑 챌린지)
- 키보드 키 하이라이트 (자모 해당 키 반짝이기)
- screen_view 추적 (GoRouter observer)

### 3순위
- K-pop 데이터 확장 (kpopatlas.com API)
- IAP subtitle 다국어 업데이트 ("+ TTS 무제한")
- InAppReview requestReview() 적절한 타이밍

## 참고 컨텍스트

- TTS 토론: `docs/discussions/2026-04-08-tts-ux-and-fan-mission.md`
- TTS 구현 계획: `docs/superpowers/plans/2026-04-09-tts-playback.md`
- TTS 문구 목록: `docs/tts-phrase-list.txt`
- R2 CDN: `tts.tigerroom.app/ko/{pack}/{audio_id}.mp3`
- mp3 원본: `/Users/dakhome/Develop/work-flutter/tts_mp3/`
- mp3 노멀라이즈: `/Users/dakhome/Develop/work-flutter/tts_mp3_up/`
- Firebase RC: `banner_delay_days=0`, `tts_rewarded_bonus=2`, `daily_tts_limit=5`
- 릴리즈 노트: `docs/release-notes-v1.1.2.txt`
