# Fangeul — Hard Rules (위반 금지)

> CLAUDE.md가 마스터 문서. 이 파일은 절대 위반하면 안 되는 규칙만 모은 가드레일.

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

## Provider 규칙
- `ref.watch` → `build()` 메서드에서만
- `ref.read` → 이벤트 핸들러에서만
- State는 freezed sealed class (initial/loading/success/error)

## 파일 규칙
- 한 파일에 하나의 public 클래스
- 모든 public 클래스/메서드에 dartdoc (`///`) 필수
- import 순서: Dart SDK → Flutter SDK → 외부 패키지 → 프로젝트 내부

## 테스트
- `core/engines/` 유닛 테스트 100% 커버리지
- 네이밍: `'should [동작] when [조건]'`
- `mocktail` 사용 (mockito 아님)

## 커밋
- `feat:` / `fix:` / `test:` / `refactor:` / `docs:` / `chore:` 접두사

## 플랫폼
- Android only (minSdk 26, targetSdk 34)
- 패키지명: `com.tigerroom.fangeul`
- 플로팅 버블: Kotlin 직접 구현, 외부 패키지 금지
- Platform Channel: `com.tigerroom.fangeul/floating_bubble`
