import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide KeyboardKey;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/providers/keyboard_providers.dart';
import 'package:fangeul/presentation/widgets/keyboard_key.dart';

/// QWERTY 두벌식 한글 키보드 위젯.
///
/// 시스템 키보드(Gboard)와 동일한 **단일 Listener + 최근접 키 해석** 방식.
/// 키보드 전체가 하나의 터치 영역이며, 터치 좌표에서 가장 가까운 키를
/// 찾아 콜백을 발화한다. 키 사이 데드존이 존재하지 않는다.
///
/// 숫자/특수문자 토글 모드를 지원한다. Row 4 좌측의 [!#1] 버튼으로
/// 문자↔숫자/특수문자 모드를 전환한다.
class KoreanKeyboard extends ConsumerStatefulWidget {
  /// [KoreanKeyboard]를 생성한다.
  const KoreanKeyboard({
    required this.isEngToKor,
    required this.onCharacterTap,
    required this.onSymbolTap,
    required this.onBackspace,
    required this.onSpace,
    super.key,
  });

  /// 영->한 모드 여부.
  final bool isEngToKor;

  /// 문자 키 탭 콜백. 영문과 한글을 함께 전달.
  final void Function(String eng, String kor) onCharacterTap;

  /// 숫자/특수문자 탭 콜백. 문자를 직접 전달.
  final void Function(String char) onSymbolTap;

  /// 백스페이스 콜백.
  final VoidCallback onBackspace;

  /// 스페이스바 콜백.
  final VoidCallback onSpace;

  @override
  ConsumerState<KoreanKeyboard> createState() => _KoreanKeyboardState();
}

/// 키 하나의 히트 영역 정보.
class _KeyHitArea {
  _KeyHitArea({
    required this.globalKey,
    required this.onTap,
    this.isBackspace = false,
  });

  final GlobalKey globalKey;
  final VoidCallback onTap;
  final bool isBackspace;
}

class _KoreanKeyboardState extends ConsumerState<KoreanKeyboard> {
  // ── 문자 모드 Row 데이터 ──

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

  // ── 숫자/특수문자 모드 Row 데이터 ──

  static const _numRow1 = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  static const _numRow2 = ['@', '#', '\$', '%', '&', '-', '+', '(', ')'];
  static const _numRow3 = ['!', '"', "'", ':', ';', '/', '?'];

  // ── 상태 ──

  bool _isNumberMode = false;

  // ── 히트 영역 ──

  late List<_KeyHitArea> _hitAreas;
  // 문자 모드 GlobalKeys
  final _row1Keys = List.generate(10, (_) => GlobalKey());
  final _row2Keys = List.generate(9, (_) => GlobalKey());
  final _capsKey = GlobalKey();
  final _row3Keys = List.generate(7, (_) => GlobalKey());
  final _bsKey = GlobalKey();
  final _spaceKey = GlobalKey();
  final _toggleKey = GlobalKey();
  // 숫자 모드 GlobalKeys
  final _numRow1Keys = List.generate(10, (_) => GlobalKey());
  final _numRow2Keys = List.generate(9, (_) => GlobalKey());
  final _numRow3Keys = List.generate(7, (_) => GlobalKey());
  final _numBsKey = GlobalKey();
  final _numSpaceKey = GlobalKey();
  final _numToggleKey = GlobalKey();

  // ── 이중 입력 방지 ──

  DateTime _lastPointerDown = DateTime(0);
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
    _hitAreas = _buildHitAreas();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _deleteTimer?.cancel();
    super.dispose();
  }

  /// 현재 모드에 맞는 히트 영역을 구성한다.
  List<_KeyHitArea> _buildHitAreas() {
    if (_isNumberMode) return _buildNumberHitAreas();
    return _buildCharHitAreas();
  }

  List<_KeyHitArea> _buildCharHitAreas() {
    final areas = <_KeyHitArea>[];
    for (var i = 0; i < _row1.length; i++) {
      areas.add(_KeyHitArea(
          globalKey: _row1Keys[i], onTap: () => _onCharTap(_row1[i])));
    }
    for (var i = 0; i < _row2.length; i++) {
      areas.add(_KeyHitArea(
          globalKey: _row2Keys[i], onTap: () => _onCharTap(_row2[i])));
    }
    areas.add(_KeyHitArea(
      globalKey: _capsKey,
      onTap: () => ref.read(keyboardNotifierProvider.notifier).toggleCaps(),
    ));
    for (var i = 0; i < _row3.length; i++) {
      areas.add(_KeyHitArea(
          globalKey: _row3Keys[i], onTap: () => _onCharTap(_row3[i])));
    }
    areas.add(_KeyHitArea(
        globalKey: _bsKey, onTap: widget.onBackspace, isBackspace: true));
    areas.add(_KeyHitArea(globalKey: _toggleKey, onTap: _toggleMode));
    areas.add(_KeyHitArea(globalKey: _spaceKey, onTap: widget.onSpace));
    return areas;
  }

  List<_KeyHitArea> _buildNumberHitAreas() {
    final areas = <_KeyHitArea>[];
    for (var i = 0; i < _numRow1.length; i++) {
      areas.add(_KeyHitArea(
          globalKey: _numRow1Keys[i],
          onTap: () => widget.onSymbolTap(_numRow1[i])));
    }
    for (var i = 0; i < _numRow2.length; i++) {
      areas.add(_KeyHitArea(
          globalKey: _numRow2Keys[i],
          onTap: () => widget.onSymbolTap(_numRow2[i])));
    }
    for (var i = 0; i < _numRow3.length; i++) {
      areas.add(_KeyHitArea(
          globalKey: _numRow3Keys[i],
          onTap: () => widget.onSymbolTap(_numRow3[i])));
    }
    areas.add(_KeyHitArea(
        globalKey: _numBsKey, onTap: widget.onBackspace, isBackspace: true));
    areas.add(_KeyHitArea(globalKey: _numToggleKey, onTap: _toggleMode));
    areas.add(_KeyHitArea(globalKey: _numSpaceKey, onTap: widget.onSpace));
    return areas;
  }

  void _toggleMode() {
    setState(() {
      _isNumberMode = !_isNumberMode;
      _hitAreas = _buildHitAreas();
    });
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
    final now = DateTime.now();
    if (now.difference(_lastPointerDown) < _minInterval) return;
    _lastPointerDown = now;

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
            widget.onBackspace();
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
                  widget.onBackspace();
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

  // ── 문자 키 탭 ──

  void _onCharTap(KeyData data) {
    final kbState = ref.read(keyboardNotifierProvider);
    final shifted = kbState.isShifted;

    final eng = shifted ? data.eng.toUpperCase() : data.eng;
    final kor = shifted && data.korShift != null ? data.korShift! : data.kor;

    widget.onCharacterTap(eng, kor);
    ref.read(keyboardNotifierProvider.notifier).consumeOneShot();
  }

  // ── 빌드 ──

  @override
  Widget build(BuildContext context) {
    final kbState = ref.watch(keyboardNotifierProvider);
    final bgColor = Theme.of(context).colorScheme.surfaceContainerLowest;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return RepaintBoundary(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: AbsorbPointer(
          child: Container(
            color: bgColor,
            padding: EdgeInsets.only(
                left: 4, right: 4, top: 8, bottom: 8 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _isNumberMode
                  ? _buildNumberRows()
                  : _buildCharRows(kbState),
            ),
          ),
        ),
      ),
    );
  }

  // ── 문자 모드 Rows ──

  List<Widget> _buildCharRows(KeyboardState kbState) {
    return [
      _buildCharRow(_row1, kbState, _row1Keys),
      _buildCharRow2(kbState),
      _buildCharRow3(kbState),
      _buildRow4(),
    ];
  }

  Widget _buildCharRow(
      List<KeyData> keys, KeyboardState kbState, List<GlobalKey> gks) {
    return Row(
      children: [
        for (var i = 0; i < keys.length; i++)
          Expanded(
            child: KeyboardKey(
              key: gks[i],
              keyType: KeyType.character,
              keyData: keys[i],
              isShifted: kbState.isShifted,
              isEngToKor: widget.isEngToKor,
            ),
          ),
      ],
    );
  }

  Widget _buildCharRow2(KeyboardState kbState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < _row2.length; i++)
            Expanded(
              child: KeyboardKey(
                key: _row2Keys[i],
                keyType: KeyType.character,
                keyData: _row2[i],
                isShifted: kbState.isShifted,
                isEngToKor: widget.isEngToKor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCharRow3(KeyboardState kbState) {
    return Row(
      children: [
        Expanded(
          flex: 15,
          child: KeyboardKey(
            key: _capsKey,
            keyType: KeyType.caps,
            isShifted: kbState.isShifted,
            isCapsLocked: kbState.capsMode == CapsMode.locked,
          ),
        ),
        for (var i = 0; i < _row3.length; i++)
          Expanded(
            flex: 10,
            child: KeyboardKey(
              key: _row3Keys[i],
              keyType: KeyType.character,
              keyData: _row3[i],
              isShifted: kbState.isShifted,
              isEngToKor: widget.isEngToKor,
            ),
          ),
        Expanded(
          flex: 15,
          child: KeyboardKey(key: _bsKey, keyType: KeyType.backspace),
        ),
      ],
    );
  }

  // ── 숫자/특수문자 모드 Rows ──

  List<Widget> _buildNumberRows() {
    return [
      _buildSymRow(_numRow1, _numRow1Keys),
      _buildSymRow2(),
      _buildSymRow3(),
      _buildRow4(),
    ];
  }

  Widget _buildSymRow(List<String> chars, List<GlobalKey> gks) {
    return Row(
      children: [
        for (var i = 0; i < chars.length; i++)
          Expanded(child: _SymbolKey(key: gks[i], label: chars[i])),
      ],
    );
  }

  Widget _buildSymRow2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < _numRow2.length; i++)
            Expanded(child: _SymbolKey(key: _numRow2Keys[i], label: _numRow2[i])),
        ],
      ),
    );
  }

  Widget _buildSymRow3() {
    return Row(
      children: [
        // 좌측 여백 (Caps 위치와 동일)
        const Expanded(flex: 15, child: SizedBox(height: 52)),
        for (var i = 0; i < _numRow3.length; i++)
          Expanded(
            flex: 10,
            child: _SymbolKey(key: _numRow3Keys[i], label: _numRow3[i]),
          ),
        Expanded(
          flex: 15,
          child: KeyboardKey(key: _numBsKey, keyType: KeyType.backspace),
        ),
      ],
    );
  }

  // ── 공통 Row 4: 토글 + 스페이스 ──

  Widget _buildRow4() {
    final toggleGk = _isNumberMode ? _numToggleKey : _toggleKey;
    final spaceGk = _isNumberMode ? _numSpaceKey : _spaceKey;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _ToggleKey(
            key: toggleGk,
            label: _isNumberMode ? 'ABC' : '!#1',
            isActive: _isNumberMode,
          ),
        ),
        Expanded(
          flex: 6,
          child: KeyboardKey(key: spaceGk, keyType: KeyType.space),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

// ── 숫자/특수문자 키 (순수 렌더링) ──

class _SymbolKey extends StatelessWidget {
  const _SymbolKey({required this.label, super.key});

  final String label;

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
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 토글 키 (순수 렌더링) ──

class _ToggleKey extends StatelessWidget {
  const _ToggleKey({
    required this.label,
    required this.isActive,
    super.key,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isActive ? cs.primaryContainer : cs.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
