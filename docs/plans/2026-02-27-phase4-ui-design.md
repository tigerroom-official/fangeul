# Phase 4: UI 레이어 설계서

> 2026-02-27 | Approach A: 토큰화 디자인 시스템 + 탭 네비게이션

## 배경

Phase 1(셋업) + Phase 2(Core 엔진, 99개 테스트) + Phase 3(데이터 레이어, 139개 테스트) 완료.
비주얼 정체성 패널 토론 + Codex 독립 리뷰 결과를 반영한 UI 설계.

### 핵심 결정사항 (패널 + Codex)

- 다크 모드 기본값, 설정에서 라이트/시스템 전환
- 순수 블랙 금지 → 딥 네이비 계열
- 팬덤 독립 컬러 (보라색 seedColor 폐기)
- "문화적 프리미엄" 톤 — 절제된 일상, 폭발하는 모먼트
- 폰트 전부 번들 (오프라인 우선)
- M3 명시적 surface role 오버라이드
- Lottie → 보상/축하 화면에만 한정

---

## 1. 디자인 시스템

### 1.1 컬러 토큰

```
다크 모드 (기본):
  background:          #0F0F1A    가장 깊은 배경
  surface:             #1E1E2E    딥 네이비 (카드, 시트)
  surfaceContainer:    #282840    컨테이너
  surfaceContainerHigh:#323250    높은 엘리베이션 컨테이너
  onSurface:           #E8E8F0    주 텍스트
  onSurfaceVariant:    #A0A0B8    보조 텍스트
  outline:             #4A4A60    경계선
  outlineVariant:      #353550    약한 경계선

라이트 모드:
  background:          #FAFAFE
  surface:             #FFFFFF
  surfaceContainer:    #F0F0F8
  onSurface:           #1E1E2E
  onSurfaceVariant:    #5A5A70

액센트 (Fangeul 고유):
  primary:             #4ECDC4    틸 — 팬덤 독립, 한국 전통 비색 유사
  primaryContainer:    #1A3A38    틸 다크 (다크모드), #D4F5F2 (라이트모드)
  secondary:           #FFE66D    웜 옐로 (CTA, 강조)
  tertiary:            #FF6B6B    코랄 (경고, 하트)

팬덤 컬러 (공유 카드 테마 전용, v1.0에서는 미사용):
  purple: #A855F7, pink: #EC4899, green: #22C55E
  blue: #3B82F6, orange: #F97316, silver: #94A3B8
```

### 1.2 타이포그래피

```
Pretendard Subset (~2.5MB):
  → 한글 2,350자 + 라틴 + 숫자
  → 키패드, 자모, 데일리 카드, 공유 카드
  → Regular(400), SemiBold(600), Bold(700)

Noto Sans KR Subset (~2MB):
  → 일반 UI 텍스트, 문구 본문
  → Regular(400), Medium(500)

총 APK 증가: ~4.5MB
GoogleFonts 패키지 사용 안 함 (전부 번들)
```

### 1.3 성능/접근성 기준

| 항목 | 기준 |
|------|------|
| 렌더링 | 60fps |
| 앱 시작 | < 2초 cold start |
| 메모리 | < 150MB |
| Lottie 파일 | 각 < 100KB |
| 터치 타겟 | 최소 48x48dp |
| 대비율 | WCAG AA (4.5:1 텍스트, 3:1 아이콘) |
| 축소 모션 | disableAnimations 시 Lottie 비활성 |

---

## 2. 네비게이션

3탭 BottomNavigationBar + go_router StatefulShellRoute.

```
[홈]       → /home        데일리 카드 + 스트릭
[변환기]   → /converter   영↔한 변환 + 로마자 발음
[문구]     → /phrases     문구 라이브러리
```

설정: 홈 AppBar 기어 아이콘 → /settings (push).

---

## 3. 화면 설계

### 3.1 홈 화면

- 스트릭 배너: 현재 연속일수 표시, 완료 시 Lottie confetti
- 데일리 카드: 큰 한글 중앙, roman, 번역, [완료]/[공유] 버튼
- 퀵 액세스: 변환기/문구 바로가기 칩

### 3.2 변환기 화면

- 3모드 탭: 영→한, 한→영, 발음(로마자)
- TextField 입력 → debounce 300ms → 결과 표시
- [복사]/[공유] 버튼
- "차분한 도구" — 미니멀, 인지 부하 최소

### 3.3 문구 화면

- 태그 필터 칩 (전체, 사랑, 응원, 일상...)
- 문구 카드 리스트: ko, roman, 번역, TTS/복사/공유
- 잠긴 팩 표시 (v1.0: 보상형 광고 해금 UI 미구현, 표시만)

### 3.4 설정 화면

- 테마 모드: 다크/라이트/시스템 SegmentedButton
- 번역 언어 선택
- 앱 정보, 라이선스

---

## 4. 애니메이션

| 위치 | 유형 | 구현 |
|------|------|------|
| 스트릭 완료 | Lottie confetti | 1-2초 |
| 데일리 카드 완료 | Lottie star burst | 1-2초 |
| 탭 전환 | M3 기본 | 커스텀 없음 |
| 카드 리스트 | staggered fade-in | AnimatedList |
| 변환 결과 | cross-fade | AnimatedSwitcher |

Lottie 파일 2개만 (LottieFiles.com 무료), 각 <100KB.

---

## 5. 공유 카드

- CustomPainter + PictureRecorder → 1080x1920 PNG
- path_provider 캐시 디렉토리 저장 → share_plus 시스템 공유
- v1.0: 다크/라이트 2종만
- v1.1: 팬덤 컬러 액센트 6개 추가

---

## 6. 신규 의존성

```yaml
go_router: ^14.0.0       # 선언적 라우팅
lottie: ^3.0.0            # Lottie 애니메이션
share_plus: ^10.0.0       # 시스템 공유
```

폰트 파일: `assets/fonts/` (Pretendard, Noto Sans KR)

---

## 7. 파일 구조

```
lib/presentation/
├── theme/
│   ├── fangeul_theme.dart         # ThemeData 생성 (다크/라이트)
│   ├── fangeul_colors.dart        # 색상 토큰 상수
│   └── fangeul_text_styles.dart   # 텍스트 스타일 상수
├── router/
│   └── app_router.dart            # go_router 설정
├── screens/
│   ├── home_screen.dart
│   ├── converter_screen.dart
│   ├── phrases_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── daily_card_widget.dart
│   ├── streak_banner.dart
│   ├── phrase_card.dart
│   ├── converter_input.dart
│   ├── tag_filter_chips.dart
│   └── share_card_painter.dart
└── providers/
    ├── phrase_providers.dart       # (기존)
    ├── progress_providers.dart     # (기존)
    ├── converter_providers.dart    # (신규)
    ├── theme_providers.dart        # (신규)
    └── settings_providers.dart     # (신규)
```

---

## 8. 구현 순서

```
Step 1: 의존성 + 폰트 + 테마 시스템
Step 2: 네비게이션 (go_router + 빈 화면 4개)
Step 3: 홈 화면 (데일리 카드 + 스트릭)
Step 4: 변환기 화면 (provider + UI)
Step 5: 문구 화면 (리스트 + 태그 필터)
Step 6: 설정 화면 (테마 토글)
Step 7: 공유 카드 (CustomPainter)
Step 8: Lottie 통합
Step 9: 검증
```
