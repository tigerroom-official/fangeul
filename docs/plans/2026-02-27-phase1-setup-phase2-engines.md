# Phase 1 (프로젝트 셋업) + Phase 2 (Core 엔진) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fangeul Flutter 프로젝트의 기반을 세우고, 핵심 엔진 3개(한글 조합/분해, 키보드 위치 변환, 로마자 발음 변환)를 TDD로 구현한다.

**Architecture:** Clean Architecture 3-Layer (core/data/presentation). Core 엔진은 순수 Dart로 구현하며 Flutter 의존성이 없다. 상태관리는 Riverpod + riverpod_generator, 모델은 freezed.

**Tech Stack:** Flutter 3.27.1 / Dart 3.6.0, Riverpod 2.x, freezed, build_runner, mocktail

**Reference:** 영타로 소스(`../typing_convertor/lib/utils/eng2kor.dart`)의 한글 조합 로직 및 매핑 테이블 참조. 엔진 상세: `docs/engine-guide.md`.

---

## Phase 1: 프로젝트 셋업

### Task 1: pubspec.yaml 의존성 추가

**Files:**
- Modify: `pubspec.yaml`

**Step 1: pubspec.yaml 전체 교체**

```yaml
name: fangeul
description: "Korean utility app for K-pop fans — Hangul keypad, keyboard converter, romanizer, fan phrases."
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: ^3.6.0

dependencies:
  flutter:
    sdk: flutter

  # 상태관리
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # Immutable 모델
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # 오디오 재생
  just_audio: ^0.9.40

  # 로컬 저장소
  shared_preferences: ^2.3.3

  # 유틸리티
  path_provider: ^2.1.4
  http: ^1.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter

  # 코드 생성
  build_runner: ^2.4.13
  riverpod_generator: ^2.6.2
  freezed: ^2.5.7
  json_serializable: ^6.8.0

  # 린트
  flutter_lints: ^5.0.0

  # 테스트
  mocktail: ^1.0.4

flutter:
  uses-material-design: true

  assets:
    - assets/phrases/
    - assets/audio/
```

**Step 2: flutter pub get 실행**

Run: `flutter pub get`
Expected: 성공 (exit 0)

---

### Task 2: 디렉토리 구조 생성

**Files:**
- Create: `lib/` 하위 전체 디렉토리 구조
- Create: `test/` 하위 디렉토리 구조
- Create: `assets/` 하위 디렉토리 구조

**Step 1: 디렉토리 및 placeholder 파일 생성**

```bash
# lib/ 구조
mkdir -p lib/core/entities
mkdir -p lib/core/usecases
mkdir -p lib/core/repositories
mkdir -p lib/core/engines
mkdir -p lib/data/repositories
mkdir -p lib/data/datasources
mkdir -p lib/data/models
mkdir -p lib/presentation/screens
mkdir -p lib/presentation/widgets
mkdir -p lib/presentation/providers
mkdir -p lib/presentation/theme
mkdir -p lib/services
mkdir -p lib/platform

# test/ 구조
mkdir -p test/core/engines
mkdir -p test/core/usecases
mkdir -p test/data/repositories
mkdir -p test/presentation/providers

# assets/ 구조
mkdir -p assets/phrases
mkdir -p assets/audio

# placeholder JSON (빈 팩)
echo '{"packs":[]}' > assets/phrases/basic_love.json

# placeholder audio (빈 디렉토리에 .gitkeep)
touch assets/audio/.gitkeep
```

---

### Task 3: Android 설정 (applicationId, minSdk, 권한)

**Files:**
- Modify: `android/app/build.gradle`
- Modify: `android/app/src/main/AndroidManifest.xml`

**Step 1: build.gradle 수정**

`android/app/build.gradle` 에서:
- `namespace` → `"com.tigerroom.fangeul"` (이미 설정됨)
- `applicationId` → `"com.tigerroom.fangeul"` (이미 설정됨)
- `minSdk` → `26`
- `targetSdk` → `34`

```groovy
android {
    namespace = "com.tigerroom.fangeul"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId = "com.tigerroom.fangeul"
        minSdk = 26
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug
        }
    }
}
```

**Step 2: AndroidManifest.xml 권한 추가**

`<manifest>` 태그 안, `<application>` 앞에 권한 3개 추가:
```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

**Step 3:** Kotlin 패키지 디렉토리는 이미 `com/tigerroom/fangeul/`에 올바르게 위치. 변경 불필요.

---

### Task 4: app.dart + main.dart 기본 구조

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/app.dart`

**Step 1: main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: FangeulApp(),
    ),
  );
}
```

**Step 2: app.dart**

```dart
import 'package:flutter/material.dart';

/// Fangeul 앱의 루트 위젯.
class FangeulApp extends StatelessWidget {
  /// Creates the root [FangeulApp] widget.
  const FangeulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fangeul',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C5CE7),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C5CE7),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Fangeul — Coming Soon'),
        ),
      ),
    );
  }
}
```

---

### Task 5: 빌드 검증

**Step 1: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 2: flutter test (빈 테스트)**

Run: `flutter test`
Expected: No tests found (또는 기본 widget_test 제거 후 0 tests)

**Step 3: 커밋**

```bash
git add -A
git commit -m "chore: Phase 1 프로젝트 셋업 — 의존성, 디렉토리 구조, Android 설정"
```

---

## Phase 2: Core 엔진 (순수 Dart, TDD)

> 모든 엔진은 `lib/core/engines/`에 위치하며 Flutter import 없이 순수 Dart로 구현.
> 참조: 영타로 `eng2kor.dart`의 한글 조합 로직 + `docs/fangeul-product-spec.md` 부록 B 매핑 테이블.

### Task 6: 한글 엔진 — 자모 상수 및 분해 (테스트 먼저)

**Files:**
- Create: `lib/core/engines/jamo.dart` (Jamo 데이터 클래스 — 별도 파일, "한 파일 한 public 클래스" 규칙)
- Create: `lib/core/engines/hangul_engine.dart`
- Create: `test/core/engines/hangul_engine_test.dart`

**Step 1: 분해(decompose) 테스트 작성**

```dart
// test/core/engines/hangul_engine_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/engines/hangul_engine.dart';

void main() {
  group('HangulEngine.decompose', () {
    test('should decompose 가 into ㄱ, ㅏ, (없음)', () {
      final result = HangulEngine.decompose('가');
      expect(result, equals([Jamo(initial: 'ㄱ', medial: 'ㅏ', final_: '')]));
    });

    test('should decompose 한 into ㅎ, ㅏ, ㄴ', () {
      final result = HangulEngine.decompose('한');
      expect(result, equals([Jamo(initial: 'ㅎ', medial: 'ㅏ', final_: 'ㄴ')]));
    });

    test('should decompose 글 into ㄱ, ㅡ, ㄹ', () {
      final result = HangulEngine.decompose('글');
      expect(result, equals([Jamo(initial: 'ㄱ', medial: 'ㅡ', final_: 'ㄹ')]));
    });

    test('should decompose multi-char 한글 into two Jamo', () {
      final result = HangulEngine.decompose('한글');
      expect(result.length, equals(2));
      expect(result[0], equals(Jamo(initial: 'ㅎ', medial: 'ㅏ', final_: 'ㄴ')));
      expect(result[1], equals(Jamo(initial: 'ㄱ', medial: 'ㅡ', final_: 'ㄹ')));
    });

    test('should handle double final consonant ㄺ (닭)', () {
      final result = HangulEngine.decompose('닭');
      expect(result, equals([Jamo(initial: 'ㄷ', medial: 'ㅏ', final_: 'ㄺ')]));
    });

    test('should handle double final consonant ㄳ (넋→넉 X, 몫)', () {
      final result = HangulEngine.decompose('몫');
      expect(result, equals([Jamo(initial: 'ㅁ', medial: 'ㅗ', final_: 'ㄳ')]));
    });

    test('should return empty list for empty string', () {
      final result = HangulEngine.decompose('');
      expect(result, isEmpty);
    });

    test('should skip non-hangul characters', () {
      final result = HangulEngine.decompose('A1!');
      expect(result, isEmpty);
    });

    test('should decompose mixed input keeping only hangul', () {
      final result = HangulEngine.decompose('가A나');
      expect(result.length, equals(2));
    });
  });
}
```

**Step 2: 테스트 실행 → 실패 확인**

Run: `flutter test test/core/engines/hangul_engine_test.dart`
Expected: FAIL — `hangul_engine.dart` 파일 없음

**Step 3: 한글 엔진 — 자모 상수 + 분해 구현**

```dart
// lib/core/engines/hangul_engine.dart

/// 한글 유니코드 자모 분해/조합 엔진.
///
/// Unicode Hangul Syllables 블록 (U+AC00~U+D7A3) 기반으로
/// 초성/중성/종성을 분해하고 조합한다.
/// 순수 Dart로 구현되며 Flutter 의존성이 없다.
class HangulEngine {
  HangulEngine._();

  /// 한글 음절 시작 코드포인트 (가 = 0xAC00)
  static const int _syllableBase = 0xAC00;

  /// 한글 음절 끝 코드포인트 (힣 = 0xD7A3)
  static const int _syllableEnd = 0xD7A3;

  /// 중성 개수
  static const int _medialCount = 21;

  /// 종성 개수 (종성 없음 포함)
  static const int _finalCount = 28;

  /// 초성 목록 (19개)
  static const List<String> initials = [
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ',
    'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
  ];

  /// 중성 목록 (21개)
  static const List<String> medials = [
    'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ',
    'ㅘ', 'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ',
    'ㅢ', 'ㅣ',
  ];

  /// 종성 목록 (28개, 인덱스 0 = 종성 없음)
  static const List<String> finals = [
    '', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ',
    'ㄺ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ',
    'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
  ];

  /// [char]가 한글 완성형 음절인지 판별한다.
  static bool isSyllable(int charCode) {
    return charCode >= _syllableBase && charCode <= _syllableEnd;
  }

  /// 한글 문자열을 자모로 분해한다.
  ///
  /// 한글 완성형 음절만 분해하며, 비한글 문자는 무시한다.
  /// 예: '한글' → [Jamo(ㅎ,ㅏ,ㄴ), Jamo(ㄱ,ㅡ,ㄹ)]
  static List<Jamo> decompose(String text) {
    final result = <Jamo>[];
    for (final rune in text.runes) {
      if (!isSyllable(rune)) continue;

      final offset = rune - _syllableBase;
      final initialIdx = offset ~/ (_medialCount * _finalCount);
      final medialIdx = (offset % (_medialCount * _finalCount)) ~/ _finalCount;
      final finalIdx = offset % _finalCount;

      result.add(Jamo(
        initial: initials[initialIdx],
        medial: medials[medialIdx],
        final_: finals[finalIdx],
      ));
    }
    return result;
  }

  /// 초성, 중성, 종성 인덱스로 한글 음절을 조합한다.
  ///
  /// 예: compose(18, 0, 4) → '한' (ㅎ=18, ㅏ=0, ㄴ=4)
  static String compose(int initialIdx, int medialIdx, int finalIdx) {
    final code = _syllableBase +
        (initialIdx * _medialCount + medialIdx) * _finalCount +
        finalIdx;
    return String.fromCharCode(code);
  }

  /// [Jamo] 객체로부터 한글 음절을 조합한다.
  static String composeFromJamo(Jamo jamo) {
    final initialIdx = initials.indexOf(jamo.initial);
    final medialIdx = medials.indexOf(jamo.medial);
    final finalIdx = finals.indexOf(jamo.final_);

    if (initialIdx == -1 || medialIdx == -1 || finalIdx == -1) {
      return '';
    }

    return compose(initialIdx, medialIdx, finalIdx);
  }

  /// 자모 리스트를 한글 문자열로 조합한다.
  static String composeAll(List<Jamo> jamos) {
    final buffer = StringBuffer();
    for (final jamo in jamos) {
      buffer.write(composeFromJamo(jamo));
    }
    return buffer.toString();
  }
}

/// 한글 음절의 초성/중성/종성을 나타내는 불변 데이터 클래스.
class Jamo {
  /// Creates a [Jamo] with the given initial, medial, and final consonant.
  const Jamo({
    required this.initial,
    required this.medial,
    required this.final_,
  });

  /// 초성 (ㄱ~ㅎ)
  final String initial;

  /// 중성 (ㅏ~ㅣ)
  final String medial;

  /// 종성 (빈 문자열이면 종성 없음)
  final String final_;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Jamo &&
        other.initial == initial &&
        other.medial == medial &&
        other.final_ == final_;
  }

  @override
  int get hashCode => Object.hash(initial, medial, final_);

  @override
  String toString() => 'Jamo($initial, $medial, $final_)';
}
```

**Step 4: 테스트 실행 → 통과 확인**

Run: `flutter test test/core/engines/hangul_engine_test.dart`
Expected: All tests passed

---

### Task 7: 한글 엔진 — 조합(compose) 테스트 추가 및 검증

**Files:**
- Modify: `test/core/engines/hangul_engine_test.dart`

**Step 1: 조합 테스트 추가**

```dart
  group('HangulEngine.compose', () {
    test('should compose ㄱ+ㅏ into 가', () {
      final result = HangulEngine.compose(0, 0, 0);
      expect(result, equals('가'));
    });

    test('should compose ㅎ+ㅏ+ㄴ into 한', () {
      // ㅎ=18, ㅏ=0, ㄴ=4
      final result = HangulEngine.compose(18, 0, 4);
      expect(result, equals('한'));
    });

    test('should compose ㄱ+ㅡ+ㄹ into 글', () {
      // ㄱ=0, ㅡ=18, ㄹ=8
      final result = HangulEngine.compose(0, 18, 8);
      expect(result, equals('글'));
    });

    test('should compose ㄷ+ㅏ+ㄺ into 닭', () {
      // ㄷ=3, ㅏ=0, ㄺ=9
      final result = HangulEngine.compose(3, 0, 9);
      expect(result, equals('닭'));
    });
  });

  group('HangulEngine.composeFromJamo', () {
    test('should compose Jamo back to original syllable', () {
      final jamo = Jamo(initial: 'ㅎ', medial: 'ㅏ', final_: 'ㄴ');
      expect(HangulEngine.composeFromJamo(jamo), equals('한'));
    });

    test('should return empty string for invalid jamo', () {
      final jamo = Jamo(initial: 'X', medial: 'ㅏ', final_: '');
      expect(HangulEngine.composeFromJamo(jamo), equals(''));
    });
  });

  group('HangulEngine round-trip', () {
    test('should decompose and recompose to original', () {
      const original = '한글사랑해요';
      final jamos = HangulEngine.decompose(original);
      final recomposed = HangulEngine.composeAll(jamos);
      expect(recomposed, equals(original));
    });

    test('should round-trip all double final consonants', () {
      // 겹받침이 포함된 글자들
      const words = '닭몫없값삶넓읽';
      final jamos = HangulEngine.decompose(words);
      final recomposed = HangulEngine.composeAll(jamos);
      expect(recomposed, equals(words));
    });
  });
```

**Step 2: 테스트 실행**

Run: `flutter test test/core/engines/hangul_engine_test.dart`
Expected: All tests passed

**Step 3: 커밋**

```bash
git add lib/core/engines/hangul_engine.dart test/core/engines/hangul_engine_test.dart
git commit -m "feat: 한글 엔진 자모 분해/조합 구현 (TDD)"
```

---

### Task 8: 키보드 변환기 — 영→한 변환 (테스트 먼저)

**Files:**
- Create: `lib/core/engines/keyboard_converter.dart`
- Create: `test/core/engines/keyboard_converter_test.dart`

**Step 1: 영→한 테스트 작성**

```dart
// test/core/engines/keyboard_converter_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/engines/keyboard_converter.dart';

void main() {
  group('KeyboardConverter.engToKor', () {
    test('should convert gksrmf to 한글', () {
      expect(KeyboardConverter.engToKor('gksrmf'), equals('한글'));
    });

    test('should convert tkfkdgody to 사랑해요', () {
      expect(KeyboardConverter.engToKor('tkfkdgody'), equals('사랑해요'));
    });

    test('should convert dkssudgktpdy to 안녕하세요', () {
      expect(KeyboardConverter.engToKor('dkssudgktpdy'), equals('안녕하세요'));
    });

    test('should handle shift for double consonants (ㅃ)', () {
      // Q → ㅃ
      expect(KeyboardConverter.engToKor('Qkf'), equals('빨'));
    });

    test('should handle shift for double consonants (ㄲ)', () {
      // R → ㄲ
      expect(KeyboardConverter.engToKor('Rkwl'), equals('꿀'));
    });

    test('should handle shift vowel ㅒ when O pressed', () {
      expect(KeyboardConverter.engToKor('sO'), equals('냬'));
    });

    test('should handle shift vowel ㅖ when P pressed', () {
      expect(KeyboardConverter.engToKor('sP'), equals('녜'));
    });

    test('should handle double final consonants (겹받침)', () {
      expect(KeyboardConverter.engToKor('ekfr'), equals('닭'));
    });

    test('should pass through non-mappable characters', () {
      expect(KeyboardConverter.engToKor('123!'), equals('123!'));
    });

    test('should handle mixed input', () {
      expect(KeyboardConverter.engToKor('gksrmf123'), equals('한글123'));
    });

    test('should return empty string for empty input', () {
      expect(KeyboardConverter.engToKor(''), equals(''));
    });

    test('should handle spaces', () {
      expect(KeyboardConverter.engToKor('gks rmf'), equals('한 글'));
    });

    test('should handle single vowel input', () {
      expect(KeyboardConverter.engToKor('k'), equals('ㅏ'));
    });

    test('should handle single consonant input', () {
      expect(KeyboardConverter.engToKor('r'), equals('ㄱ'));
    });
  });
}
```

**Step 2: 테스트 실행 → 실패 확인**

Run: `flutter test test/core/engines/keyboard_converter_test.dart`
Expected: FAIL

**Step 3: 키보드 변환기 구현**

> 핵심 로직: 영문자 → 자모 매핑 후, 자모 시퀀스를 한글 음절로 조합.
> 영타로의 `eng2kor.dart` 로직을 Clean Architecture에 맞게 재구현.
> 매핑 테이블은 `docs/fangeul-product-spec.md` 부록 B 기준.

```dart
// lib/core/engines/keyboard_converter.dart

import 'package:fangeul/core/engines/hangul_engine.dart';

/// 영↔한 키보드 위치 변환기.
///
/// 두벌식 표준 자판 레이아웃 기반으로 영문 키 입력을
/// 한글 자모로 매핑한 뒤, [HangulEngine]을 이용해 음절로 조합한다.
class KeyboardConverter {
  KeyboardConverter._();

  // ── 영문 → 자모 매핑 (두벌식 표준) ──

  /// 영문 키 → 한글 자모 매핑 (일반 + Shift)
  static const Map<String, String> _engToJamo = {
    // 일반 (소문자)
    'q': 'ㅂ', 'w': 'ㅈ', 'e': 'ㄷ', 'r': 'ㄱ', 't': 'ㅅ',
    'y': 'ㅛ', 'u': 'ㅕ', 'i': 'ㅑ', 'o': 'ㅐ', 'p': 'ㅔ',
    'a': 'ㅁ', 's': 'ㄴ', 'd': 'ㅇ', 'f': 'ㄹ', 'g': 'ㅎ',
    'h': 'ㅗ', 'j': 'ㅓ', 'k': 'ㅏ', 'l': 'ㅣ',
    'z': 'ㅋ', 'x': 'ㅌ', 'c': 'ㅊ', 'v': 'ㅍ',
    'b': 'ㅠ', 'n': 'ㅜ', 'm': 'ㅡ',
    // Shift (대문자) — 쌍자음 + 추가 모음
    'Q': 'ㅃ', 'W': 'ㅉ', 'E': 'ㄸ', 'R': 'ㄲ', 'T': 'ㅆ',
    'O': 'ㅒ', 'P': 'ㅖ',
  };

  /// 자모 → 영문 키 역매핑
  static final Map<String, String> _jamoToEng = () {
    final map = <String, String>{};
    // 소문자 매핑을 기본으로
    _engToJamo.forEach((eng, jamo) {
      // 대문자(Shift) 매핑은 소문자 매핑이 없는 자모만
      if (eng == eng.toLowerCase() || !map.containsKey(jamo)) {
        map[jamo] = eng;
      }
    });
    return map;
  }();

  // ── 자모 분류 ──

  static const Set<String> _initialConsonants = {
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ',
    'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
  };

  static const Set<String> _vowels = {
    'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ',
    'ㅘ', 'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ',
    'ㅢ', 'ㅣ',
  };

  /// 종성으로 쓸 수 있는 단일 자음 → 종성 인덱스 매핑
  static const Map<String, int> _finalConsonantIdx = {
    'ㄱ': 1, 'ㄲ': 2, 'ㄳ': 3, 'ㄴ': 4, 'ㄵ': 5, 'ㄶ': 6,
    'ㄷ': 7, 'ㄹ': 8, 'ㄺ': 9, 'ㄻ': 10, 'ㄼ': 11, 'ㄽ': 12,
    'ㄾ': 13, 'ㄿ': 14, 'ㅀ': 15, 'ㅁ': 16, 'ㅂ': 17, 'ㅄ': 18,
    'ㅅ': 19, 'ㅆ': 20, 'ㅇ': 21, 'ㅈ': 22, 'ㅊ': 23,
    'ㅋ': 24, 'ㅌ': 25, 'ㅍ': 26, 'ㅎ': 27,
  };

  /// 겹받침 조합 테이블: (첫 자음, 둘째 자음) → 겹받침
  static const Map<String, Map<String, String>> _doubleFinals = {
    'ㄱ': {'ㅅ': 'ㄳ'},
    'ㄴ': {'ㅈ': 'ㄵ', 'ㅎ': 'ㄶ'},
    'ㄹ': {'ㄱ': 'ㄺ', 'ㅁ': 'ㄻ', 'ㅂ': 'ㄼ', 'ㅅ': 'ㄽ',
           'ㅌ': 'ㄾ', 'ㅍ': 'ㄿ', 'ㅎ': 'ㅀ'},
    'ㅂ': {'ㅅ': 'ㅄ'},
  };

  /// 겹받침 → (첫 자음, 둘째 자음) 분리
  static const Map<String, List<String>> _doubleFinalSplit = {
    'ㄳ': ['ㄱ', 'ㅅ'], 'ㄵ': ['ㄴ', 'ㅈ'], 'ㄶ': ['ㄴ', 'ㅎ'],
    'ㄺ': ['ㄹ', 'ㄱ'], 'ㄻ': ['ㄹ', 'ㅁ'], 'ㄼ': ['ㄹ', 'ㅂ'],
    'ㄽ': ['ㄹ', 'ㅅ'], 'ㄾ': ['ㄹ', 'ㅌ'], 'ㄿ': ['ㄹ', 'ㅍ'],
    'ㅀ': ['ㄹ', 'ㅎ'], 'ㅄ': ['ㅂ', 'ㅅ'],
  };

  /// 복합 모음 조합 테이블
  static const Map<String, Map<String, String>> _compoundVowels = {
    'ㅗ': {'ㅏ': 'ㅘ', 'ㅐ': 'ㅙ', 'ㅣ': 'ㅚ'},
    'ㅜ': {'ㅓ': 'ㅝ', 'ㅔ': 'ㅞ', 'ㅣ': 'ㅟ'},
    'ㅡ': {'ㅣ': 'ㅢ'},
  };

  /// 영문 입력을 한글로 변환한다.
  ///
  /// 두벌식 표준 자판 레이아웃 기준으로 영문 키를 한글 자모로
  /// 매핑한 뒤 음절을 조합한다.
  /// 예: 'gksrmf' → '한글'
  static String engToKor(String input) {
    if (input.isEmpty) return '';

    // 1단계: 영문 → 자모 시퀀스로 변환
    final jamos = <String>[];
    for (final char in input.split('')) {
      final jamo = _engToJamo[char];
      if (jamo != null) {
        jamos.add(jamo);
      } else {
        jamos.add(char); // 매핑 안 되는 문자는 그대로
      }
    }

    // 2단계: 자모 시퀀스를 한글 음절로 조합
    return _assembleJamos(jamos);
  }

  /// 한글 입력을 영문으로 변환한다.
  ///
  /// 한글 음절을 자모로 분해한 뒤, 각 자모를 영문 키로 역매핑한다.
  /// 예: '한글' → 'gksrmf'
  static String korToEng(String input) {
    if (input.isEmpty) return '';

    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);

      if (HangulEngine.isSyllable(rune)) {
        // 완성형 한글 → 분해 → 영문 역매핑
        final jamos = HangulEngine.decompose(char);
        for (final jamo in jamos) {
          buffer.write(_jamoToEng[jamo.initial] ?? '');
          buffer.write(_jamoToEng[jamo.medial] ?? '');
          if (jamo.final_.isNotEmpty) {
            // 겹받침 분리
            final split = _doubleFinalSplit[jamo.final_];
            if (split != null) {
              buffer.write(_jamoToEng[split[0]] ?? '');
              buffer.write(_jamoToEng[split[1]] ?? '');
            } else {
              buffer.write(_jamoToEng[jamo.final_] ?? '');
            }
          }
        }
      } else if (_jamoToEng.containsKey(char)) {
        // 단독 자모 → 영문
        buffer.write(_jamoToEng[char]);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  // ── 자모 → 음절 조합 FSM ──

  static String _assembleJamos(List<String> jamos) {
    final buffer = StringBuffer();
    var i = 0;

    while (i < jamos.length) {
      final current = jamos[i];

      // 자음이 아닌 경우
      if (!_initialConsonants.contains(current)) {
        if (_vowels.contains(current)) {
          // 단독 모음 → 자모 문자 출력
          buffer.write(current);
          i++;
        } else {
          // 비한글 문자
          buffer.write(current);
          i++;
        }
        continue;
      }

      // 초성 자음 발견
      final initialJamo = current;
      final initialIdx = HangulEngine.initials.indexOf(initialJamo);
      if (initialIdx == -1) {
        buffer.write(current);
        i++;
        continue;
      }

      // 다음이 모음인지 확인
      if (i + 1 >= jamos.length || !_vowels.contains(jamos[i + 1])) {
        // 자음만 단독 → 자모 문자 출력
        buffer.write(current);
        i++;
        continue;
      }

      // 중성 모음
      var medialJamo = jamos[i + 1];
      i += 2;

      // 복합 모음 확인
      if (i < jamos.length && _compoundVowels.containsKey(medialJamo)) {
        final nextChar = jamos[i];
        final compound = _compoundVowels[medialJamo]?[nextChar];
        if (compound != null) {
          medialJamo = compound;
          i++;
        }
      }

      final medialIdx = HangulEngine.medials.indexOf(medialJamo);
      if (medialIdx == -1) {
        buffer.write(initialJamo);
        buffer.write(medialJamo);
        continue;
      }

      // 종성 확인
      var finalIdx = 0; // 종성 없음

      if (i < jamos.length && _initialConsonants.contains(jamos[i])) {
        final possibleFinal = jamos[i];

        // 이 자음이 종성이 될 수 있는지, 다음에 모음이 오는지 확인
        final possibleFinalIdx = _finalConsonantIdx[possibleFinal];

        if (possibleFinalIdx != null) {
          // 다음에 모음이 오면 → 이 자음은 다음 음절의 초성
          if (i + 1 < jamos.length && _vowels.contains(jamos[i + 1])) {
            // 종성 없이 현재 음절 완성
          } else if (i + 1 < jamos.length &&
              _initialConsonants.contains(jamos[i + 1])) {
            // 다음도 자음 → 겹받침 가능성 확인
            final nextConsonant = jamos[i + 1];
            final doubleFinal =
                _doubleFinals[possibleFinal]?[nextConsonant];

            if (doubleFinal != null) {
              final doubleFinalIdx = _finalConsonantIdx[doubleFinal];
              if (doubleFinalIdx != null) {
                // 겹받침 다음에 모음이 오면 → 겹받침 분리
                if (i + 2 < jamos.length &&
                    _vowels.contains(jamos[i + 2])) {
                  // 첫 자음만 종성, 둘째 자음은 다음 초성
                  finalIdx = possibleFinalIdx;
                  i++;
                } else {
                  // 겹받침 확정
                  finalIdx = doubleFinalIdx;
                  i += 2;
                }
              }
            } else {
              // 겹받침 불가 → 단일 종성
              finalIdx = possibleFinalIdx;
              i++;
            }
          } else {
            // 문자열 끝 → 종성 확정
            finalIdx = possibleFinalIdx;
            i++;
          }
        }
      }

      buffer.write(HangulEngine.compose(initialIdx, medialIdx, finalIdx));
    }

    return buffer.toString();
  }
}
```

**Step 4: 테스트 실행**

Run: `flutter test test/core/engines/keyboard_converter_test.dart`
Expected: All tests passed

---

### Task 9: 키보드 변환기 — 한→영 변환 테스트 추가

**Files:**
- Modify: `test/core/engines/keyboard_converter_test.dart`

**Step 1: 한→영 테스트 추가**

```dart
  group('KeyboardConverter.korToEng', () {
    test('should convert 한글 to gksrmf', () {
      expect(KeyboardConverter.korToEng('한글'), equals('gksrmf'));
    });

    test('should convert 사랑해요 to tkfkdgody', () {
      expect(KeyboardConverter.korToEng('사랑해요'), equals('tkfkdgody'));
    });

    test('should convert 안녕하세요 to dkssudgktpdy', () {
      expect(KeyboardConverter.korToEng('안녕하세요'), equals('dkssudgktpdy'));
    });

    test('should handle double final consonants', () {
      expect(KeyboardConverter.korToEng('닭'), equals('ekfr'));
    });

    test('should pass through non-hangul characters', () {
      expect(KeyboardConverter.korToEng('123!'), equals('123!'));
    });

    test('should handle spaces', () {
      expect(KeyboardConverter.korToEng('한 글'), equals('gks rmf'));
    });

    test('should return empty string for empty input', () {
      expect(KeyboardConverter.korToEng(''), equals(''));
    });
  });

  group('KeyboardConverter round-trip', () {
    test('should round-trip eng→kor→eng', () {
      const original = 'gksrmf';
      final kor = KeyboardConverter.engToKor(original);
      final back = KeyboardConverter.korToEng(kor);
      expect(back, equals(original));
    });

    test('should round-trip kor→eng→kor', () {
      const original = '사랑해요';
      final eng = KeyboardConverter.korToEng(original);
      final back = KeyboardConverter.engToKor(eng);
      expect(back, equals(original));
    });
  });
```

**Step 2: 테스트 실행**

Run: `flutter test test/core/engines/keyboard_converter_test.dart`
Expected: All tests passed

**Step 3: 커밋**

```bash
git add lib/core/engines/keyboard_converter.dart test/core/engines/keyboard_converter_test.dart
git commit -m "feat: 키보드 위치 변환기 영↔한 양방향 구현 (TDD)"
```

---

### Task 10: 로마자 발음 변환기 — 기본 매핑 (테스트 먼저)

**Files:**
- Create: `lib/core/engines/romanizer.dart`
- Create: `test/core/engines/romanizer_test.dart`

**Step 1: 기본 변환 테스트 작성 (발음 규칙 없이 매핑만)**

```dart
// test/core/engines/romanizer_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/engines/romanizer.dart';

void main() {
  group('Romanizer — 기본 자모 매핑', () {
    test('should romanize 가 to ga', () {
      expect(Romanizer.romanize('가'), equals('ga'));
    });

    test('should romanize 나 to na', () {
      expect(Romanizer.romanize('나'), equals('na'));
    });

    test('should romanize 한 to han', () {
      expect(Romanizer.romanize('한'), equals('han'));
    });

    test('should return empty string for empty input', () {
      expect(Romanizer.romanize(''), equals(''));
    });

    test('should pass through non-hangul characters', () {
      expect(Romanizer.romanize('123'), equals('123'));
    });

    test('should handle spaces', () {
      expect(Romanizer.romanize('가 나'), equals('ga na'));
    });
  });

  group('Romanizer — 연음법칙', () {
    test('should apply liaison: 음악 → eumak (no liaison here)', () {
      expect(Romanizer.romanize('음악'), equals('eumak'));
    });

    test('should apply liaison: 먹어 → meogeo', () {
      expect(Romanizer.romanize('먹어'), equals('meogeo'));
    });

    test('should apply liaison: 없어요 → eopseoyo', () {
      expect(Romanizer.romanize('없어요'), equals('eopseoyo'));
    });
  });

  group('Romanizer — 비음화', () {
    test('should apply nasalization: 합니다 → hamnida', () {
      expect(Romanizer.romanize('합니다'), equals('hamnida'));
    });

    test('should apply nasalization: 국물 → gungmul', () {
      expect(Romanizer.romanize('국물'), equals('gungmul'));
    });

    test('should apply nasalization: 읽는 → ingneun', () {
      expect(Romanizer.romanize('읽는'), equals('ingneun'));
    });
  });

  group('Romanizer — 격음화', () {
    test('should apply aspiration: 좋다 → jota', () {
      expect(Romanizer.romanize('좋다'), equals('jota'));
    });

    test('should apply aspiration: 놓다 → nota', () {
      expect(Romanizer.romanize('놓다'), equals('nota'));
    });

    test('should apply aspiration: 축하 → chuka', () {
      expect(Romanizer.romanize('축하'), equals('chuka'));
    });
  });

  group('Romanizer — 구개음화', () {
    test('should apply palatalization: 같이 → gachi', () {
      expect(Romanizer.romanize('같이'), equals('gachi'));
    });

    test('should apply palatalization: 굳이 → guji', () {
      expect(Romanizer.romanize('굳이'), equals('guji'));
    });

    test('should apply palatalization: 해돋이 → haedoji', () {
      expect(Romanizer.romanize('해돋이'), equals('haedoji'));
    });
  });

  group('Romanizer — 경음화', () {
    test('should apply fortition: 학교 → hakkkyo', () {
      expect(Romanizer.romanize('학교'), equals('hakkkyo'));
    });

    test('should apply fortition: 식당 → sikttang', () {
      expect(Romanizer.romanize('식당'), equals('sikttang'));
    });

    test('should apply fortition: 입구 → ipkku', () {
      expect(Romanizer.romanize('입구'), equals('ipkku'));
    });
  });

  group('Romanizer — ㄹ 비음화', () {
    test('should apply ㄹ-nasalization: 심리 → simni', () {
      expect(Romanizer.romanize('심리'), equals('simni'));
    });

    test('should apply ㄹ-nasalization: 종로 → jongno', () {
      expect(Romanizer.romanize('종로'), equals('jongno'));
    });

    test('should apply ㄹ-nasalization: 정류장 → jeongnyujang', () {
      expect(Romanizer.romanize('정류장'), equals('jeongnyujang'));
    });
  });

  group('Romanizer — 유음화', () {
    test('should apply liquidization: 설날 → seollal', () {
      expect(Romanizer.romanize('설날'), equals('seollal'));
    });

    test('should apply liquidization: 칼날 → kallal', () {
      expect(Romanizer.romanize('칼날'), equals('kallal'));
    });

    test('should apply liquidization: 신라 → silla', () {
      expect(Romanizer.romanize('신라'), equals('silla'));
    });
  });

  group('Romanizer — 규칙 중첩', () {
    test('should handle nasalization + liaison: 읽어요 → ilgeoyo', () {
      expect(Romanizer.romanize('읽어요'), equals('ilgeoyo'));
    });

    test('should handle aspiration in compound: 못하다 → motada → motada', () {
      expect(Romanizer.romanize('못하다'), equals('motada'));
    });

    test('should handle multiple rules: 독립 → dongnip', () {
      expect(Romanizer.romanize('독립'), equals('dongnip'));
    });
  });

  group('Romanizer — 실사용 문구', () {
    test('should romanize 사랑해요 → saranghaeyo', () {
      expect(Romanizer.romanize('사랑해요'), equals('saranghaeyo'));
    });

    test('should romanize 안녕하세요 → annyeonghaseyo', () {
      expect(Romanizer.romanize('안녕하세요'), equals('annyeonghaseyo'));
    });

    test('should romanize 감사합니다 → gamsahamnida', () {
      expect(Romanizer.romanize('감사합니다'), equals('gamsahamnida'));
    });

    test('should romanize 화이팅 → hwaiting', () {
      expect(Romanizer.romanize('화이팅'), equals('hwaiting'));
    });

    test('should romanize 보고 싶어요 → bogo sipeoyo', () {
      expect(Romanizer.romanize('보고 싶어요'), equals('bogo sipeoyo'));
    });
  });
}
```

**Step 2: 테스트 실행 → 실패 확인**

Run: `flutter test test/core/engines/romanizer_test.dart`
Expected: FAIL

**Step 3: 로마자 변환기 구현 — 2-pass 아키텍처**

> 국립국어원 로마자 표기법(2000년 고시) 기반.
> 테이블 드리븐 규칙 엔진으로 구현 (하드코딩 조건문 금지).
> 참조: zaeleus/hangeul (Rust), KOROMAN (부산대)
> 상세 설계: `docs/engine-guide.md` 섹션 3.

**아키텍처: 2-pass 방식 (Jamo immutable 유지)**

```
Pass 1: 전처리 — 전체 음절을 _SyllableInfo 리스트로 변환,
         음절 경계에서 발음 변화 규칙을 적용하여 초성/종성 변경
Pass 2: 로마자 변환 — 전처리된 음절 리스트를 로마자로 매핑
```

**핵심 설계 결정:**
- `Jamo` 클래스는 **immutable 유지** (hangul_engine.dart에서 import)
- 로마자 변환기 내부에 `_SyllableInfo` mutable 래퍼 클래스 생성
- Pass 1에서 `_SyllableInfo`의 `initial`/`final_` 필드를 직접 수정
- Pass 2에서 수정된 `_SyllableInfo`를 로마자 테이블로 매핑

```dart
// lib/core/engines/romanizer.dart

import 'package:fangeul/core/engines/hangul_engine.dart';

/// 한글 → 로마자 발음 변환기.
///
/// 국립국어원 로마자 표기법(2000년 고시) 기반으로
/// 한글 텍스트를 로마자(Latin) 표기로 변환한다.
/// 2-pass 방식: 전처리(발음 규칙 적용) → 로마자 매핑.
class Romanizer {
  Romanizer._();

  // ── 로마자 매핑 테이블 (초성/중성/종성) ──
  static const Map<String, String> _initialRoman = { /* ... */ };
  static const Map<String, String> _medialRoman = { /* ... */ };
  static const Map<String, String> _finalRoman = { /* ... */ };

  // ── 발음 변화 규칙 테이블 ──
  static const Map<String, Map<String, List<String>>> _nasalization = { /* ... */ };
  static const Map<String, Map<String, String>> _aspiration = { /* ... */ };
  static const Map<String, String> _palatalization = { /* ... */ };
  static const Map<String, String> _fortition = { /* ... */ };
  // + ㄹ 비음화 / 유음화 테이블 추가

  /// 한글 텍스트를 로마자로 변환한다.
  static String romanize(String text) {
    if (text.isEmpty) return '';

    // Pass 1: 텍스트를 _SyllableInfo 리스트로 변환 + 발음 규칙 적용
    final syllables = _preprocess(text);

    // Pass 2: 전처리된 음절을 로마자로 변환
    return _toRoman(syllables);
  }

  /// Pass 1: 음절 리스트를 전처리하여 발음 변화 규칙을 적용한다.
  static List<_Token> _preprocess(String text) {
    final tokens = <_Token>[];

    for (final rune in text.runes) {
      if (HangulEngine.isSyllable(rune)) {
        final jamos = HangulEngine.decompose(String.fromCharCode(rune));
        if (jamos.isNotEmpty) {
          final j = jamos[0];
          tokens.add(_SyllableInfo(
            initial: j.initial,
            medial: j.medial,
            final_: j.final_,
          ));
        }
      } else {
        tokens.add(_LiteralToken(String.fromCharCode(rune)));
      }
    }

    // 인접 음절 경계에서 발음 규칙 적용 (순서: 연음→비음화→격음화→구개음화→경음화→ㄹ비음화/유음화)
    for (var i = 0; i < tokens.length - 1; i++) {
      final curr = tokens[i];
      final next = tokens[i + 1];
      if (curr is _SyllableInfo && next is _SyllableInfo) {
        _applyRules(curr, next);
      }
    }

    return tokens;
  }

  /// 인접 두 음절에 발음 변화 규칙을 적용한다.
  /// curr의 종성과 next의 초성을 직접 수정한다.
  static void _applyRules(_SyllableInfo curr, _SyllableInfo next) {
    // 우선순위 순서대로 적용 (하나만 적용되면 return)
    if (_applyLiaison(curr, next)) return;
    if (_applyAspiration(curr, next)) return;
    if (_applyPalatalization(curr, next)) return;
    if (_applyNasalization(curr, next)) return;
    if (_applyRieulNasalization(curr, next)) return;
    if (_applyLiquidization(curr, next)) return;
    if (_applyFortition(curr, next)) return;
  }

  /// Pass 2: 전처리된 토큰 리스트를 로마자 문자열로 변환한다.
  static String _toRoman(List<_Token> tokens) {
    final buffer = StringBuffer();
    for (final token in tokens) {
      if (token is _SyllableInfo) {
        buffer.write(_initialRoman[token.initial] ?? '');
        buffer.write(_medialRoman[token.medial] ?? '');
        if (token.final_.isNotEmpty) {
          buffer.write(_finalRoman[token.final_] ?? '');
        }
      } else if (token is _LiteralToken) {
        buffer.write(token.value);
      }
    }
    return buffer.toString();
  }
}

/// 토큰 베이스 클래스.
sealed class _Token {}

/// 한글 음절의 mutable 래퍼. Pass 1에서 발음 규칙 적용 시 변경된다.
class _SyllableInfo extends _Token {
  String initial;
  String medial;
  String final_;
  _SyllableInfo({required this.initial, required this.medial, required this.final_});
}

/// 비한글 문자 토큰.
class _LiteralToken extends _Token {
  final String value;
  _LiteralToken(this.value);
}
```

> **구현 시 주의:**
> - 매핑 테이블은 plan에서 제시한 것을 그대로 사용 (위 `/* ... */`는 지면 절약)
> - 각 `_apply*` 규칙 메서드는 `bool`을 반환하여 적용 여부를 표시
> - ㄹ 비음화: 비ㄹ 종성(ㅁ,ㅇ,ㄴ 제외) + ㄹ초성 → ㄹ→ㄴ, 유음화: ㄹ종성+ㄴ초성 → ㄴ→ㄹ, ㄴ종성+ㄹ초성 → ㄴ→ㄹ
> - 실제 `_apply*` 메서드 구현은 TDD로 테스트에 맞춰 작성

**Step 4: 테스트 실행 및 디버깅**

Run: `flutter test test/core/engines/romanizer_test.dart`
Expected: All tests passed (반복 조정 필요 가능)

**Step 5: 커밋**

```bash
git add lib/core/engines/romanizer.dart test/core/engines/romanizer_test.dart
git commit -m "feat: 로마자 발음 변환기 구현 — 연음/비음화/격음화/구개음화/경음화 (TDD)"
```

---

### Task 11: 전체 엔진 통합 테스트 + Phase 2 완료 검증

**Files:**
- Modify: `test/core/engines/` (기존 테스트 보강)

**Step 1: 전체 테스트 실행**

Run: `flutter test`
Expected: All tests passed

**Step 2: 커버리지 확인**

Run: `flutter test --coverage`
Expected: `coverage/lcov.info` 생성. `core/engines/` 파일들 100% 커버리지 확인.

```bash
# 커버리지 요약 출력 (lcov 설치 필요 시 brew install lcov)
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```

**Step 3: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 4: 최종 커밋**

```bash
git add -A
git commit -m "test: Phase 2 Core 엔진 통합 테스트 검증 완료"
```

---

## 체크리스트

### Phase 1 완료 조건
- [ ] `flutter pub get` 성공
- [ ] `flutter analyze` 에러 0
- [ ] 디렉토리 구조 (core/engines, data, presentation, services, platform)
- [ ] Android: applicationId=com.tigerroom.fangeul, minSdk=26, targetSdk=34
- [ ] AndroidManifest: SYSTEM_ALERT_WINDOW, FOREGROUND_SERVICE, INTERNET

### Phase 2 완료 조건
- [ ] `hangul_engine.dart` + `jamo.dart`: 자모 분해/조합, 겹받침 처리, round-trip 검증
- [ ] `keyboard_converter.dart`: gksrmf↔한글, tkfkdgody↔사랑해요, 겹받침, Shift
- [ ] `romanizer.dart` (2-pass): 연음, 비음화, 격음화, 구개음화, 경음화, ㄹ비음화, 유음화
- [ ] 각 발음 규칙 테스트 3개 이상 + 규칙 중첩 테스트
- [ ] 실사용 문구 테스트: 사랑해요→saranghaeyo, 안녕하세요→annyeonghaseyo 등
- [ ] `flutter test` 전체 통과
- [ ] `flutter test --coverage` — core/engines/ 100% 커버리지
- [ ] `flutter analyze` 에러 0
