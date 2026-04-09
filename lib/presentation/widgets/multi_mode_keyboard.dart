import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide KeyboardKey;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/engines/keyboard_converter.dart';
import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/keyboard_providers.dart';
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
///
/// 시스템 키보드(Gboard)와 동일한 **단일 Listener + 최근접 키 해석** 방식.
/// 키보드 전체가 하나의 터치 영역이며, 터치 좌표에서 가장 가까운 키를
/// 찾아 콜백을 발화한다. 키 사이 데드존이 존재하지 않는다.
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

/// 키 하나의 히트 영역 정보.
class _KeyHitArea {
  _KeyHitArea({
    required this.globalKey,
    required this.onTap,
    this.isBackspace = false,
  });

  /// 키 위젯에 부여된 [GlobalKey].
  final GlobalKey globalKey;

  /// 키를 탭했을 때 실행할 콜백.
  final VoidCallback onTap;

  /// 백스페이스 키 여부 (가속 삭제 판별용).
  final bool isBackspace;
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

  // ── 히트 영역 ──

  late List<_KeyHitArea> _hitAreas;

  // Korean/ABC 모드 GlobalKeys
  final _qRow1Keys = List.generate(10, (_) => GlobalKey());
  final _qRow2Keys = List.generate(9, (_) => GlobalKey());
  final _qCapsKey = GlobalKey();
  final _qRow3Keys = List.generate(7, (_) => GlobalKey());
  final _qBsKey = GlobalKey();
  final _qSpaceKey = GlobalKey();

  // 123 모드 GlobalKeys
  final _nRow1Keys = List.generate(10, (_) => GlobalKey());
  final _nRow2Keys = List.generate(8, (_) => GlobalKey());
  final _nBsKey = GlobalKey();
  final _nModeKey = GlobalKey();
  final _nSpaceKey = GlobalKey();

  // ── 이중 입력 방지 ──
  // 테스트 환경에서 DateTime.now()가 tester.pump()와 무관하게 실시간이므로
  // PointerEvent.timeStamp 기반으로 비교한다.

  Duration _lastPointerDownTs = Duration.zero;
  static const _minInterval = Duration(milliseconds: 40);

  // ── 백스페이스 가속 삭제 ──

  Timer? _deleteTimer;
  bool _isAccelerated = false;
  bool _isDisposed = false;
  DateTime? _longPressStart;
  bool _bsActive = false;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    _mode = widget.initialMode;
    _hitAreas = _buildHitAreas();
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

  // ── 히트 영역 빌드 ──

  /// 현재 모드에 맞는 히트 영역을 구성한다.
  List<_KeyHitArea> _buildHitAreas() {
    return switch (_mode) {
      InputMode.korean => _buildQwertyHitAreas(isEngToKor: false),
      InputMode.abc => _buildQwertyHitAreas(isEngToKor: true),
      InputMode.numbers => _buildNumberHitAreas(),
    };
  }

  List<_KeyHitArea> _buildQwertyHitAreas({required bool isEngToKor}) {
    final onChar = isEngToKor ? _onAbcChar : _onKoreanChar;
    final areas = <_KeyHitArea>[];

    for (var i = 0; i < _row1.length; i++) {
      areas.add(_KeyHitArea(
        globalKey: _qRow1Keys[i],
        onTap: () => onChar(_row1[i]),
      ));
    }
    for (var i = 0; i < _row2.length; i++) {
      areas.add(_KeyHitArea(
        globalKey: _qRow2Keys[i],
        onTap: () => onChar(_row2[i]),
      ));
    }
    areas.add(_KeyHitArea(
      globalKey: _qBsKey,
      onTap: _onBackspace,
      isBackspace: true,
    ));
    areas.add(_KeyHitArea(
      globalKey: _qCapsKey,
      onTap: () => ref.read(keyboardNotifierProvider.notifier).toggleCaps(),
    ));
    for (var i = 0; i < _row3.length; i++) {
      areas.add(_KeyHitArea(
        globalKey: _qRow3Keys[i],
        onTap: () => onChar(_row3[i]),
      ));
    }
    areas.add(_KeyHitArea(
      globalKey: _qSpaceKey,
      onTap: _onSpace,
    ));
    return areas;
  }

  List<_KeyHitArea> _buildNumberHitAreas() {
    final areas = <_KeyHitArea>[];
    for (var i = 0; i < _numRow1.length; i++) {
      areas.add(_KeyHitArea(
        globalKey: _nRow1Keys[i],
        onTap: () => _onNumChar(_numRow1[i]),
      ));
    }
    for (var i = 0; i < _numRow2.length; i++) {
      areas.add(_KeyHitArea(
        globalKey: _nRow2Keys[i],
        onTap: () => _onNumChar(_numRow2[i]),
      ));
    }
    areas.add(_KeyHitArea(
      globalKey: _nBsKey,
      onTap: _onBackspace,
      isBackspace: true,
    ));
    areas.add(_KeyHitArea(
      globalKey: _nModeKey,
      onTap: () => _switchMode(InputMode.abc),
    ));
    areas.add(_KeyHitArea(
      globalKey: _nSpaceKey,
      onTap: _onSpace,
    ));
    return areas;
  }

  // ── 최근접 키 해석 ──

  _KeyHitArea? _findNearest(Offset globalPos) {
    _KeyHitArea? nearest;
    double minDist = double.infinity;

    for (final area in _hitAreas) {
      final box =
          area.globalKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final topLeft = box.localToGlobal(Offset.zero);
      final rect = topLeft & box.size;

      if (rect.contains(globalPos)) return area;

      final dist = (rect.center - globalPos).distanceSquared;
      if (dist < minDist) {
        minDist = dist;
        nearest = area;
      }
    }
    return nearest;
  }

  // ── 포인터 이벤트 ──

  void _onPointerDown(PointerDownEvent event) {
    if (event.timeStamp - _lastPointerDownTs < _minInterval) return;
    _lastPointerDownTs = event.timeStamp;

    final area = _findNearest(event.position);
    if (area == null) return;

    HapticFeedback.lightImpact();
    area.onTap();

    if (area.isBackspace) {
      _bsActive = true;
      _longPressStart = DateTime.now();
      _isAccelerated = false;
      _deleteTimer = Timer(const Duration(milliseconds: 300), () {
        if (_isDisposed || !_bsActive) return;
        _deleteTimer = Timer.periodic(
          const Duration(milliseconds: 70),
          (timer) {
            if (_isDisposed || !_bsActive) {
              timer.cancel();
              return;
            }
            _onBackspace();
            final elapsed = DateTime.now().difference(_longPressStart!);
            if (!_isAccelerated && elapsed.inMilliseconds > 800) {
              _isAccelerated = true;
              HapticFeedback.heavyImpact();
              timer.cancel();
              if (_isDisposed) return;
              _deleteTimer = Timer.periodic(
                const Duration(milliseconds: 35),
                (t) {
                  if (_isDisposed || !_bsActive) {
                    t.cancel();
                    return;
                  }
                  _onBackspace();
                },
              );
            }
          },
        );
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) => _cancelBackspace();

  void _onPointerCancel(PointerCancelEvent event) => _cancelBackspace();

  void _cancelBackspace() {
    _deleteTimer?.cancel();
    _deleteTimer = null;
    _isAccelerated = false;
    _longPressStart = null;
    _bsActive = false;
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
      _hitAreas = _buildHitAreas();
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
    if (_mode == InputMode.korean &&
        _jamoList.isEmpty &&
        _committedText.isEmpty) {
      return;
    }
    if (_mode != InputMode.korean && _committedText.isEmpty) {
      return;
    }
    setState(() {
      if (_mode == InputMode.korean && _jamoList.isNotEmpty) {
        _jamoList = _jamoList.sublist(0, _jamoList.length - 1);
      } else if (_committedText.isNotEmpty) {
        _committedText = _committedText.substring(0, _committedText.length - 1);
      }
    });
    _emitText();
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final kbState = ref.watch(keyboardNotifierProvider);
    final theme = Theme.of(context);
    final bgColor = theme.colorScheme.surfaceContainerLowest;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolbar(theme),
          const SizedBox(height: 4),
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _onPointerDown,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            child: AbsorbPointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildKeyRows(kbState),
              ),
            ),
          ),
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
              segments: [
                ButtonSegment(
                  value: InputMode.korean,
                  label: Text(L.of(context).keyboardModeKorean),
                ),
                ButtonSegment(
                  value: InputMode.abc,
                  label: Text(L.of(context).keyboardModeAbc),
                ),
                ButtonSegment(
                  value: InputMode.numbers,
                  label: Text(L.of(context).keyboardModeNumbers),
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
            child: Text(L.of(context).keyboardDone),
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
    return [
      _buildCharRow(_row1, kbState, _qRow1Keys, isEngToKor: isEngToKor),
      const SizedBox(height: 4),
      _buildCharRow2(kbState, isEngToKor: isEngToKor),
      const SizedBox(height: 4),
      _buildCharRow3(kbState, isEngToKor: isEngToKor),
    ];
  }

  /// Row 1: 10개 문자 키.
  Widget _buildCharRow(
    List<KeyData> keys,
    KeyboardState kbState,
    List<GlobalKey> gks, {
    required bool isEngToKor,
  }) {
    return Row(
      children: [
        for (var i = 0; i < keys.length; i++)
          Expanded(
            child: KeyboardKey(
              key: gks[i],
              keyType: KeyType.character,
              keyData: keys[i],
              isShifted: kbState.isShifted,
              isEngToKor: isEngToKor,
            ),
          ),
      ],
    );
  }

  /// Row 2: 9개 문자 키 + DEL 키.
  Widget _buildCharRow2(
    KeyboardState kbState, {
    required bool isEngToKor,
  }) {
    return Row(
      children: [
        for (var i = 0; i < _row2.length; i++)
          Expanded(
            child: KeyboardKey(
              key: _qRow2Keys[i],
              keyType: KeyType.character,
              keyData: _row2[i],
              isShifted: kbState.isShifted,
              isEngToKor: isEngToKor,
            ),
          ),
        Expanded(
          child: _BackspaceKeyVisual(key: _qBsKey),
        ),
      ],
    );
  }

  /// Row 3: CAPS + 7개 문자 키 + SPACE.
  Widget _buildCharRow3(
    KeyboardState kbState, {
    required bool isEngToKor,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 13,
          child: KeyboardKey(
            key: _qCapsKey,
            keyType: KeyType.caps,
            isShifted: kbState.isShifted,
            isCapsLocked: kbState.capsMode == CapsMode.locked,
          ),
        ),
        for (var i = 0; i < _row3.length; i++)
          Expanded(
            flex: 10,
            child: KeyboardKey(
              key: _qRow3Keys[i],
              keyType: KeyType.character,
              keyData: _row3[i],
              isShifted: kbState.isShifted,
              isEngToKor: isEngToKor,
            ),
          ),
        Expanded(
          flex: 20,
          child: KeyboardKey(key: _qSpaceKey, keyType: KeyType.space),
        ),
      ],
    );
  }

  // ── 123 모드 ──

  List<Widget> _buildNumberRows() {
    return [
      _buildSimpleRow(_numRow1, _nRow1Keys),
      const SizedBox(height: 4),
      _buildNumRow2(),
      const SizedBox(height: 4),
      _buildNumRow3(),
    ];
  }

  Widget _buildSimpleRow(List<String> chars, List<GlobalKey> gks) {
    return Row(
      children: [
        for (var i = 0; i < chars.length; i++)
          Expanded(child: _SimpleKeyVisual(key: gks[i], label: chars[i])),
      ],
    );
  }

  Widget _buildNumRow2() {
    return Row(
      children: [
        for (var i = 0; i < _numRow2.length; i++)
          Expanded(
            child: _SimpleKeyVisual(key: _nRow2Keys[i], label: _numRow2[i]),
          ),
        Expanded(
          child: _BackspaceKeyVisual(key: _nBsKey),
        ),
      ],
    );
  }

  Widget _buildNumRow3() {
    return Row(
      children: [
        Expanded(
          flex: 13,
          child: _ModeButtonVisual(
            key: _nModeKey,
            label: L.of(context).keyboardModeAbc,
          ),
        ),
        Expanded(
          flex: 70,
          child: KeyboardKey(key: _nSpaceKey, keyType: KeyType.space),
        ),
      ],
    );
  }
}

/// 단일 라벨 키 (123 모드용, 순수 렌더링).
class _SimpleKeyVisual extends StatelessWidget {
  const _SimpleKeyVisual({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = colorScheme.surfaceContainerHigh;
    final textColor = colorScheme.onSurface;

    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
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
    );
  }
}

/// 모드 전환 버튼 (123 모드의 ABC 전환, 순수 렌더링).
class _ModeButtonVisual extends StatelessWidget {
  const _ModeButtonVisual({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = colorScheme.surfaceContainerHigh;
    final textColor = colorScheme.onSurfaceVariant;

    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
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
    );
  }
}

/// 백스페이스 키 (순수 렌더링).
class _BackspaceKeyVisual extends StatelessWidget {
  const _BackspaceKeyVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(Icons.backspace_outlined,
                size: 20, color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
