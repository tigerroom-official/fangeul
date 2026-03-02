# CLAUDE.md — Fangeul Flutter Project

**Fangeul** — 글로벌 K-pop 팬을 위한 한국어 유틸리티 Android 앱.
핵심 기능: 한글 키패드, 영↔한 변환, 로마자 발음, 팬 문구(다국어+TTS), 플로팅 버블.

## 아키텍처: Clean Architecture (3-Layer)

```
lib/
├── core/           # 순수 Dart — engines, entities, usecases, repositories(interface)
├── data/           # 외부 의존성 — repositories(impl), datasources, models
├── presentation/   # UI — screens, widgets, providers, theme
├── services/       # 플랫폼 서비스 (TTS, 클립보드)
├── platform/       # 네이티브 통신 (Platform Channel)
└── app.dart
```

**의존성:** `core/` → 외부 import 금지. `presentation/` → `core/` OK. `data/` → `core/` OK.
**상태관리:** Riverpod + freezed sealed class (`initial/loading/success/error`)

## 데이터 관리

- 문구: `assets/phrases/*.json` (스키마 → `docs/fangeul-future-reference.md` §1.4)
- TTS: `assets/audio/*.mp3` + Cloudflare R2 캐싱, `just_audio` 재생
- 로컬 저장소: `shared_preferences`만 (SQLite/Hive 금지)

## 작업 Phase (순서대로)

```
Phase 1: 셋업 ✅ | Phase 2: Core 엔진 ✅ | Phase 3: 데이터 레이어 ✅
Phase 4: UI ✅   | Phase 5: 버블 ✅    | Phase 6: 수익화 | Phase 7: 릴리즈
```

## 검증 명령어

```bash
flutter test test/core/engines/     # 엔진 유닛 테스트 (99개)
flutter test test/core/entities/    # Entity 테스트
flutter test test/core/usecases/    # UseCase 테스트
flutter test test/data/             # Repository/DataSource 테스트
flutter test                        # 전체 테스트
flutter analyze                     # 정적 분석
flutter test --coverage             # 커버리지 (core/engines 90%+)
dart format --set-exit-if-changed .  # 포맷 검증
```

## 참조 문서

| 문서 | 내용 |
|------|------|
| `docs/fangeul-future-reference.md` | 미구현 스펙(버블, TTS), 보안, 수익화, KPI, 로드맵 |
| `docs/plans/` | Phase별 구현 계획서 |
| `docs/HANDOFF.md` | 세션 핸드오프 (최신 작업 상태) |

## 현재 작업 상태
> 마지막 핸드오프: 2026-03-03
> 상세: `docs/HANDOFF.md` 참조
> 요약: MVP 통합 완료 — 마이아이돌(5그룹) + 템플릿 문구 + 온보딩 + 교차리뷰 3라운드. 314 tests pass. 다음: Phase 6 수익화.
