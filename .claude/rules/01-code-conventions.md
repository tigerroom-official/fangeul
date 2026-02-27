# Fangeul — Code Conventions

## Dart 스타일

- `dart format` 기본 준수
- 파일명: `snake_case.dart` / 클래스: `PascalCase` / 변수·함수: `camelCase`
- 상수: `camelCase` (Dart 컨벤션)
- private: `_prefix`

## 파일 규칙

- **한 파일에 하나의 public 클래스.** 관련 private 클래스는 같은 파일에 허용.
- **barrel export (index.dart) 금지.** 명시적 import.
- **상대 경로 import 금지.** 항상 `package:fangeul/` 사용.

## import 순서

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. 외부 패키지 (알파벳순)
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 4. 프로젝트 내부 (레이어 순서: core → data → services → presentation)
import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/data/repositories/phrase_repository_impl.dart';
```

## Riverpod Provider 패턴

```dart
// 기능별 Provider 파일 분리
@riverpod
class ConverterNotifier extends _$ConverterNotifier {
  @override
  ConverterState build() => const ConverterState.initial();

  Future<void> convert(String input, ConvertMode mode) async {
    state = const ConverterState.loading();
    try {
      final result = ref.read(convertTextUseCaseProvider).execute(input, mode);
      state = ConverterState.success(result);
    } catch (e) {
      state = ConverterState.error(e.toString());
    }
  }
}

// State는 항상 freezed sealed class
@freezed
sealed class ConverterState with _$ConverterState {
  const factory ConverterState.initial() = _Initial;
  const factory ConverterState.loading() = _Loading;
  const factory ConverterState.success(ConvertResult result) = _Success;
  const factory ConverterState.error(String message) = _Error;
}
```

- Provider 네이밍: `{기능}Provider`, `{기능}NotifierProvider`
- UseCase Provider: `@riverpod UseCase useCase(Ref ref) => UseCase(ref.read(repoProvider));`

## 주석

- 모든 public 클래스/메서드에 dartdoc (`///`) 필수
- "왜(why)"를 설명. "무엇(what)"은 코드 자체로.
- TODO: `// TODO(fangeul): 설명`

## 테스트

- `core/engines/` 유닛 테스트 100% 커버리지
- 테스트 네이밍: `'should [동작] when [조건]'`
- `mocktail` 사용 (mockito 아님)
- 발음 규칙별 최소 3개 이상 테스트 케이스. 규칙 중첩 케이스 포함.
- Provider 테스트: `ProviderContainer` 격리 테스트

## 커밋 컨벤션

```
feat: / fix: / test: / refactor: / docs: / chore:
```
