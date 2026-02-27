# CLAUDE.md — Fangeul Flutter Project

> 마스터 지시서. 모든 코드 작성 시 이 문서의 원칙을 따른다.

## 프로젝트 개요

**Fangeul** — 글로벌 K-pop 팬을 위한 한국어 유틸리티 Android 앱.

핵심 기능: 한글 키패드, 영↔한 키보드 위치 변환, 한글→로마자 발음 변환, K-pop 팬 문구 라이브러리(다국어+TTS), 플로팅 버블 오버레이.

## 아키텍처: Clean Architecture (3-Layer)

```
lib/
├── core/                    # 순수 비즈니스 로직 (외부 의존성 없음)
│   ├── engines/             # 한글, 키보드, 로마자 엔진 (순수 Dart)
│   ├── entities/            # 도메인 모델 (immutable, freezed)
│   ├── usecases/            # 비즈니스 유스케이스
│   └── repositories/        # Repository 인터페이스 (abstract class)
│
├── data/                    # 데이터 레이어 (외부 의존성 구현)
│   ├── repositories/        # Repository 구현체
│   ├── datasources/         # 로컬 JSON, SharedPreferences
│   └── models/              # 데이터 모델 (JSON 직렬화)
│
├── presentation/            # UI 레이어
│   ├── screens/             # 화면 단위 위젯
│   ├── widgets/             # 재사용 가능한 위젯
│   ├── providers/           # Riverpod Provider 정의
│   └── theme/               # 테마, 색상, 타이포그래피
│
├── services/                # 플랫폼 서비스 (TTS, 클립보드 등)
├── platform/                # 네이티브 통신 (Platform Channel)
└── app.dart                 # MaterialApp, 라우팅, 프로바이더 스코프
```

### 핵심 규칙

1. **의존성 방향은 안쪽으로만.** `core/`는 `data/`, `presentation/`을 절대 import하지 않는다.
2. **모든 Repository는 인터페이스를 core/에, 구현체를 data/에 둔다.**
3. **UI 위젯은 직접 데이터소스에 접근하지 않는다.** Provider → UseCase → Repository 경로.
4. **레이어 간 데이터 전달은 Entity(core)를 사용한다.**

## 상태관리: Riverpod + freezed

- `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`
- `freezed` + `freezed_annotation` (immutable state)
- State는 항상 freezed sealed class: `initial / loading / success / error`
- `ref.watch` → `build()`에서만, `ref.read` → 이벤트 핸들러에서만
- 화면당 하나의 주요 Notifier. UI는 순수 위젯.

## 데이터 관리

- **문구 데이터:** `assets/phrases/*.json` → 스키마는 `docs/fangeul-product-spec.md` 섹션 6.3
- **TTS 오디오:** `assets/audio/*.mp3` (기본 번들) + Cloudflare R2 다운로드 캐싱
- **로컬 저장소:** `shared_preferences`만 사용. SQLite/Hive 금지 (MVP).
- **재생:** `just_audio`

## 작업 흐름 (Phase 순서)

반드시 순서대로. 각 Phase 완료 후 다음 진행.

```
Phase 1: 프로젝트 셋업 — 패키지, 디렉토리, Android 설정, 빌드 확인
Phase 2: Core 엔진 — hangul_engine + keyboard_converter + romanizer (TDD)
Phase 3: 데이터 레이어 — Entity/Model(freezed), JSON 문구, Repository
Phase 4: UI 화면 — 테마, 네비게이션, 변환기, 키패드, 문구 라이브러리
Phase 5: 플로팅 버블 — Kotlin 네이티브 서비스 + Platform Channel
Phase 6: 수익화 — AdMob + Pro 구독
Phase 7: 마무리 — 아이콘, 스플래시, 릴리즈 빌드
```

## 참조 문서

| 문서 | 내용 |
|------|------|
| `docs/fangeul-product-spec.md` | 전체 기획서, 매핑 테이블(부록 B), 발음 규칙(4.3), JSON 스키마(6.3) |
| `docs/engine-guide.md` | 엔진 구현 상세 가이드 (한글/키보드/로마자/버블) |
| `docs/plans/` | Phase별 구현 계획서 |
| `.claude/rules/00-project.md` | 절대 위반 금지 규칙 |
| `.claude/rules/01-code-conventions.md` | 코드 스타일, import 순서, Riverpod 패턴, 테스트 규칙 |
