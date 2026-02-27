# Fangeul — Hard Rules (위반 금지)

> 절대 위반하면 안 되는 가드레일. 코드 스타일/패턴은 `01-code-conventions.md` 참조.

## 절대 금지 (DO NOT)
- `setState()` 사용 금지 → Riverpod Provider만
- `print()` 금지 → `debugPrint()` 사용
- 상대경로 import 금지 → `package:fangeul/` 사용
- barrel export (index.dart) 금지
- `core/`에서 Flutter/외부 패키지 import 금지
- 비즈니스 로직을 위젯 안에 넣지 않음
- 하드코딩 문자열 금지 → JSON 또는 상수 파일
- 테스트 없이 `core/engines/` 코드 수정 금지
- `any`, `dynamic` 타입 최소화
- MVP에서 SQLite/Hive 사용 금지 → shared_preferences만

## 의존성 방향
```
presentation/ → core/  ✅
data/         → core/  ✅
core/         → data/  ❌
core/         → presentation/ ❌
```

## Riverpod 규칙
- `ref.watch` → `build()` 메서드에서만
- `ref.read` → 이벤트 핸들러에서만
- State는 freezed sealed class (initial/loading/success/error)

## 읽지 않는 디렉토리
- `docs/raw-transcripts/` — 대화 원본 아카이브. 참조하지 않음. 정리본은 `docs/discussions/`.

## 플랫폼
- Android only (minSdk 26, targetSdk 34)
- 패키지명: `com.tigerroom.fangeul`
- 플로팅 버블: Kotlin 직접 구현, 외부 패키지 금지
- Platform Channel: `com.tigerroom.fangeul/floating_bubble`
