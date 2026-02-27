# Fangeul — Session Handoff

BASE_COMMIT: 8ba8e22e4e8798544a1d4be9a8354b3deb216930
HANDOFF_COMMIT: a03e6c914161b9de38427b99653d6882fd280a1b
BRANCH: main
DATE: 2026-02-27

---

## 작업 요약

Phase 4 UI 레이어 전체 구현 완료. 디자인 시스템(컬러/텍스트/테마), 4개 화면(홈/변환기/문구/설정), 3탭 네비게이션, 공유 카드, Lottie 애니메이션까지 구축. Codex + Self Review 병렬 리뷰 후 12건 이슈 수정. 151개 테스트 pass.

---

## 완료된 작업

- [x] Phase 1: 프로젝트 셋업 (`96e072a`)
- [x] Phase 2: Core 엔진 — hangul_engine, keyboard_converter, romanizer (`bfea2a5`~`7317083`)
- [x] Phase 3: 데이터 레이어 — Entity, UseCase, DataSource, Repository, Provider (`807bc3a`)
- [x] Phase 4: UI 레이어 (`6dab1ab`~`a03e6c9`)
  - [x] 디자인 시스템: FangeulColors, FangeulTextStyles, FangeulTheme (`412db5a`~`e1e7bde`)
  - [x] 상태관리: ThemeModeNotifier(5 tests), ConverterNotifier(7 tests) (`e1e7bde`, `14455f7`)
  - [x] 네비게이션: go_router StatefulShellRoute 3탭 (`0ff625f`)
  - [x] 4개 화면: 홈/변환기/문구/설정 (`dd629f1`~`ce5dfbc`)
  - [x] 공유 카드: CustomPainter 1080x1920 + share_plus (`d0f3b75`)
  - [x] Lottie 축하 오버레이 + 접근성 (`f9a3794`)
  - [x] 코드 리뷰 12건 수정 (`62fd02c`)
  - [x] 오버스크롤 글로우 + Gradle 업그레이드 (`a03e6c9`)

---

## 진행 중인 작업

없음. Phase 4 완료. feature/phase4-ui 브랜치 → main에 fast-forward merge 완료, worktree 삭제됨.

---

## 핵심 교훈

- ★ ShareCardPainter에서 `ui.TextStyle`에 `fontFamily`를 명시하지 않으면 오프스크린 렌더링 시 시스템 기본 폰트(Roboto)로 렌더링되어 한글이 깨진다
- ★ Android 12+ stretch 오버스크롤은 카드/텍스트까지 늘어나므로, 유틸리티 앱에서는 `GlowingOverscrollIndicator`로 교체 필요
- ★ `ui.Picture`와 `ui.Image`는 네이티브 리소스 — 반드시 `dispose()` 호출, finally 블록에서
- ★ ConverterState 같은 동기 작업도 프로젝트 규칙상 `initial/loading/success/error` 4상태 패턴 준수
- ★ NotoSansKR 번들 시 Regular(400)/Medium(500)만 포함됨. w600/w700 사용하면 faux-bold 발생
- 변환기 화면에 300ms 디바운스 적용 (디자인 스펙 준수, 키입력마다 엔진 호출 방지)

---

## 다음 단계

### P0: 변환기 UX 개선 (Phase 4.5)
1. **영한 자판 매핑 힌트** — 변환기 화면에서 사용자가 어떤 영문 키가 어떤 한글인지 모르는 문제
   - 옵션 A: 키보드 위 한글 힌트 바
   - 옵션 B: 화면 하단 영한 매핑 표 토글
   - → 브레인스토밍 필요

### P1: Phase 5 — 플로팅 버블 + 한글 키패드
- Platform Channel (Kotlin): `com.tigerroom.fangeul/floating_bubble`
- 커스텀 한글 키패드 UI (버블 오버레이 위)
- 참조: `docs/fangeul-product-spec.md`

### P2: 누락 기능 (Phase 4 리뷰에서 발견)
- Quick access chips (홈 화면)
- AnimatedList/AnimatedSwitcher 트랜지션
- 번역 언어 선택 (설정)
- 잠긴 팩 표시 (문구)
- 변환기 공유 버튼
- 라이선스 페이지 (설정)
- 실제 Lottie 에셋 교체 (현재 빈 placeholder)

---

## 커밋 히스토리

```
a03e6c9 fix: stretch 오버스크롤 글로우로 교체 + AGP/Gradle 버전 업그레이드
62fd02c fix: Phase 4 UI 코드 리뷰 이슈 12건 수정
f9a3794 feat: Lottie 축하 오버레이 — 스트릭 완료 시 confetti
d0f3b75 feat: 공유 카드 — CustomPainter 1080x1920 PNG + share_plus
ce5dfbc feat: 설정 화면 — 다크/라이트/시스템 테마 토글
2d2c037 feat: 문구 화면 — 태그 필터 + 문구 카드 리스트
26aa59a feat: 변환기 화면 — 영↔한/로마자 3탭 변환
dd629f1 feat: 홈 화면 — 데일리 카드 + 스트릭 배너
0ff625f feat: 3탭 네비게이션 — go_router StatefulShellRoute + 테마 연동
14455f7 feat: ConverterNotifier — 영↔한/로마자 변환 상태관리 (TDD)
e1e7bde feat: 테마 시스템 — FangeulTheme + ThemeModeNotifier (TDD)
14c56ef feat: FangeulTextStyles 텍스트 스타일 토큰 — NotoSansKR 기반
412db5a feat: FangeulColors 컬러 토큰 정의 — 다크/라이트/액센트
6dab1ab chore: Phase 4 의존성 추가 — go_router, lottie, share_plus, NotoSansKR 폰트
564bc6f docs: Phase 4 UI 설계서 + 구현 계획서
71a7d1e docs: 비주얼 정체성 패널 토론 결과 기록
807bc3a feat: Phase 3 데이터 레이어 구현
7317083 refactor: HangulTables 공유 테이블 추출 + 중복 제거 + 버그 수정
dde3e26 feat: 로마자 발음 변환기 구현 (TDD)
487b99a feat: 키보드 위치 변환기 영↔한 양방향 구현 (TDD)
bfea2a5 feat: 한글 엔진 자모 분해/조합 구현 (TDD)
96e072a chore: Phase 1 프로젝트 셋업
9472427 chore: initial Fangeul Flutter project scaffold + docs
```

---

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| 다크 모드 기본 + 딥 네이비(#1E1E2E) | K-pop 팬덤 미학 일치, 순수 블랙 금지 (패널 합의) |
| 팬덤 독립 액센트 (#4ECDC4 teal) | BTS 보라, BLACKPINK 분홍 등 특정 그룹 연상 회피 |
| NotoSansKR Regular+Medium만 번들 | 앱 사이즈 절약 (~20MB), Pretendard subset은 릴리즈 시 도입 |
| ConverterState: initial/loading/success/error | 동기 엔진이지만 프로젝트 패턴 일관성 유지 |
| stretch → glow 오버스크롤 | Android 12+ stretch가 카드/글자를 늘여 유틸리티 앱에 부적합 |
| StateProvider로 UI 로컬 상태 관리 | 프로젝트 규칙 setState 금지 → autoDispose StateProvider 사용 |

---

## 참고 컨텍스트

| 문서 | 경로 |
|------|------|
| 전체 기획서 | `docs/fangeul-product-spec.md` |
| Phase 4 설계서 | `docs/plans/2026-02-27-phase4-ui-design.md` |
| Phase 4 구현 계획 | `docs/plans/2026-02-27-phase4-ui-implementation.md` |
| 비주얼 정체성 토론 | `docs/discussions/2026-02-27-visual-identity.md` |
| 엔진 가이드 | `docs/engine-guide.md` |

---

## 테스트 현황

| 영역 | 테스트 수 | 상태 |
|------|-----------|------|
| core/engines | 99 | pass |
| core/entities | 14 | pass |
| core/usecases | 14 | pass |
| data/repositories | 12 | pass |
| presentation/providers | 12 | pass |
| **총계** | **151** | **all pass** |

---

## 런타임 상태

- Android 에뮬레이터 (Pixel_8_API_33) 실행 중일 수 있음 — PID 확인 필요
- AGP 8.7.0 / Gradle 8.9 / Kotlin 1.9.24 로 업그레이드 완료
