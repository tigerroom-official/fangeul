# Fangeul — Session Handoff

BASE_COMMIT: 8ba8e22e4e8798544a1d4be9a8354b3deb216930
HANDOFF_COMMIT: c3f7167e2c035827195fdd5a92a74b358bffa862
BRANCH: main
DATE: 2026-02-28

---

## 작업 요약

Phase 4.5: Romanizer 낱자모 필터링 버그 수정 + 초기 기획 문서 3개 통합 정리. 커스텀 한글 키보드 통합 완료 (이전 세션). 179개 테스트 pass.

---

## 완료된 작업

- [x] Phase 1: 프로젝트 셋업 (`96e072a`)
- [x] Phase 2: Core 엔진 (`bfea2a5`~`7317083`)
- [x] Phase 3: 데이터 레이어 (`807bc3a`)
- [x] Phase 4: UI 레이어 (`6dab1ab`~`a03e6c9`)
- [x] Phase 4.5: 커스텀 한글 키보드 통합 (`5d510ed`~`9803dbd`)
  - [x] KeyboardNotifier CAPS 상태관리 TDD (`f337263`)
  - [x] KeyboardKey 위젯 — 이중 라벨 + 햅틱 (`bffacf5`)
  - [x] KoreanKeyboard QWERTY 두벌식 + DEL 가속삭제 (`47bf16f`)
  - [x] ConverterScreen 시스템 키보드 대체 (`f625616`)
  - [x] 위젯 테스트 3개 (`a2cd958`)
  - [x] 데드코드 제거 + DEL 타이머 누수 수정 (`10478db`, `9803dbd`)
- [x] Romanizer 낱자모 필터링 — ㅎㅎㅎ/ㅣㅣㅣ 스킵 (`ba08997`)
- [x] 초기 기획 문서 3개 통합 정리 (`c3f7167`)
  - engine-guide.md, fangeul-product-spec.md, fangeul-engagement-system.md → 삭제
  - 법적/IP, 보안 규칙 → `.claude/rules/00-project.md` 승격
  - HMAC/seed 패턴 → `.claude/rules/01-code-conventions.md` 추가
  - 미구현 스펙 통합 → `docs/fangeul-future-reference.md` 생성

---

## 진행 중인 작업

없음. 모든 작업 커밋 완료.

---

## 핵심 교훈

- ★ Romanizer: 호환 자모(U+3131~U+3163)는 `_LiteralToken`으로 통과됨 → `_isJamo()` 체크 필요
- ★ 초기 기획 문서가 패널 토론/코드와 충돌하면 즉시 정리 — 새 세션 혼란 방지
- ★ 문서 삭제 시 활성 참조(CLAUDE.md, HANDOFF.md) 먼저 업데이트, plan docs는 스냅샷이므로 유지
- ★ 보안 규칙: flutter_secure_storage + HMAC은 rules에, 상세 위협 모델은 참조 문서에 분리

---

## 다음 단계

### P0: 플로팅 버블 수익화 전략 패널 토론
- 플로팅 버블 유료화 모델 검증: 저가 구독 vs 보상형 광고 시간제 해금
- 배너 광고 대안으로서의 실현 가능성
- 토론 후 결정사항을 `.claude/rules/` 및 `fangeul-future-reference.md`에 반영

### P1: Phase 5 — 플로팅 버블 구현
- 스펙: `docs/fangeul-future-reference.md` §1.1
- Kotlin FloatingBubbleService + Platform Channel
- SYSTEM_ALERT_WINDOW 권한 플로우

### P2: Phase 6 — 수익화
- AdMob 통합 (배너 + 보상형)
- 버블 해금 모델 구현 (P0 토론 결과에 따라)
- Pro 구독 (Google Play Billing)

### P3: 누락 기능 (Phase 4 리뷰)
- Quick access chips, AnimatedList 트랜지션
- 번역 언어 선택, 잠긴 팩 표시
- 변환기 공유 버튼, 라이선스 페이지

---

## 커밋 히스토리 (이번 세션)

```
c3f7167 docs: 초기 기획 문서 3개 통합 정리 — fangeul-future-reference.md
ba08997 fix: Romanizer 낱자모(ㅎ,ㅣ,ㅏ) 필터링 — 완성 음절만 로마자 변환
9803dbd fix: DEL 타이머 누수 방지 + 커서 위치 끝 고정
10478db refactor: KeyboardKey 데드코드 제거 — LayoutBuilder/widthMultiplier 삭제
a2cd958 test: KoreanKeyboard 위젯 테스트 — 키 탭/백스페이스/스페이스
f625616 feat: 커스텀 한글 키보드 통합 — 시스템 키보드 대체
2955433 fix: KeyboardKey 이름 충돌 해소 — Flutter services.dart hide
47bf16f feat: KoreanKeyboard 위젯 — QWERTY 두벌식 + DEL 가속삭제
bffacf5 feat: KeyboardKey 위젯 — 이중 라벨 키 + 햅틱 피드백
f337263 feat: KeyboardNotifier — CAPS 원샷/잠금 상태관리 (TDD)
5d510ed refactor: assembleJamos 공개 — 커스텀 키보드 자모 조합용
734f158 docs: 변환기 커스텀 키보드 구현 계획서
ae3abdf docs: 변환기 커스텀 한글 키보드 설계서
67467a6 chore: session handoff - Phase 4 UI 완료
```

---

## 수정한 파일 (이번 세션, 주요)

```
 .claude/rules/00-project.md           | 22 +-   (법적/IP, 보안, 광고 규칙 추가)
 .claude/rules/01-code-conventions.md  | 21 +    (HMAC/seed 패턴 추가)
 CLAUDE.md                             |  5 +-   (참조 문서 업데이트)
 docs/HANDOFF.md                       |  5 +-   (참조 업데이트)
 docs/fangeul-future-reference.md      | 343 +   (신규 — 통합 참조 문서)
 docs/engine-guide.md                  | 109 -   (삭제)
 docs/fangeul-engagement-system.md     | 577 -   (삭제)
 docs/fangeul-product-spec.md          | 712 -   (삭제)
 lib/core/engines/romanizer.dart       | 14 +-   (낱자모 필터링 추가)
 test/core/engines/romanizer_test.dart | 30 +    (7개 테스트 추가)
 lib/presentation/widgets/*.dart       | 다수     (커스텀 키보드 위젯)
 lib/presentation/providers/*.dart     | +keyboard_providers (키보드 상태관리)
```

---

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| 낱자모 필터링: Option A (자모 스킵) | 사용자 승인. Option B(전체 숨김)보다 자연스러운 UX |
| 문서 통합: 3개 → 1개 + rules 승격 | 패널 토론/코드와 충돌하는 내용 제거, 새 세션 혼란 방지 |
| 법적/IP 규칙 → rules 승격 | 가사/초상권/팬덤명 위반은 DMCA 리스크 → 하드 가드레일 |
| shared_preferences 범위 명확화 | 앱 설정만 SP, 게임/보상 상태는 flutter_secure_storage+HMAC |
| 플로팅 버블 스펙 최우선 보존 | Phase 5 유일한 구현 스펙, 핵심 엣지 기능 |

---

## 참고 컨텍스트

| 문서 | 경로 |
|------|------|
| 통합 참조 문서 (버블 §1.1) | `docs/fangeul-future-reference.md` |
| 비주얼 정체성 토론 | `docs/discussions/2026-02-27-visual-identity.md` |
| MVP 엣지 전략 토론 | `docs/discussions/2026-02-27-fangeul-edge-strategy.md` |
| Phase 4 설계/구현 | `docs/plans/2026-02-27-phase4-*.md` |
| 키보드 설계/구현 | `docs/plans/2026-02-28-converter-custom-keyboard-*.md` |

---

## 테스트 현황

| 영역 | 테스트 수 | 상태 |
|------|-----------|------|
| core/engines | 106 (hangul 17 + tables 6 + keyboard 34 + romanizer 49) | pass |
| core/entities | 14 | pass |
| core/usecases | 14 | pass |
| data/repositories | 12 | pass |
| presentation/providers | 19 (converter 7 + theme 5 + keyboard 7) | pass |
| presentation/widgets | 4 (keyboard 4) | pass |
| **총계** | **179** | **all pass** |

---

## 세션 히스토리

| 세션 | 날짜 | 주요 작업 |
|------|------|----------|
| S1 | 2026-02-27 | Phase 1~3 구현, 패널 토론 2건 |
| S2 | 2026-02-27 | Phase 4 UI 전체, 코드 리뷰 |
| S3 | 2026-02-28 | 커스텀 키보드, Romanizer 버그 수정, 문서 정리 |
