# Fangeul — Session Handoff

BASE_COMMIT: b421e53 (이전 핸드오프)
HANDOFF_COMMIT: 1f711e8
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
- 보상형 광고 피벗 (2026-03-09): TTS/즐겨찾기 시간제 해금 폐지 → 프리미엄 테마 24h 체험 전용
- IAP UI 마무리 (2026-03-09): subtitle 설명 추가, 번들 "추천" 뱃지, Codex 리뷰 수정
- 즐겨찾기 제한 UX 개선 (2026-03-09): 다이얼로그 직접적 메시지, SnackBar CTA 개선, 버블 해결 경로 추가
- 릴리즈 준비 (2026-03-11): AdMob 프로덕션 ID + T-rating + targetSdk 35 + ProGuard + privacy/terms + 서명 설정
- 변환기 UX 개선 (2026-03-11): autofocus + paste + 중앙 space bar + empty state 예시 + "Key Swap" 영문 리네이밍
- 릴리즈 버그 수정 (2026-03-11): Done 버튼 silent failure (FlutterSecureStorage try-catch) + debug progress panel
- v1.0.0+4 AAB 빌드 완료 (2026-03-11)
- **FlutterSecureStorage BadPaddingException 크래시 수정** (2026-03-12): UserProgress + Monetization 양쪽 방어 + 8 테스트
- **전문가 패널 토론** (2026-03-12): 일일카드 TTS + 스트릭 BM + 카드 컬렉션 설계 합의
- **v1.0.0+5 내부 테스트 빌드** (2026-03-12): AAB 빌드 + Play Console 업로드
- **Play Store 에셋** (2026-03-12): 아이콘 512x512 + 그래픽 이미지 1024x500 제작
- **app-ads.txt 배포** (2026-03-12): `tigerroom-official.github.io` 별도 레포 생성 + GitHub Pages 활성화

### 활성 작업
- Play Console 스토어 등록정보 완성 (아이콘/그래픽 업로드됨, 스크린샷 미등록)
- 다국어 스토어 등록 (ja/zh/id/th/vi) — 다음 세션 즉시 작업

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
- 일일카드 TTS 번들 통합 ₩1,900 (전문가 패널 합의, v1.1)
- 스트릭 "축하" 감성 보상 + 마일스톤 시스템 (v1.1)

---

## 작업 요약

Crashlytics 크래시(FlutterSecureStorage BadPaddingException) 양쪽 DataSource 수정 + 전문가 패널 토론(TTS/스트릭 BM) + v1.0.0+5 AAB 빌드 + Play Store 에셋 제작 + app-ads.txt 배포. 812 tests pass.

## 완료된 작업

- [x] FlutterSecureStorage BadPaddingException crash recovery — UserProgress + Monetization 양쪽 `PlatformException` 방어 + `_deleteCorruptedKeys()` + save 재시도 + 8 테스트 (b297225)
- [x] 전문가 패널 토론 기록 — 일일카드 TTS + 스트릭 BM + 카드 컬렉션 (b874957)
- [x] IAP 테스트 가이드 + Firebase Analytics 가이드 작성 (b874957)
- [x] v1.0.0+5 AAB 빌드 — 내부 테스트용 (d46f235)
- [x] app-ads.txt 배포 — `tigerroom-official.github.io` 별도 레포 + GitHub Pages
- [x] Play Store 에셋 제작 — 아이콘 512x512 + 그래픽 이미지 1024x500 (b0ee999)
- [x] 812 tests pass + flutter analyze clean

## 진행 중인 작업
없음. 다음 세션에서 스토어 등록 계속.

## 핵심 교훈

- ★ `MonetizationLocalDataSource.load()`는 원래 `_storage.read()` 호출에 try-catch 없었음 → PlatformException이 직접 전파되어 크래시
- ★ BadPaddingException 수정: catch만으론 부족 → `_deleteCorruptedKeys()` + 재시도까지 해야 반복 크래시 방지
- ★ app-ads.txt는 도메인 루트 필수 — `domain.github.io/app-ads.txt` (하위 경로 불가)
- ★ Play Console IAP 메뉴: 스토어 등록정보 완성 + 내부 테스트 배포 후 노출
- ★ 앱 아이콘: 단순한 디자인이 48px 작은 사이즈에서 가독성 좋음 — 장식(반짝이 등) 지양
- 스크린샷 IP 주의: 특정 그룹/팬덤명 노출 금지 → "Fangeul"을 기타 설정으로 사용

## 다음 단계

### 1순위: Play Console 다국어 스토어 등록
1. **번역 관리** — ko/en 외 5개 언어(ja, zh, id, th, vi) 스토어 소개 등록
2. **스크린샷 촬영** — 영어 시스템 언어 + 기본 테마 + "Fangeul" 그룹명 + device frame, 최소 4장 (홈/Key Swap/문구/테마)
3. **스토어 등록정보 완성** — 아이콘+그래픽 업로드 + 스크린샷 + 설명 → 임시저장 해제

### 2순위: IAP + QA + 출시
4. **IAP 상품 등록** — 3 SKU (₩990/₩990/₩1,500) + 동남아 현지가
5. **내부 테스트 QA** — 전체 기능 + IAP 플로우 검증
6. **프로덕션 출시**

### 3순위: 출시 후 빠른 개선
- P1: 버블 딥링크 — openMainApp → ThemePickerSheet 자동 오픈
- P1: 핸들 좌측 멤버 이름 노출
- PaletteRegistry 20-25개 확장
- Firebase Analytics 대시보드 구성

### 4순위: v1.1 로드맵
- 일일카드 TTS 번들 ₩1,900 (패널 합의)
- 스트릭 "축하" 감성 보상 + 마일스톤 시스템
- 한글 카드 컬렉션 (가챠) — Phase 2로 연기 (패널 합의)
- 한글 퍼즐 (Wordle 스타일)
- 구독 모델

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| BadPaddingException 양쪽 DataSource 방어 | Crashlytics에서 실제 크래시 발생 — Monetization은 catch 자체가 없었음 |
| app-ads.txt 별도 레포 | GitHub Pages는 루트 도메인 레포에서만 루트 경로 제공 |
| 아이콘 hu.png 선택 (반짝이 없는 심플 버전) | 48px 앱 서랍에서 가독성 우선 |
| TTS 번들 ₩1,900 (패널 합의) | TTS 단독 SKU는 가치 불명확 → 기존 IAP에 통합이 전환율 유리 |
| 카드 컬렉션 v1.1 연기 | IP 제약 하 차별화 어려움 + 개발 비용 큼 → v1.0 출시 우선 |

## 참고 컨텍스트

- 크래시 원본: `~/Develop/com_tigerroom_fangeul_issue_46b28dba04ac686b4183b6e3fded0c69_crash.txt`
- 전문가 패널 토론: `docs/discussions/2026-03-12-daily-tts-streak-bm.md`
- IAP 테스트 가이드: `docs/guides/iap-testing-guide.md`
- Firebase Analytics 가이드: `docs/guides/firebase-analytics-guide.md`
- 스토어 에셋: `docs/assets/store/` (app-icon-512.png, feature-graphic.png)
- app-ads.txt: `tigerroom-official.github.io` 레포

## 커밋 히스토리 (이번 세션)

```
b0ee999 chore: add Play Store assets (icon 512x512 + feature graphic 1024x500)
d46f235 chore: bump version to 1.0.0+5 for internal test
b874957 docs: 일일카드 TTS+스트릭 토론 기록, IAP/Analytics 가이드 추가
b297225 fix: FlutterSecureStorage BadPaddingException crash recovery
```

## 수정한 파일

```
11 files changed, 2081 insertions(+), 23 deletions(-)

주요 수정:
 lib/data/datasources/monetization_local_datasource.dart (PlatformException 방어 + deleteCorruptedKeys)
 lib/data/datasources/user_progress_local_datasource.dart (PlatformException 방어 + deleteCorruptedKeys + save 재시도)
 test/data/datasources/monetization_local_datasource_test.dart (+69 lines 테스트)
 test/data/datasources/user_progress_local_datasource_test.dart (NEW, 151 lines)
 docs/discussions/2026-03-12-daily-tts-streak-bm.md (NEW, 패널 토론 기록)
 docs/guides/iap-testing-guide.md (NEW, 583 lines)
 docs/guides/firebase-analytics-guide.md (NEW, 937 lines)
 docs/assets/store/app-icon-512.png (NEW, 512x512)
 docs/assets/store/feature-graphic.png (NEW, 1024x500)
 pubspec.yaml (v1.0.0+5)
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
| 보상형피벗+즐겨찾기UX | 보상형→테마 체험 전용 + IAP subtitle/추천 + 즐겨찾기 UX 개선 + Codex 리뷰 → 812 tests |
| 릴리즈준비+UX수정 | AdMob prod + ProGuard + Key Swap + autofocus + Done 버튼 수정 + debug panel → 812 tests, v1.0.0+4 |
| **크래시수정+스토어** | BadPaddingException 방어 + 패널 토론 + v1.0.0+5 + Play Store 에셋 + app-ads.txt → 812 tests |
