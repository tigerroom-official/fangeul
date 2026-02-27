# Fangeul — Session Handoff

BASE_COMMIT: c3f7167e2c035827195fdd5a92a74b358bffa862
HANDOFF_COMMIT: 68b6d796448c87fa042d891cab9273806a876b0d
BRANCH: main
DATE: 2026-02-28

---

## 작업 요약

S4: 플로팅 버블 수익화 전략 패널 토론 (5명 전문가, 5개 토픽 + 심화 3개 쟁점). 감성 컬러 팩 IAP 모델 확정. 수익화 결정사항을 rules + future-reference에 반영. 179개 테스트 pass (코드 변경 없음, 문서 전용 세션).

---

## 완료된 작업

- [x] Phase 1: 프로젝트 셋업 (`96e072a`)
- [x] Phase 2: Core 엔진 (`bfea2a5`~`7317083`)
- [x] Phase 3: 데이터 레이어 (`807bc3a`)
- [x] Phase 4: UI 레이어 (`6dab1ab`~`a03e6c9`)
- [x] Phase 4.5: 커스텀 한글 키보드 + Romanizer 수정 + 문서 정리 (`5d510ed`~`c3f7167`)
- [x] 플로팅 버블 수익화 패널 토론 (`68b6d79`)
  - [x] 5명 전문가 × 5개 토픽 토론 (버블 게이팅, 보상형 광고, 구독/가격, 배너, 전환 퍼널)
  - [x] 심화 토론 3개 쟁점 (MVP=IAP, 해금시간=4h, 감성 컬러 팩 IP 안전 구조)
  - [x] 토론 기록 저장 `docs/discussions/2026-02-28-bubble-monetization.md`
  - [x] 수익화 규칙 `.claude/rules/00-project.md` 반영
  - [x] `docs/fangeul-future-reference.md` §3.1 수익 구조 업데이트

---

## 진행 중인 작업

없음. 모든 작업 커밋 완료.

---

## 핵심 교훈

- ★ 버블 기본 기능(변환, 키보드, 띄우기)은 전면 무료 — 핵심 엣지를 페이월 뒤에 두면 입소문/성장 차단
- ★ MVP 수익화 = IAP 단일 (구독은 Phase 7+) — 동남아 신용카드 6~7%, 구독 피로, K-pop 시즌 소비 패턴
- ★ "감성 컬러 팩" IP 안전 구조: 색상+감성 이름(퍼플 드림, 골든 아워), 아이돌/팬덤명 절대 금지
- ★ 보상형 광고 "팬 패스": 4시간 해금("4h or 자정 중 빠른 것"), 하루 3회, 보상 프레이밍
- ★ 전환 퍼널: 7일 무료 → Day 4~ 보상형 → Day 7+ 광고 3회 소진 시 단일 IAP 트리거

---

## 다음 단계

### P0: Phase 5 — 플로팅 버블 구현
- 스펙: `docs/fangeul-future-reference.md` §1.1
- Kotlin FloatingBubbleService + Platform Channel
- SYSTEM_ALERT_WINDOW 권한 플로우

### P1: Phase 6 — 수익화 구현
- AdMob 통합 (배너 조건부 + 보상형 "팬 패스")
- 감성 컬러 팩 IAP (Google Play Billing, 일회성)
- 보상형 광고 시간제 해금 로직 (4h / 자정 만료)
- 전환 퍼널 UX 플로우

### P2: 누락 기능 (Phase 4 리뷰)
- Quick access chips, AnimatedList 트랜지션
- 번역 언어 선택, 잠긴 팩 표시
- 변환기 공유 버튼, 라이선스 페이지

---

## 커밋 히스토리 (이번 세션)

```
68b6d79 docs: 플로팅 버블 수익화 패널 토론 — 감성 컬러 팩 IAP 모델 확정
faee240 chore: session handoff - 커스텀 키보드 + Romanizer 수정 + 문서 정리
```

---

## 수정한 파일 (이번 세션)

```
 .claude/rules/00-project.md                        |  12 +-   (수익화 규칙 추가)
 CLAUDE.md                                          |   4 +-   (포인터 갱신)
 docs/HANDOFF.md                                    | 173 +-   (S3 핸드오프)
 docs/discussions/2026-02-28-bubble-monetization.md  | 142 +    (신규 — 수익화 패널 토론 기록)
 docs/fangeul-future-reference.md                   |  38 +-   (§3.1 수익 구조 패널 결과 반영)
```

---

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| 버블 기본 기능 = 전면 무료 | A조(게이팅 지지) → B조 반론(Weverse 실시간 마찰, 인니 결제 인프라)에 동의 |
| MVP = IAP 단일 (구독 X) | 동남아 신용카드 6~7%, 구독 피로, K-pop 시즌별 소비 패턴에 IAP 적합 |
| 감성 컬러 팩 (IP 안전) | 색상+감성 이름으로 팬 자발적 연상 유도, 아이돌/팬덤명 DMCA 리스크 회피 |
| 보상형 4시간 해금 | 윤넛지 제안. 2시간(잭그로)은 '빌려 쓰는 느낌' 강함. 4/5 동의 |
| "4h or 자정" 만료 규칙 | 다음 날 첫 광고 시청 유도 → DAU 유지 + 보상형 습관 형성 |
| 배너 조건부 유지 | 보상형 1회 시청 시 세션 배너 제거 → DAU 15% 전환 시 전면 종료 |

---

## 참고 컨텍스트

| 문서 | 경로 |
|------|------|
| 수익화 패널 토론 기록 | `docs/discussions/2026-02-28-bubble-monetization.md` |
| 수익화 패널 원본 대화 | `docs/raw-transcripts/2026-02-28-monetization-panel-raw.md` |
| 통합 참조 문서 (버블 §1.1, 수익 §3.1) | `docs/fangeul-future-reference.md` |
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
| S4 | 2026-02-28 | 수익화 패널 토론, 감성 컬러 팩 IAP 모델 확정 |
