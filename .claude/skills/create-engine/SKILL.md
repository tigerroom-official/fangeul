---
name: create-engine
description: TDD 방식으로 core/engines/ 에 새 엔진 클래스를 생성한다
user_invocable: true
---

# Create Engine (TDD)

Fangeul 프로젝트의 `core/engines/` 에 새 엔진을 TDD로 생성하는 스킬.

## 입력

사용자가 엔진 이름과 목적을 설명하면 아래 단계를 따른다.

## 단계

### 1. 테스트 파일 먼저 생성

```
test/core/engines/{engine_name}_test.dart
```

- `package:flutter_test/flutter_test.dart` import
- `package:fangeul/core/engines/{engine_name}.dart` import
- 기본 그룹: 정상 입력, 빈 입력, 엣지 케이스
- 테스트 네이밍: `'should [동작] when [조건]'`
- 최소 6개 테스트 케이스

### 2. 구현 파일 생성

```
lib/core/engines/{engine_name}.dart
```

- private 생성자: `ClassName._();`
- static 메서드만 (순수 함수형)
- `package:fangeul/` import만 허용 (Flutter/외부 패키지 금지)
- 모든 public 메서드에 dartdoc (`///`)

### 3. 검증

```bash
flutter test test/core/engines/{engine_name}_test.dart  # 신규 테스트 pass
flutter test test/core/engines/                          # 기존 테스트 영향 없음
flutter analyze                                          # No issues
```

### 4. 공유 테이블

엔진 간 공유 데이터가 있으면 `HangulTables`에 추가한다.
절대 테이블을 엔진 내부에 중복 정의하지 않는다.

## 규칙

- Red → Green → Refactor 순서 엄수
- `core/`는 순수 Dart만 — Flutter/외부 패키지 import 금지
- 기존 엔진 참고: `hangul_engine.dart`, `keyboard_converter.dart`, `romanizer.dart`
