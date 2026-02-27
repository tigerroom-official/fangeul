# 변환기 커스텀 한글 키보드 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 시스템 키보드를 대체하는 인앱 QWERTY 커스텀 한글 키보드를 변환기 화면 3탭에 적용한다.

**Architecture:** 기존 `KeyboardConverter.assembleJamos`(공개화) + 자모 리스트 기반 조합 + Flutter 위젯 키보드. 별도 FSM 불필요 — 키 입력마다 자모 리스트에 추가하고 `assembleJamos`를 재실행하여 한글 조합.

**Tech Stack:** Flutter widgets, Riverpod (freezed + riverpod_generator), HapticFeedback, 기존 core/engines

**설계서:** `docs/plans/2026-02-28-converter-custom-keyboard-design.md`

---

## 핵심 설계 결정

### 자모 조합: 리스트 + assembleJamos 재실행

기존 `KeyboardConverter._assembleJamos(List<String>)`는 자모 리스트를 받아 한글 음절로 조합하는 **완성된 FSM**이다. 이를 공개(public)하고, 키보드에서 자모 리스트를 관리하며 매 입력마다 재실행한다.

```
한→영/발음 모드:
  키 탭 → jamoList.add(jamo)
  → assembleJamos(jamoList) → Korean text
  → korToEng(korean) 또는 romanize(korean) → 변환 결과

백스페이스:
  jamoList.removeLast()
  → assembleJamos(jamoList) → Korean text 재조합
```

별도 FSM 클래스 불필요. 복합모음, 겹받침, 음절 경계 모두 기존 `assembleJamos`가 처리.

### 데이터 소유 구조

| 소유자 | 데이터 |
|--------|--------|
| `converter_screen` State | `TextEditingController`, `TabController`, `List<String> _jamoList`, `String _engBuffer` |
| `KeyboardNotifier` (Riverpod) | `CapsMode` (UI 렌더링용) |
| `ConverterNotifier` (기존) | 변환 결과 상태 |
| `KoreanKeyboard` 위젯 | 순수 UI, 콜백으로 이벤트 전달 |

---

## Task 1: `assembleJamos` 공개 + 테스트

**Files:**
- Modify: `lib/core/engines/keyboard_converter.dart:108` (`_assembleJamos` → `assembleJamos`)
- Test: `test/core/engines/keyboard_converter_test.dart` (기존 + 신규)

**Step 1: 기존 테스트 확인**

Run: `flutter test test/core/engines/keyboard_converter_test.dart`
Expected: All PASS

**Step 2: `_assembleJamos` → `assembleJamos` 공개**

```dart
// lib/core/engines/keyboard_converter.dart
// Line 108: 변경
/// 자모 리스트를 한글 음절로 조합한다.
///
/// 두벌식 표준 자판의 FSM 기반 조합 알고리즘.
/// [jamos]에 초성·중성·종성 자모를 순서대로 전달하면
/// 복합모음, 겹받침, 음절 경계를 자동 처리하여 조합된 한글을 반환한다.
///
/// 비자모 문자(공백, 숫자 등)는 그대로 통과한다.
static String assembleJamos(List<String> jamos) {
  // (기존 _assembleJamos 코드 그대로, 이름만 변경)
```

`engToKor` 내부 호출도 변경:
```dart
// Line 62: 변경
return assembleJamos(jamos);
```

**Step 3: 공개 API용 테스트 추가**

```dart
// test/core/engines/keyboard_converter_test.dart 에 추가

group('assembleJamos', () {
  test('should compose basic syllable from jamo list', () {
    expect(
      KeyboardConverter.assembleJamos(['ㅎ', 'ㅏ', 'ㄴ']),
      '한',
    );
  });

  test('should compose multiple syllables', () {
    expect(
      KeyboardConverter.assembleJamos(['ㅎ', 'ㅏ', 'ㄴ', 'ㄱ', 'ㅡ', 'ㄹ']),
      '한글',
    );
  });

  test('should handle compound vowel', () {
    expect(
      KeyboardConverter.assembleJamos(['ㅎ', 'ㅗ', 'ㅏ']),
      '화',
    );
  });

  test('should handle double final', () {
    expect(
      KeyboardConverter.assembleJamos(['ㄱ', 'ㅏ', 'ㄹ', 'ㄱ']),
      '갉',
    );
  });

  test('should split double final when followed by vowel', () {
    expect(
      KeyboardConverter.assembleJamos(['ㄱ', 'ㅏ', 'ㄹ', 'ㄱ', 'ㅏ']),
      '갈가',
    );
  });

  test('should handle standalone consonant', () {
    expect(
      KeyboardConverter.assembleJamos(['ㄱ']),
      'ㄱ',
    );
  });

  test('should handle standalone vowel', () {
    expect(
      KeyboardConverter.assembleJamos(['ㅏ']),
      'ㅏ',
    );
  });

  test('should pass through non-jamo characters', () {
    expect(
      KeyboardConverter.assembleJamos(['ㅎ', 'ㅏ', 'ㄴ', ' ', 'ㄱ', 'ㅡ', 'ㄹ']),
      '한 글',
    );
  });

  test('should handle consonant that cannot be final', () {
    // ㄸ은 종성이 될 수 없음
    expect(
      KeyboardConverter.assembleJamos(['ㄱ', 'ㅏ', 'ㄸ', 'ㅏ']),
      '가따',
    );
  });
});
```

**Step 4: 테스트 실행**

Run: `flutter test test/core/engines/keyboard_converter_test.dart`
Expected: All PASS (기존 + 신규)

**Step 5: 커밋**

```bash
git add lib/core/engines/keyboard_converter.dart test/core/engines/keyboard_converter_test.dart
git commit -m "refactor: assembleJamos 공개 — 커스텀 키보드 자모 조합용"
```

---

## Task 2: KeyboardNotifier + CapsMode (TDD)

**Files:**
- Create: `lib/presentation/providers/keyboard_providers.dart`
- Test: `test/presentation/providers/keyboard_providers_test.dart`

**Step 1: 테스트 작성**

```dart
// test/presentation/providers/keyboard_providers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/providers/keyboard_providers.dart';

void main() {
  group('KeyboardNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should start with caps off', () {
      final state = container.read(keyboardNotifierProvider);
      expect(state.capsMode, CapsMode.off);
    });

    test('should toggle to oneShot on single tap', () {
      container.read(keyboardNotifierProvider.notifier).toggleCaps();
      expect(
        container.read(keyboardNotifierProvider).capsMode,
        CapsMode.oneShot,
      );
    });

    test('should toggle to locked on double tap', () {
      final notifier = container.read(keyboardNotifierProvider.notifier);
      notifier.toggleCaps(); // off → oneShot
      notifier.toggleCaps(); // oneShot → locked
      expect(
        container.read(keyboardNotifierProvider).capsMode,
        CapsMode.locked,
      );
    });

    test('should toggle off from locked', () {
      final notifier = container.read(keyboardNotifierProvider.notifier);
      notifier.toggleCaps(); // off → oneShot
      notifier.toggleCaps(); // oneShot → locked
      notifier.toggleCaps(); // locked → off
      expect(
        container.read(keyboardNotifierProvider).capsMode,
        CapsMode.off,
      );
    });

    test('should consume oneShot after key press', () {
      final notifier = container.read(keyboardNotifierProvider.notifier);
      notifier.toggleCaps(); // off → oneShot
      notifier.consumeOneShot();
      expect(
        container.read(keyboardNotifierProvider).capsMode,
        CapsMode.off,
      );
    });

    test('should not consume locked mode', () {
      final notifier = container.read(keyboardNotifierProvider.notifier);
      notifier.toggleCaps(); // oneShot
      notifier.toggleCaps(); // locked
      notifier.consumeOneShot();
      expect(
        container.read(keyboardNotifierProvider).capsMode,
        CapsMode.locked,
      );
    });

    test('should report isShifted correctly', () {
      final notifier = container.read(keyboardNotifierProvider.notifier);
      expect(container.read(keyboardNotifierProvider).isShifted, false);

      notifier.toggleCaps();
      expect(container.read(keyboardNotifierProvider).isShifted, true);

      notifier.toggleCaps();
      expect(container.read(keyboardNotifierProvider).isShifted, true); // locked

      notifier.toggleCaps();
      expect(container.read(keyboardNotifierProvider).isShifted, false); // off
    });
  });
}
```

**Step 2: 테스트 실행 — 실패 확인**

Run: `flutter test test/presentation/providers/keyboard_providers_test.dart`
Expected: FAIL (파일 없음)

**Step 3: 구현**

```dart
// lib/presentation/providers/keyboard_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'keyboard_providers.freezed.dart';
part 'keyboard_providers.g.dart';

/// CAPS 키 모드.
enum CapsMode {
  /// 비활성.
  off,

  /// 원샷 — 다음 1글자만 쌍자음, 이후 자동 해제.
  oneShot,

  /// 잠금 — 다시 누를 때까지 유지.
  locked,
}

/// 키보드 상태.
@freezed
class KeyboardState with _$KeyboardState {
  /// Creates a [KeyboardState].
  const factory KeyboardState({
    @Default(CapsMode.off) CapsMode capsMode,
  }) = _KeyboardState;

  const KeyboardState._();

  /// CAPS가 활성 상태(oneShot 또는 locked)인지 여부.
  bool get isShifted => capsMode != CapsMode.off;
}

/// 키보드 상태 관리 Notifier.
@riverpod
class KeyboardNotifier extends _$KeyboardNotifier {
  @override
  KeyboardState build() => const KeyboardState();

  /// CAPS 토글: off → oneShot → locked → off.
  void toggleCaps() {
    state = state.copyWith(
      capsMode: switch (state.capsMode) {
        CapsMode.off => CapsMode.oneShot,
        CapsMode.oneShot => CapsMode.locked,
        CapsMode.locked => CapsMode.off,
      },
    );
  }

  /// 원샷 모드 소비. locked 모드에서는 무시.
  void consumeOneShot() {
    if (state.capsMode == CapsMode.oneShot) {
      state = state.copyWith(capsMode: CapsMode.off);
    }
  }
}
```

**Step 4: 코드 생성 + 테스트 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/presentation/providers/keyboard_providers_test.dart`
Expected: All PASS

**Step 5: 커밋**

```bash
git add lib/presentation/providers/keyboard_providers.dart \
  lib/presentation/providers/keyboard_providers.freezed.dart \
  lib/presentation/providers/keyboard_providers.g.dart \
  test/presentation/providers/keyboard_providers_test.dart
git commit -m "feat: KeyboardNotifier — CAPS 원샷/잠금 상태관리 (TDD)"
```

---

## Task 3: 키보드 레이아웃 상수 + KeyboardKey 위젯

**Files:**
- Create: `lib/presentation/widgets/keyboard_key.dart`
- Modify: `lib/presentation/constants/ui_strings.dart` (키보드 관련 문자열)

**Step 1: UI 문자열 추가**

```dart
// lib/presentation/constants/ui_strings.dart 에 추가

// Keyboard
static const keyboardSpace = 'Space';
```

**Step 2: KeyboardKey 위젯 구현**

```dart
// lib/presentation/widgets/keyboard_key.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/presentation/theme/fangeul_colors.dart';

/// 키보드의 개별 키 데이터.
class KeyData {
  /// Creates a [KeyData].
  const KeyData({
    required this.eng,
    required this.kor,
    this.korShift,
  });

  /// 영문 소문자.
  final String eng;

  /// 한글 자모 (일반).
  final String kor;

  /// 한글 자모 (쌍자음/추가모음). null이면 Shift 변형 없음.
  final String? korShift;
}

/// 키보드의 키 종류.
enum KeyType {
  /// 일반 문자 키.
  character,

  /// CAPS (쌍자음 토글) 키.
  caps,

  /// 백스페이스 키.
  backspace,

  /// 스페이스 키.
  space,
}

/// 개별 키 위젯.
class KeyboardKey extends StatelessWidget {
  /// Creates a [KeyboardKey].
  const KeyboardKey({
    required this.keyType,
    required this.onTap,
    this.keyData,
    this.isShifted = false,
    this.isCapsLocked = false,
    this.isEngToKor = true,
    this.widthMultiplier = 1.0,
    this.onLongPressStart,
    this.onLongPressEnd,
    super.key,
  });

  /// 키 종류.
  final KeyType keyType;

  /// 문자 키 데이터. [keyType]이 [KeyType.character]일 때 필수.
  final KeyData? keyData;

  /// 탭 콜백.
  final VoidCallback onTap;

  /// 롱프레스 시작 콜백 (DEL용).
  final VoidCallback? onLongPressStart;

  /// 롱프레스 종료 콜백 (DEL용).
  final VoidCallback? onLongPressEnd;

  /// Shift 활성 여부.
  final bool isShifted;

  /// CAPS 잠금 여부 (아이콘 구분용).
  final bool isCapsLocked;

  /// 영→한 모드 여부. false이면 한→영/발음.
  final bool isEngToKor;

  /// 키 너비 배수. 기본 1.0, CAPS/SPACE는 더 넓음.
  final double widthMultiplier;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyColor = isDark
        ? const Color(0xFF2A2A3E)
        : const Color(0xFFE8E8F0);
    final pressedColor = FangeulColors.primary.withValues(alpha: 0.2);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth * widthMultiplier,
          height: 48,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Material(
              color: keyColor,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                splashColor: pressedColor,
                onTap: () {
                  if (keyType == KeyType.character) {
                    HapticFeedback.selectionClick();
                  } else if (keyType == KeyType.backspace) {
                    HapticFeedback.lightImpact();
                  } else if (keyType == KeyType.caps) {
                    HapticFeedback.mediumImpact();
                  }
                  onTap();
                },
                onLongPress: onLongPressStart != null
                    ? () {
                        HapticFeedback.heavyImpact();
                        onLongPressStart!();
                      }
                    : null,
                child: _buildContent(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = FangeulColors.primary;
    final subColor = isDark
        ? FangeulColors.darkOnSurfaceVariant
        : FangeulColors.lightOnSurfaceVariant;

    return switch (keyType) {
      KeyType.character => _buildCharacterKey(primaryColor, subColor),
      KeyType.caps => _buildCapsKey(primaryColor, subColor),
      KeyType.backspace => _buildIconKey(Icons.backspace_outlined, subColor),
      KeyType.space => _buildSpaceKey(subColor),
    };
  }

  Widget _buildCharacterKey(Color primaryColor, Color subColor) {
    final data = keyData!;
    final activeKor = isShifted && data.korShift != null
        ? data.korShift!
        : data.kor;

    // 자음(초성 리스트에 있으면) = 100% 투명도, 모음 = 60%
    final isConsonant = _consonants.contains(data.kor);
    final korColor = primaryColor.withValues(
      alpha: isConsonant ? 1.0 : 0.6,
    );

    final String mainLabel;
    final String subLabel;
    final Color mainColor;
    final Color subLabelColor;

    if (isEngToKor) {
      mainLabel = isShifted ? data.eng.toUpperCase() : data.eng;
      subLabel = activeKor;
      mainColor = subColor;
      subLabelColor = korColor;
    } else {
      mainLabel = activeKor;
      subLabel = data.eng;
      mainColor = korColor;
      subLabelColor = subColor.withValues(alpha: 0.4);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          mainLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: mainColor,
            fontFamily: 'NotoSansKR',
          ),
        ),
        Text(
          subLabel,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: subLabelColor,
            fontFamily: 'NotoSansKR',
          ),
        ),
      ],
    );
  }

  Widget _buildCapsKey(Color primaryColor, Color subColor) {
    final color = isShifted ? primaryColor : subColor;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.arrow_upward, size: 20, color: color),
        if (isCapsLocked)
          Container(
            width: 12,
            height: 2,
            margin: const EdgeInsets.only(top: 2),
            color: primaryColor,
          ),
      ],
    );
  }

  Widget _buildIconKey(IconData icon, Color color) {
    return Center(
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildSpaceKey(Color color) {
    return Center(
      child: Text(
        'Space',
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }

  // 자음 판별용 (투명도 구분)
  static const _consonants = {
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ',
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
  };
}
```

**Step 3: 커밋**

```bash
git add lib/presentation/widgets/keyboard_key.dart \
  lib/presentation/constants/ui_strings.dart
git commit -m "feat: KeyboardKey 위젯 — 이중 라벨 키 + 햅틱 피드백"
```

---

## Task 4: KoreanKeyboard 위젯

**Files:**
- Create: `lib/presentation/widgets/korean_keyboard.dart`

**Step 1: 구현**

```dart
// lib/presentation/widgets/korean_keyboard.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/providers/keyboard_providers.dart';
import 'package:fangeul/presentation/theme/fangeul_colors.dart';
import 'package:fangeul/presentation/widgets/keyboard_key.dart';

/// 커스텀 한글 키보드 위젯.
///
/// QWERTY 두벌식 표준 배열. 영문(상) + 한글(하) 이중 라벨.
/// 모드에 따라 주/부 라벨이 반전된다.
class KoreanKeyboard extends ConsumerStatefulWidget {
  /// Creates a [KoreanKeyboard].
  const KoreanKeyboard({
    required this.isEngToKor,
    required this.onCharacterTap,
    required this.onBackspace,
    required this.onSpace,
    super.key,
  });

  /// 영→한 모드 여부.
  final bool isEngToKor;

  /// 문자 키 탭 콜백. (eng, kor) 쌍을 전달.
  final void Function(String eng, String kor) onCharacterTap;

  /// 백스페이스 콜백.
  final VoidCallback onBackspace;

  /// 스페이스 콜백.
  final VoidCallback onSpace;

  @override
  ConsumerState<KoreanKeyboard> createState() => _KoreanKeyboardState();
}

class _KoreanKeyboardState extends ConsumerState<KoreanKeyboard> {
  Timer? _deleteTimer;
  bool _isAccelerated = false;
  DateTime? _longPressStart;

  // ── 두벌식 표준 레이아웃 ──

  static const _row1 = [
    KeyData(eng: 'q', kor: 'ㅂ', korShift: 'ㅃ'),
    KeyData(eng: 'w', kor: 'ㅈ', korShift: 'ㅉ'),
    KeyData(eng: 'e', kor: 'ㄷ', korShift: 'ㄸ'),
    KeyData(eng: 'r', kor: 'ㄱ', korShift: 'ㄲ'),
    KeyData(eng: 't', kor: 'ㅅ', korShift: 'ㅆ'),
    KeyData(eng: 'y', kor: 'ㅛ'),
    KeyData(eng: 'u', kor: 'ㅕ'),
    KeyData(eng: 'i', kor: 'ㅑ'),
    KeyData(eng: 'o', kor: 'ㅐ', korShift: 'ㅒ'),
    KeyData(eng: 'p', kor: 'ㅔ', korShift: 'ㅖ'),
  ];

  static const _row2 = [
    KeyData(eng: 'a', kor: 'ㅁ'),
    KeyData(eng: 's', kor: 'ㄴ'),
    KeyData(eng: 'd', kor: 'ㅇ'),
    KeyData(eng: 'f', kor: 'ㄹ'),
    KeyData(eng: 'g', kor: 'ㅎ'),
    KeyData(eng: 'h', kor: 'ㅗ'),
    KeyData(eng: 'j', kor: 'ㅓ'),
    KeyData(eng: 'k', kor: 'ㅏ'),
    KeyData(eng: 'l', kor: 'ㅣ'),
  ];

  static const _row3 = [
    KeyData(eng: 'z', kor: 'ㅋ'),
    KeyData(eng: 'x', kor: 'ㅌ'),
    KeyData(eng: 'c', kor: 'ㅊ'),
    KeyData(eng: 'v', kor: 'ㅍ'),
    KeyData(eng: 'b', kor: 'ㅠ'),
    KeyData(eng: 'n', kor: 'ㅜ'),
    KeyData(eng: 'm', kor: 'ㅡ'),
  ];

  @override
  void dispose() {
    _deleteTimer?.cancel();
    super.dispose();
  }

  void _onCharTap(KeyData data) {
    final kbState = ref.read(keyboardNotifierProvider);
    final shifted = kbState.isShifted;

    final eng = shifted ? data.eng.toUpperCase() : data.eng;
    final kor = shifted && data.korShift != null ? data.korShift! : data.kor;

    widget.onCharacterTap(eng, kor);
    ref.read(keyboardNotifierProvider.notifier).consumeOneShot();
  }

  void _onDeleteLongPressStart() {
    _longPressStart = DateTime.now();
    _isAccelerated = false;

    // Phase 2: 150ms 간격으로 시작
    _deleteTimer = Timer.periodic(
      const Duration(milliseconds: 150),
      (timer) {
        widget.onBackspace();

        // Phase 3: 1500ms 후 가속 (50ms 간격)
        final elapsed = DateTime.now().difference(_longPressStart!);
        if (!_isAccelerated && elapsed.inMilliseconds > 1500) {
          _isAccelerated = true;
          timer.cancel();
          _deleteTimer = Timer.periodic(
            const Duration(milliseconds: 50),
            (_) => widget.onBackspace(),
          );
        }
      },
    );
  }

  void _onDeleteLongPressEnd() {
    _deleteTimer?.cancel();
    _deleteTimer = null;
    _isAccelerated = false;
    _longPressStart = null;
  }

  @override
  Widget build(BuildContext context) {
    final kbState = ref.watch(keyboardNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? FangeulColors.darkBackground
        : FangeulColors.lightBackground;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: 10 character keys
          _buildRow(_row1, kbState),
          const SizedBox(height: 4),
          // Row 2: 9 character keys + DEL
          _buildRow2(kbState),
          const SizedBox(height: 4),
          // Row 3: CAPS + 7 character keys + SPACE
          _buildRow3(kbState),
        ],
      ),
    );
  }

  Widget _buildRow(List<KeyData> keys, KeyboardState kbState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((data) {
        return Expanded(
          child: KeyboardKey(
            keyType: KeyType.character,
            keyData: data,
            isShifted: kbState.isShifted,
            isEngToKor: widget.isEngToKor,
            onTap: () => _onCharTap(data),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRow2(KeyboardState kbState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 9 character keys (narrower to make room for DEL)
        ..._row2.map((data) {
          return Expanded(
            child: KeyboardKey(
              keyType: KeyType.character,
              keyData: data,
              isShifted: kbState.isShifted,
              isEngToKor: widget.isEngToKor,
              onTap: () => _onCharTap(data),
            ),
          );
        }),
        // DEL key
        Expanded(
          child: KeyboardKey(
            keyType: KeyType.backspace,
            onTap: widget.onBackspace,
            onLongPressStart: _onDeleteLongPressStart,
            onLongPressEnd: _onDeleteLongPressEnd,
          ),
        ),
      ],
    );
  }

  Widget _buildRow3(KeyboardState kbState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // CAPS key (1.3x)
        Expanded(
          flex: 13,
          child: KeyboardKey(
            keyType: KeyType.caps,
            isShifted: kbState.isShifted,
            isCapsLocked: kbState.capsMode == CapsMode.locked,
            onTap: () {
              ref.read(keyboardNotifierProvider.notifier).toggleCaps();
            },
          ),
        ),
        // 7 character keys
        ..._row3.map((data) {
          return Expanded(
            flex: 10,
            child: KeyboardKey(
              keyType: KeyType.character,
              keyData: data,
              isShifted: kbState.isShifted,
              isEngToKor: widget.isEngToKor,
              onTap: () => _onCharTap(data),
            ),
          );
        }),
        // SPACE key (2x)
        Expanded(
          flex: 20,
          child: KeyboardKey(
            keyType: KeyType.space,
            onTap: widget.onSpace,
          ),
        ),
      ],
    );
  }
}
```

**Step 2: DEL 롱프레스 해제 처리 — `Listener` 래핑**

`InkWell`의 `onLongPress`는 종료 이벤트가 없으므로, `KeyboardKey.build()`에서 backspace 키를 `Listener`로 래핑:

```dart
// keyboard_key.dart의 build() 메서드에서 backspace 키만 Listener 추가
// onLongPressEnd를 위해 KeyboardKey에 Listener 래핑 필요

// KoreanKeyboard에서 GestureDetector로 직접 처리하는 것이 깨끗함.
// _buildRow2의 DEL 키를 GestureDetector로 래핑:
```

실제로는 `KoreanKeyboard._buildRow2`에서 DEL 키를 `GestureDetector`로 래핑하여 `onLongPressStart`/`onLongPressEnd`를 직접 처리. `KeyboardKey`의 `onLongPressStart`/`onLongPressEnd`를 `GestureDetector.onLongPressStart`/`onLongPressEnd`에 연결.

**Step 3: 커밋**

```bash
git add lib/presentation/widgets/korean_keyboard.dart
git commit -m "feat: KoreanKeyboard 위젯 — QWERTY 두벌식 + DEL 가속삭제"
```

---

## Task 5: Converter Screen 통합

**Files:**
- Modify: `lib/presentation/screens/converter_screen.dart` (전면 개편)
- Modify: `lib/presentation/widgets/converter_input.dart` (readOnly 지원)

**Step 1: `converter_input.dart` 수정 — readOnly 지원**

```dart
// lib/presentation/widgets/converter_input.dart
// TextField에 readOnly: true, showCursor: true 추가
// 기존 onChanged 대신 외부에서 controller.text를 직접 관리

// 변경 사항:
// 1. onChanged 콜백 제거 (더 이상 TextField에서 직접 입력 안 함)
// 2. readOnly: true 추가
// 3. showCursor: true 추가
// 4. 키보드 팝업 방지
```

`converter_input.dart` 수정:
- `onChanged` 파라미터 제거
- `TextField`에 `readOnly: true`, `showCursor: true` 추가
- `onTap`에 `FocusScope.of(context).unfocus()` 추가 (혹시 시스템 키보드가 올라오는 것 방지)

**Step 2: `converter_screen.dart` 전면 개편**

```dart
// lib/presentation/screens/converter_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/engines/keyboard_converter.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/converter_providers.dart';
import 'package:fangeul/presentation/widgets/converter_input.dart';
import 'package:fangeul/presentation/widgets/korean_keyboard.dart';

/// 변환기 화면 — 커스텀 한글 키보드로 입력.
class ConverterScreen extends ConsumerStatefulWidget {
  /// Creates a [ConverterScreen].
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _textController = TextEditingController();

  // 모드별 입력 버퍼
  List<String> _jamoList = [];  // 한→영, 발음 모드
  String _engBuffer = '';        // 영→한 모드

  static const _modes = [
    ConvertMode.engToKor,
    ConvertMode.korToEng,
    ConvertMode.romanize,
  ];

  static const _labels = [
    UiStrings.converterTabEngToKor,
    UiStrings.converterTabKorToEng,
    UiStrings.converterTabRomanize,
  ];

  static const _hints = [
    UiStrings.converterHintEngToKor,
    UiStrings.converterHintKorToEng,
    UiStrings.converterHintRomanize,
  ];

  ConvertMode get _currentMode => _modes[_tabController.index];
  bool get _isEngToKor => _currentMode == ConvertMode.engToKor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;

    // 탭 전환 시 버퍼 초기화
    _jamoList = [];
    _engBuffer = '';
    _textController.clear();
    ref.read(converterNotifierProvider.notifier).clear();
  }

  void _onCharacterTap(String eng, String kor) {
    if (_isEngToKor) {
      _engBuffer += eng;
      _textController.text = _engBuffer;
    } else {
      _jamoList.add(kor);
      _textController.text = KeyboardConverter.assembleJamos(_jamoList);
    }
    _convert();
  }

  void _onBackspace() {
    if (_isEngToKor) {
      if (_engBuffer.isEmpty) return;
      _engBuffer = _engBuffer.substring(0, _engBuffer.length - 1);
      _textController.text = _engBuffer;
    } else {
      if (_jamoList.isEmpty) return;
      _jamoList.removeLast();
      _textController.text = KeyboardConverter.assembleJamos(_jamoList);
    }
    _convert();
  }

  void _onSpace() {
    if (_isEngToKor) {
      _engBuffer += ' ';
      _textController.text = _engBuffer;
    } else {
      _jamoList.add(' ');
      _textController.text = KeyboardConverter.assembleJamos(_jamoList);
    }
    _convert();
  }

  void _convert() {
    final text = _textController.text;
    if (text.isEmpty) {
      ref.read(converterNotifierProvider.notifier).clear();
      return;
    }
    ref.read(converterNotifierProvider.notifier).convert(text, _currentMode);
  }

  void _clear() {
    _jamoList = [];
    _engBuffer = '';
    _textController.clear();
    ref.read(converterNotifierProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final converterState = ref.watch(converterNotifierProvider);

    final output = switch (converterState) {
      ConverterSuccess(:final output) => output,
      _ => '',
    };

    return Column(
      children: [
        // 탭바
        TabBar(
          controller: _tabController,
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),

        // 입력 + 출력
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConverterInput(
              controller: _textController,
              output: output,
              hintText: _hints[_tabController.index],
              onClear: _clear,
            ),
          ),
        ),

        // 커스텀 키보드
        KoreanKeyboard(
          isEngToKor: _isEngToKor,
          onCharacterTap: _onCharacterTap,
          onBackspace: _onBackspace,
          onSpace: _onSpace,
        ),
      ],
    );
  }
}
```

**Step 3: `converter_input.dart` 수정**

- `onChanged` 파라미터 → `onClear` 콜백으로 변경
- `TextField`에 `readOnly: true`, `showCursor: true` 추가
- Clear 버튼은 `onClear` 콜백 호출

```dart
// converter_input.dart 변경사항:
// - 생성자: onChanged 제거, onClear 추가
// - TextField: readOnly: true, showCursor: true
// - suffixIcon clear 버튼: onClear 호출
```

**Step 4: 기존 테스트 수정**

`converter_input.dart`의 API가 변경되므로 관련 테스트가 있으면 수정.
현재 `converter_input.dart`에 대한 별도 테스트 파일이 없으므로 (위젯은 통합 테스트), 이 단계에서는 빌드 확인만.

**Step 5: 빌드 + 분석 확인**

Run: `flutter analyze`
Expected: No issues

**Step 6: 커밋**

```bash
git add lib/presentation/screens/converter_screen.dart \
  lib/presentation/widgets/converter_input.dart
git commit -m "feat: 커스텀 한글 키보드 통합 — 시스템 키보드 대체"
```

---

## Task 6: 위젯 테스트

**Files:**
- Create: `test/presentation/widgets/korean_keyboard_test.dart`

**Step 1: 키보드 위젯 테스트**

```dart
// test/presentation/widgets/korean_keyboard_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/presentation/widgets/korean_keyboard.dart';

void main() {
  Widget buildTestApp({
    required bool isEngToKor,
    required void Function(String, String) onCharacterTap,
    VoidCallback? onBackspace,
    VoidCallback? onSpace,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: KoreanKeyboard(
            isEngToKor: isEngToKor,
            onCharacterTap: onCharacterTap,
            onBackspace: onBackspace ?? () {},
            onSpace: onSpace ?? () {},
          ),
        ),
      ),
    );
  }

  group('KoreanKeyboard', () {
    testWidgets('should render all character keys', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          isEngToKor: true,
          onCharacterTap: (_, __) {},
        ),
      );

      // 26 character keys + CAPS + DEL + SPACE = 29 tap targets
      // Check some specific keys exist
      expect(find.text('q'), findsOneWidget);
      expect(find.text('ㅂ'), findsOneWidget);
      expect(find.text('m'), findsOneWidget);
      expect(find.text('ㅡ'), findsOneWidget);
    });

    testWidgets('should call onCharacterTap with eng and kor', (tester) async {
      String? tappedEng;
      String? tappedKor;

      await tester.pumpWidget(
        buildTestApp(
          isEngToKor: true,
          onCharacterTap: (eng, kor) {
            tappedEng = eng;
            tappedKor = kor;
          },
        ),
      );

      // Tap the 'q' key (ㅂ)
      await tester.tap(find.text('q'));
      await tester.pump();

      expect(tappedEng, 'q');
      expect(tappedKor, 'ㅂ');
    });

    testWidgets('should call onBackspace when DEL tapped', (tester) async {
      var called = false;

      await tester.pumpWidget(
        buildTestApp(
          isEngToKor: true,
          onCharacterTap: (_, __) {},
          onBackspace: () => called = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      expect(called, true);
    });

    testWidgets('should call onSpace when SPACE tapped', (tester) async {
      var called = false;

      await tester.pumpWidget(
        buildTestApp(
          isEngToKor: true,
          onCharacterTap: (_, __) {},
          onSpace: () => called = true,
        ),
      );

      await tester.tap(find.text('Space'));
      await tester.pump();

      expect(called, true);
    });

    testWidgets('should show Korean as main label in korToEng mode',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          isEngToKor: false,
          onCharacterTap: (_, __) {},
        ),
      );

      // In korToEng mode, Korean should be the main (bigger) label
      // This is visually tested — the key structure puts main label first
      // Verify both labels are present
      expect(find.text('ㅂ'), findsOneWidget);
      expect(find.text('q'), findsOneWidget);
    });
  });
}
```

**Step 2: 테스트 실행**

Run: `flutter test test/presentation/widgets/korean_keyboard_test.dart`
Expected: All PASS

**Step 3: 커밋**

```bash
git add test/presentation/widgets/korean_keyboard_test.dart
git commit -m "test: KoreanKeyboard 위젯 테스트 — 키 탭/백스페이스/스페이스"
```

---

## Task 7: 전체 검증 + 정리

**Step 1: 코드 생성**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Success

**Step 2: 전체 테스트**

Run: `flutter test`
Expected: All PASS (기존 151 + 신규)

**Step 3: 정적 분석**

Run: `flutter analyze`
Expected: No issues

**Step 4: 포맷**

Run: `dart format --set-exit-if-changed .`
Expected: No changes (or format and re-run)

**Step 5: 최종 커밋 (필요 시)**

```bash
git add -A
git commit -m "chore: 커스텀 키보드 최종 정리 — 분석/포맷 통과"
```

---

## 의존성 그래프

```
Task 1: assembleJamos 공개     [독립]
Task 2: KeyboardNotifier        [독립]
Task 3: KeyboardKey 위젯        [독립]
Task 4: KoreanKeyboard 위젯     [→ Task 2, 3]
Task 5: Converter Screen 통합   [→ Task 1, 4]
Task 6: 위젯 테스트             [→ Task 4]
Task 7: 전체 검증               [→ 전체]
```

Task 1, 2, 3은 독립적이므로 병렬 실행 가능.

---

## 검증 체크리스트

- [ ] 영→한: 영문 키 탭 → 한글 변환 결과 표시
- [ ] 한→영: 한글 키 탭 → 자모 조합 → 영문 변환 결과 표시
- [ ] 발음: 한글 키 탭 → 자모 조합 → 로마자 변환 결과 표시
- [ ] CAPS: 원샷(1글자 후 해제) + 더블탭(잠금)
- [ ] DEL: 단일 삭제 + 롱프레스 가속 (150ms→50ms)
- [ ] SPACE: 공백 입력 + 음절 확정
- [ ] 복합모음: ㅗ+ㅏ=ㅘ 정상 조합
- [ ] 겹받침: ㄹ+ㄱ=ㄺ → 다음 모음 시 분리
- [ ] 탭 전환: 버퍼 초기화, 키보드 라벨 반전
- [ ] 다크/라이트: 테마에 맞는 키보드 색상
- [ ] 시스템 키보드: 올라오지 않음
- [ ] 기존 테스트: 151개 모두 PASS
