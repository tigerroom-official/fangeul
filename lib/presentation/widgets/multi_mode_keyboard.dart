import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide KeyboardKey;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/engines/keyboard_converter.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/keyboard_providers.dart';
import 'package:fangeul/presentation/theme/fangeul_colors.dart';
import 'package:fangeul/presentation/widgets/keyboard_key.dart';

/// 키보드 입력 모드.
enum InputMode {
  /// 두벌식 한글.
  korean,

  /// QWERTY 영문.
  abc,

  /// 숫자 + 기호.
  numbers,
}

/// 한글/ABC/123 3모드 가상 키보드.
///
/// 아이돌 선택 화면에서 한글 입력 수단이 없는 동남아 유저를 위해
/// 커스텀 그룹명/멤버명 입력에 사용한다.
/// 한글/ABC 모드 모두 [KeyboardKey] + [KeyData] 를 재사용하며
/// (`isEngToKor` 플래그로 주/보조 라벨 전환),
/// 자모 조합은 [KeyboardConverter.assembleJamos]를 호출한다.
class MultiModeKeyboard extends ConsumerStatefulWidget {
  /// Creates a [MultiModeKeyboard].
  const MultiModeKeyboard({
    required this.onText,
    required this.onDone,
    this.initialMode = InputMode.korean,
    super.key,
  });

  /// 조합된 전체 텍스트 콜백. 매 입력마다 호출.
  final ValueChanged<String> onText;

  /// 완료 버튼 콜백.
  final VoidCallback onDone;

  /// 초기 입력 모드.
  final InputMode initialMode;

  @override
  ConsumerState<MultiModeKeyboard> createState() => MultiModeKeyboardState();
}

/// [MultiModeKeyboard]의 상태. GlobalKey로 외부 접근 가능.
class MultiModeKeyboardState extends ConsumerState<MultiModeKeyboard> {
  late InputMode _mode;

  /// 확정된 텍스트 (모드 전환 시 flush된 자모 포함).
  String _committedText = '';

  /// 한글 모드 자모 버퍼.
  List<String> _jamoList = [];

  // ── QWERTY KeyData (한글/ABC 모드 공유) ──

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

  // ── 123 레이아웃 ──

  static const _numRow1 = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  static const _numRow2 = ['@', '#', '-', '_', '(', ')', '/', '.'];

  // ── DEL 가속 삭제 ──

  Timer? _deleteTimer;
  bool _isAccelerated = false;
  bool _isDisposed = false;
  DateTime? _longPressStart;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _deleteTimer?.cancel();
    super.dispose();
  }

  // ── Public API ──

  /// 현재 조합 텍스트 반환.
  String get currentText =>
      _committedText +
      (_jamoList.isEmpty ? '' : KeyboardConverter.assembleJamos(_jamoList));

  /// 외부에서 텍스트 설정 (필드 전환 시).
  void setText(String text) {
    setState(() {
      _committedText = text;
      _jamoList = [];
    });
  }

  // ── 내부 로직 ──

  /// 자모 버퍼를 flush하여 committedText에 합산.
  void _flushJamo() {
    if (_jamoList.isNotEmpty) {
      _committedText += KeyboardConverter.assembleJamos(_jamoList);
      _jamoList = [];
    }
  }

  void _switchMode(InputMode newMode) {
    if (newMode == _mode) return;
    setState(() {
      _flushJamo();
      _mode = newMode;
    });
  }

  void _emitText() {
    widget.onText(currentText);
  }

  /// 한글 모드: 한글 자모를 자모 리스트에 추가.
  void _onKoreanChar(KeyData data) {
    final kbState = ref.read(keyboardNotifierProvider);
    final shifted = kbState.isShifted;
    final kor = shifted && data.korShift != null ? data.korShift! : data.kor;

    setState(() {
      _jamoList = [..._jamoList, kor];
    });
    ref.read(keyboardNotifierProvider.notifier).consumeOneShot();
    _emitText();
  }

  /// ABC 모드: 영문 문자를 committedText에 추가.
  void _onAbcChar(KeyData data) {
    final kbState = ref.read(keyboardNotifierProvider);
    final shifted = kbState.isShifted;
    final output = shifted ? data.eng.toUpperCase() : data.eng;

    setState(() {
      _committedText += output;
    });
    ref.read(keyboardNotifierProvider.notifier).consumeOneShot();
    _emitText();
  }

  /// 123 모드: 숫자/기호를 committedText에 추가.
  void _onNumChar(String char) {
    setState(() {
      _committedText += char;
    });
    _emitText();
  }

  void _onSpace() {
    setState(() {
      if (_mode == InputMode.korean) {
        _jamoList = [..._jamoList, ' '];
      } else {
        _committedText += ' ';
      }
    });
    _emitText();
  }

  void _onBackspace() {
    setState(() {
      if (_mode == InputMode.korean && _jamoList.isNotEmpty) {
        _jamoList = _jamoList.sublist(0, _jamoList.length - 1);
      } else if (_committedText.isNotEmpty) {
        _committedText =
            _committedText.substring(0, _committedText.length - 1);
      }
    });
    _emitText();
  }

  // ── DEL 가속 삭제 ──

  void _onDeleteLongPressStart() {
    _longPressStart = DateTime.now();
    _isAccelerated = false;
    _deleteTimer = Timer.periodic(
      const Duration(milliseconds: 150),
      (timer) {
        if (_isDisposed) {
          timer.cancel();
          return;
        }
        _onBackspace();
        final elapsed = DateTime.now().difference(_longPressStart!);
        if (!_isAccelerated && elapsed.inMilliseconds > 1500) {
          _isAccelerated = true;
          HapticFeedback.heavyImpact();
          timer.cancel();
          if (_isDisposed) return;
          _deleteTimer = Timer.periodic(
            const Duration(milliseconds: 50),
            (t) {
              if (_isDisposed) {
                t.cancel();
                return;
              }
              _onBackspace();
            },
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

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final kbState = ref.watch(keyboardNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? FangeulColors.darkBackground : FangeulColors.lightBackground;
    final theme = Theme.of(context);

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolbar(theme),
          const SizedBox(height: 4),
          ..._buildKeyRows(kbState),
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<InputMode>(
              segments: const [
                ButtonSegment(
                  value: InputMode.korean,
                  label: Text(UiStrings.keyboardModeKorean),
                ),
                ButtonSegment(
                  value: InputMode.abc,
                  label: Text(UiStrings.keyboardModeAbc),
                ),
                ButtonSegment(
                  value: InputMode.numbers,
                  label: Text(UiStrings.keyboardModeNumbers),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => _switchMode(s.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: WidgetStatePropertyAll(
                  theme.textTheme.labelSmall,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              _flushJamo();
              widget.onDone();
            },
            child: const Text(UiStrings.keyboardDone),
          ),
        ],
      ),
    );
  }

  // ── 키 행 분기 ──

  List<Widget> _buildKeyRows(KeyboardState kbState) {
    return switch (_mode) {
      InputMode.korean => _buildQwertyRows(kbState, isEngToKor: false),
      InputMode.abc => _buildQwertyRows(kbState, isEngToKor: true),
      InputMode.numbers => _buildNumberRows(),
    };
  }

  // ── 한글/ABC 공통 QWERTY 행 ──

  List<Widget> _buildQwertyRows(
    KeyboardState kbState, {
    required bool isEngToKor,
  }) {
    void Function(KeyData) onChar =
        isEngToKor ? _onAbcChar : _onKoreanChar;

    return [
      _buildCharRow(_row1, kbState, isEngToKor: isEngToKor, onChar: onChar),
      const SizedBox(height: 4),
      _buildCharRow2(kbState, isEngToKor: isEngToKor, onChar: onChar),
      const SizedBox(height: 4),
      _buildCharRow3(kbState, isEngToKor: isEngToKor, onChar: onChar),
    ];
  }

  /// Row 1: 10개 문자 키.
  Widget _buildCharRow(
    List<KeyData> keys,
    KeyboardState kbState, {
    required bool isEngToKor,
    required void Function(KeyData) onChar,
  }) {
    return Row(
      children: keys
          .map(
            (data) => Expanded(
              child: KeyboardKey(
                keyType: KeyType.character,
                keyData: data,
                isShifted: kbState.isShifted,
                isEngToKor: isEngToKor,
                onTap: () => onChar(data),
              ),
            ),
          )
          .toList(),
    );
  }

  /// Row 2: 9개 문자 키 + DEL 키.
  Widget _buildCharRow2(
    KeyboardState kbState, {
    required bool isEngToKor,
    required void Function(KeyData) onChar,
  }) {
    return Row(
      children: [
        ..._row2.map(
          (data) => Expanded(
            child: KeyboardKey(
              keyType: KeyType.character,
              keyData: data,
              isShifted: kbState.isShifted,
              isEngToKor: isEngToKor,
              onTap: () => onChar(data),
            ),
          ),
        ),
        Expanded(
          child: KeyboardKey(
            keyType: KeyType.backspace,
            onTap: _onBackspace,
            onLongPressStart: _onDeleteLongPressStart,
            onLongPressEnd: _onDeleteLongPressEnd,
          ),
        ),
      ],
    );
  }

  /// Row 3: CAPS + 7개 문자 키 + SPACE.
  Widget _buildCharRow3(
    KeyboardState kbState, {
    required bool isEngToKor,
    required void Function(KeyData) onChar,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 13,
          child: KeyboardKey(
            keyType: KeyType.caps,
            isShifted: kbState.isShifted,
            isCapsLocked: kbState.capsMode == CapsMode.locked,
            onTap: () =>
                ref.read(keyboardNotifierProvider.notifier).toggleCaps(),
          ),
        ),
        ..._row3.map(
          (data) => Expanded(
            flex: 10,
            child: KeyboardKey(
              keyType: KeyType.character,
              keyData: data,
              isShifted: kbState.isShifted,
              isEngToKor: isEngToKor,
              onTap: () => onChar(data),
            ),
          ),
        ),
        Expanded(
          flex: 20,
          child: KeyboardKey(
            keyType: KeyType.space,
            onTap: _onSpace,
          ),
        ),
      ],
    );
  }

  // ── 123 모드 ──

  List<Widget> _buildNumberRows() {
    return [
      _buildSimpleRow(_numRow1, _onNumChar),
      const SizedBox(height: 4),
      _buildNumRow2(),
      const SizedBox(height: 4),
      _buildNumRow3(),
    ];
  }

  Widget _buildNumRow2() {
    return Row(
      children: [
        ..._numRow2.map(
          (ch) => Expanded(child: _SimpleKey(label: ch, onTap: _onNumChar)),
        ),
        Expanded(
          child: KeyboardKey(
            keyType: KeyType.backspace,
            onTap: _onBackspace,
            onLongPressStart: _onDeleteLongPressStart,
            onLongPressEnd: _onDeleteLongPressEnd,
          ),
        ),
      ],
    );
  }

  Widget _buildNumRow3() {
    return Row(
      children: [
        Expanded(
          flex: 13,
          child: _ModeButton(
            label: UiStrings.keyboardModeAbc,
            onTap: () => _switchMode(InputMode.abc),
          ),
        ),
        Expanded(
          flex: 70,
          child: KeyboardKey(
            keyType: KeyType.space,
            onTap: _onSpace,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleRow(
    List<String> chars,
    void Function(String) onChar,
  ) {
    return Row(
      children: chars
          .map((ch) => Expanded(child: _SimpleKey(label: ch, onTap: onChar)))
          .toList(),
    );
  }
}

/// 단일 라벨 키 (123 모드용).
class _SimpleKey extends StatelessWidget {
  const _SimpleKey({required this.label, required this.onTap});

  final String label;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF3F4F6);
    final textColor =
        isDark ? FangeulColors.darkOnSurface : FangeulColors.lightOnSurface;
    final accentColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            splashColor: accentColor.withValues(alpha: 0.2),
            onTap: () {
              HapticFeedback.selectionClick();
              onTap(label);
            },
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'NotoSansKR',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 모드 전환 버튼 (123 모드의 ABC 전환).
class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF3F4F6);
    final textColor = isDark
        ? FangeulColors.darkOnSurfaceVariant
        : FangeulColors.lightOnSurfaceVariant;

    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'NotoSansKR',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
