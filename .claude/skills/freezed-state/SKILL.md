---
name: freezed-state
description: Riverpod Notifier + freezed sealed State 클래스를 생성한다
user_invocable: true
---

# Freezed State Generator

Fangeul 프로젝트 패턴에 맞는 Riverpod Notifier + freezed State를 생성하는 스킬.

## 입력

사용자가 기능 이름(예: `converter`, `phrase_library`)을 제공하면 아래를 생성한다.

## 생성 파일

### 1. State 클래스

```
lib/presentation/providers/{feature_name}_state.dart
```

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{feature_name}_state.freezed.dart';

/// {Feature} 화면 상태.
@freezed
sealed class {Feature}State with _${Feature}State {
  const factory {Feature}State.initial() = _Initial;
  const factory {Feature}State.loading() = _Loading;
  const factory {Feature}State.success({결과 타입} result) = _Success;
  const factory {Feature}State.error(String message) = _Error;
}
```

### 2. Notifier

```
lib/presentation/providers/{feature_name}_notifier.dart
```

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/providers/{feature_name}_state.dart';

part '{feature_name}_notifier.g.dart';

/// {Feature} 비즈니스 로직 Notifier.
@riverpod
class {Feature}Notifier extends _${Feature}Notifier {
  @override
  {Feature}State build() => const {Feature}State.initial();
}
```

### 3. 코드 생성 실행

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 규칙

- State 4단계 필수: `initial / loading / success / error`
- `ref.watch` → `build()`에서만, `ref.read` → 이벤트 핸들러에서만
- 한 파일에 하나의 public 클래스
- 모든 public 클래스/메서드에 dartdoc
- UseCase를 통해 core/ 접근: `ref.read(useCaseProvider).execute(...)`
