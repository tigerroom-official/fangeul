import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide KeyboardKey;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/providers/keyboard_providers.dart';
import 'package:fangeul/presentation/theme/fangeul_colors.dart';
import 'package:fangeul/presentation/widgets/keyboard_key.dart';

/// QWERTY 두벌식 한글 키보드 위젯.
///
/// 3행 키 배열(문자 26키 + CAPS/DEL/SPACE 특수키)을 렌더링한다.
/// [KeyboardNotifier]를 통해 CAPS 상태를 관리하며,
/// DEL 키는 길게 누르면 가속 삭제(150ms -> 50ms)를 지원한다.
class KoreanKeyboard extends ConsumerStatefulWidget {
  /// [KoreanKeyboard]를 생성한다.
  ///
  /// [isEngToKor]가 true이면 영문이 주 라벨, false이면 한글이 주 라벨.
  /// [onCharacterTap]은 문자 키 입력 시 영문/한글 쌍을 전달한다.
  /// [onBackspace]는 백스페이스(삭제) 콜백이다.
  /// [onSpace]는 스페이스바 콜백이다.
  const KoreanKeyboard({
    required this.isEngToKor,
    required this.onCharacterTap,
    required this.onBackspace,
    required this.onSpace,
    super.key,
  });

  /// 영->한 모드 여부.
  final bool isEngToKor;

  /// 문자 키 탭 콜백. 영문과 한글을 함께 전달.
  final void Function(String eng, String kor) onCharacterTap;

  /// 백스페이스 콜백.
  final VoidCallback onBackspace;

  /// 스페이스바 콜백.
  final VoidCallback onSpace;

  @override
  ConsumerState<KoreanKeyboard> createState() => _KoreanKeyboardState();
}

class _KoreanKeyboardState extends ConsumerState<KoreanKeyboard> {
  // ── Row 1: 10 keys ──

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

  // ── Row 2: 9 keys (DEL은 별도 처리) ──

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

  // ── Row 3: 7 keys (CAPS, SPACE는 별도 처리) ──

  static const _row3 = [
    KeyData(eng: 'z', kor: 'ㅋ'),
    KeyData(eng: 'x', kor: 'ㅌ'),
    KeyData(eng: 'c', kor: 'ㅊ'),
    KeyData(eng: 'v', kor: 'ㅍ'),
    KeyData(eng: 'b', kor: 'ㅠ'),
    KeyData(eng: 'n', kor: 'ㅜ'),
    KeyData(eng: 'm', kor: 'ㅡ'),
  ];

  // ── DEL 가속 삭제 상태 ──

  Timer? _deleteTimer;
  bool _isAccelerated = false;
  DateTime? _longPressStart;

  @override
  void dispose() {
    _deleteTimer?.cancel();
    super.dispose();
  }

  // ── 문자 키 탭 ──

  void _onCharTap(KeyData data) {
    final kbState = ref.read(keyboardNotifierProvider);
    final shifted = kbState.isShifted;

    final eng = shifted ? data.eng.toUpperCase() : data.eng;
    final kor = shifted && data.korShift != null ? data.korShift! : data.kor;

    widget.onCharacterTap(eng, kor);
    ref.read(keyboardNotifierProvider.notifier).consumeOneShot();
  }

  // ── DEL 가속 삭제 ──

  /// Phase 2: 길게 누르기 시작 -- 150ms 간격 삭제.
  /// Phase 3: 1500ms 이후 -- 50ms 간격 가속.
  void _onDeleteLongPressStart() {
    _longPressStart = DateTime.now();
    _isAccelerated = false;
    _deleteTimer = Timer.periodic(
      const Duration(milliseconds: 150),
      (timer) {
        widget.onBackspace();
        final elapsed = DateTime.now().difference(_longPressStart!);
        if (!_isAccelerated && elapsed.inMilliseconds > 1500) {
          _isAccelerated = true;
          HapticFeedback.heavyImpact();
          timer.cancel();
          _deleteTimer = Timer.periodic(
            const Duration(milliseconds: 50),
            (_) => widget.onBackspace(),
          );
        }
      },
    );
  }

  /// Phase 4: 길게 누르기 종료 -- 타이머 정리.
  void _onDeleteLongPressEnd() {
    _deleteTimer?.cancel();
    _deleteTimer = null;
    _isAccelerated = false;
    _longPressStart = null;
  }

  // ── 빌드 ──

  @override
  Widget build(BuildContext context) {
    final kbState = ref.watch(keyboardNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? FangeulColors.darkBackground : FangeulColors.lightBackground;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(_row1, kbState),
          const SizedBox(height: 4),
          _buildRow2(kbState),
          const SizedBox(height: 4),
          _buildRow3(kbState),
        ],
      ),
    );
  }

  // ── Row builders ──

  /// 일반 행: 모든 키가 동일 너비(Expanded).
  Widget _buildRow(List<KeyData> keys, KeyboardState kbState) {
    return Row(
      children: keys
          .map(
            (data) => Expanded(
              child: KeyboardKey(
                keyType: KeyType.character,
                keyData: data,
                isShifted: kbState.isShifted,
                isEngToKor: widget.isEngToKor,
                onTap: () => _onCharTap(data),
              ),
            ),
          )
          .toList(),
    );
  }

  /// Row 2: 9개 문자 키 + DEL 키.
  Widget _buildRow2(KeyboardState kbState) {
    return Row(
      children: [
        ..._row2.map(
          (data) => Expanded(
            child: KeyboardKey(
              keyType: KeyType.character,
              keyData: data,
              isShifted: kbState.isShifted,
              isEngToKor: widget.isEngToKor,
              onTap: () => _onCharTap(data),
            ),
          ),
        ),
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

  /// Row 3: CAPS (flex 13) + 7개 문자 키 (flex 10) + SPACE (flex 20).
  Widget _buildRow3(KeyboardState kbState) {
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
              isEngToKor: widget.isEngToKor,
              onTap: () => _onCharTap(data),
            ),
          ),
        ),
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
