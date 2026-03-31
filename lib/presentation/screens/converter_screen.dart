import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/engines/hangul_engine.dart';
import 'package:fangeul/core/engines/hangul_tables.dart';
import 'package:fangeul/core/engines/keyboard_converter.dart';
import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/converter_providers.dart';
import 'package:fangeul/presentation/widgets/converter_input.dart';
import 'package:fangeul/presentation/widgets/korean_keyboard.dart';
import 'package:fangeul/presentation/widgets/shell_scaffold.dart';

/// 변환기 화면 -- 커스텀 한글 키보드 통합.
///
/// 3개 모드 탭: 영->한, 한->영, 발음(로마자).
/// 시스템 키보드 대신 [KoreanKeyboard]로 문자를 입력받는다.
/// 영->한 모드: 영문 버퍼(_engBuffer)를 축적 후 KeyboardConverter.engToKor로 변환.
/// 한->영/발음 모드: 자모 리스트(_jamoList)를 축적 후 assembleJamos로 조합.
class ConverterScreen extends ConsumerStatefulWidget {
  /// Creates the [ConverterScreen] widget.
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen>
    with SingleTickerProviderStateMixin {
  static const _tabPrefsKey = 'converter_tab_index';

  late final TabController _tabController;
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _convertDebounce;

  /// 영->한 모드에서 누적된 영문 입력.
  String _engBuffer = '';

  /// 한->영/발음 모드에서 누적된 자모 리스트.
  List<String> _jamoList = [];

  static const _modes = ConvertMode.values;

  /// 각 변환 모드의 예시 입력/출력.
  static const _examples = [
    ('gksrmf', '한글'),
    ('한글', 'gksrmf'),
    ('사랑해요', 'saranghaeyo'),
  ];

  /// 변환 모드별 탭 레이블 목록 (context 기반 i18n).
  List<String> _labels(L l) => [
        l.converterTabEngToKor,
        l.converterTabKorToEng,
        l.converterTabRomanize,
      ];

  /// 변환 모드별 힌트 텍스트 목록 (context 기반 i18n).
  List<String> _hints(L l) => [
        l.converterHintEngToKor,
        l.converterHintKorToEng,
        l.converterHintRomanize,
      ];

  /// 현재 선택된 변환 모드.
  ConvertMode get _currentMode => _modes[_tabController.index];

  /// 영->한 모드 여부.
  bool get _isEngToKor => _currentMode == ConvertMode.engToKor;

  /// 사용자가 탭을 직접 전환했는지 여부. async 복원이 사용자 선택을 덮어쓰는 것을 방지.
  bool _userChangedTab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _modes.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _restoreSavedTab();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_focusNode.hasFocus) _focusNode.requestFocus();
    });
  }

  /// SharedPreferences에서 저장된 탭 인덱스를 복원한다.
  Future<void> _restoreSavedTab() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(_tabPrefsKey);
      if (saved != null &&
          saved >= 0 &&
          saved < _modes.length &&
          mounted &&
          !_userChangedTab) {
        _tabController.animateTo(saved);
      }
    } catch (e) {
      debugPrint('Failed to restore tab preference: $e');
    }
  }

  /// 현재 탭 인덱스를 SharedPreferences에 저장한다.
  Future<void> _saveTab(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_tabPrefsKey, index);
    } catch (e) {
      debugPrint('Failed to save tab preference: $e');
    }
  }

  @override
  void dispose() {
    _convertDebounce?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  // ── 탭 전환 ──

  /// 탭 전환 시 모든 버퍼와 변환 상태를 초기화하고, 선택을 저장한다.
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _userChangedTab = true;
    _clear();
    _saveTab(_tabController.index);
  }

  // ── 텍스트 업데이트 ──

  /// 컨트롤러 텍스트를 갱신하고 커서를 끝으로 이동한다.
  ///
  /// `controller.value` 단일 할당으로 리스너 알림을 1회로 줄인다.
  /// `.text` + `.selection` 개별 설정 시 2회 알림이 발생하여 리빌드가 2배.
  void _updateText(String text) {
    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  // ── 커서 위치 ──

  /// 현재 커서 위치를 반환한다. 유효하지 않으면 버퍼 끝.
  int get _cursorPos {
    final sel = _textController.selection;
    if (!sel.isValid || sel.baseOffset < 0) return _engBuffer.length;
    return sel.baseOffset.clamp(0, _engBuffer.length);
  }

  /// _engBuffer의 커서 위치에 [char]를 삽입하고 커서를 진행한다.
  void _insertAtCursor(String char) {
    final pos = _cursorPos;
    _engBuffer =
        _engBuffer.substring(0, pos) + char + _engBuffer.substring(pos);
    _textController.value = TextEditingValue(
      text: _engBuffer,
      selection: TextSelection.collapsed(offset: pos + char.length),
    );
  }

  /// _engBuffer의 커서 앞 1글자를 삭제하고 커서를 후퇴한다.
  void _deleteAtCursor() {
    final pos = _cursorPos;
    if (pos <= 0 || _engBuffer.isEmpty) return;
    _engBuffer =
        _engBuffer.substring(0, pos - 1) + _engBuffer.substring(pos);
    _textController.value = TextEditingValue(
      text: _engBuffer,
      selection: TextSelection.collapsed(offset: pos - 1),
    );
  }

  // ── 키보드 입력 핸들러 ──

  /// 커서가 텍스트 끝에 있는지 여부.
  bool get _isCursorAtEnd {
    final sel = _textController.selection;
    if (!sel.isValid || sel.baseOffset < 0) return true;
    return sel.baseOffset >= _textController.text.length;
  }

  /// 한→영/발음 모드에서 커서가 중간이면 자모 조합을 커밋하고
  /// 표시 텍스트 기반 편집으로 전환한다.
  void _commitJamoIfMidCursor() {
    if (_jamoList.isNotEmpty) {
      _engBuffer = _textController.text;
      _jamoList = [];
    }
  }

  /// 문자 키 입력 처리.
  ///
  /// 커서가 끝이면 기존 버퍼 로직(자모 조합 포함).
  /// 커서가 중간이면 표시 텍스트에 직접 삽입.
  void _onCharacterTap(String eng, String kor) {
    if (_isEngToKor) {
      _insertAtCursor(eng);
    } else if (_isCursorAtEnd && _engBuffer.isEmpty) {
      _jamoList.add(kor);
      _updateText(KeyboardConverter.assembleJamos(_jamoList));
    } else {
      _commitJamoIfMidCursor();
      _insertAtCursor(kor);
    }
    _convert();
  }

  /// 백스페이스 입력 처리.
  void _onBackspace() {
    if (_isEngToKor) {
      _deleteAtCursor();
    } else if (_isCursorAtEnd && _engBuffer.isEmpty && _jamoList.isNotEmpty) {
      _jamoList.removeLast();
      _updateText(KeyboardConverter.assembleJamos(_jamoList));
    } else {
      _commitJamoIfMidCursor();
      _deleteAtCursor();
    }
    _convert();
  }

  /// 숫자/특수문자 입력 처리.
  void _onSymbolTap(String char) {
    if (_isEngToKor) {
      _insertAtCursor(char);
    } else if (_isCursorAtEnd && _engBuffer.isEmpty) {
      _jamoList.add(char);
      _updateText(KeyboardConverter.assembleJamos(_jamoList));
    } else {
      _commitJamoIfMidCursor();
      _insertAtCursor(char);
    }
    _convert();
  }

  /// 스페이스바 입력 처리.
  void _onSpace() {
    if (_isEngToKor) {
      _insertAtCursor(' ');
    } else if (_isCursorAtEnd && _engBuffer.isEmpty) {
      _jamoList.add(' ');
      _updateText(KeyboardConverter.assembleJamos(_jamoList));
    } else {
      _commitJamoIfMidCursor();
      _insertAtCursor(' ');
    }
    _convert();
  }

  // ── 붙여넣기 ──

  /// 클립보드 텍스트를 현재 모드의 버퍼에 붙여넣는다.
  Future<void> _onPaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    if (!mounted) return;

    if (_isEngToKor) {
      _engBuffer = text;
      _updateText(_engBuffer);
    } else {
      _jamoList = _decomposeToJamoList(text);
      _updateText(KeyboardConverter.assembleJamos(_jamoList));
    }
    _convert();
  }

  /// 한글 텍스트를 키보드 단위 자모 리스트로 분해한다 (붙여넣기용).
  ///
  /// 복합모음(ㅘ→ㅗ+ㅏ)과 겹받침(ㄳ→ㄱ+ㅅ)을 키보드 입력 단위로
  /// 분리하여, 붙여넣기 후 backspace가 키 단위로 동작하도록 한다.
  static List<String> _decomposeToJamoList(String text) {
    final result = <String>[];
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (HangulEngine.isSyllable(rune)) {
        final jamos = HangulEngine.decompose(char);
        for (final jamo in jamos) {
          // 초성: 단일 자음이므로 그대로
          result.add(jamo.initial);
          // 중성: 복합모음이면 분리
          final vowelSplit =
              HangulTables.compoundVowelSplit[jamo.medial];
          if (vowelSplit != null) {
            result.addAll(vowelSplit);
          } else {
            result.add(jamo.medial);
          }
          // 종성: 겹받침이면 분리
          if (jamo.final_.isNotEmpty) {
            final finalSplit =
                HangulTables.doubleFinalSplit[jamo.final_];
            if (finalSplit != null) {
              result.addAll(finalSplit);
            } else {
              result.add(jamo.final_);
            }
          }
        }
      } else {
        result.add(char);
      }
    }
    return result;
  }

  // ── 변환 & 초기화 ──

  /// 현재 입력을 변환기에 전달한다.
  ///
  /// 150ms 디바운스 적용 — 빠른 타이핑 시 중간 변환을 건너뛰어
  /// UI 리빌드 부하를 줄인다. 입력 텍스트 표시는 즉시, 변환 결과만 지연.
  void _convert() {
    _convertDebounce?.cancel();
    final text = _textController.text;
    if (text.isEmpty) {
      ref.read(converterNotifierProvider.notifier).clear();
      return;
    }
    _convertDebounce = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      ref.read(converterNotifierProvider.notifier).convert(text, _currentMode);
    });
  }

  /// 모든 버퍼, 컨트롤러, 변환 상태를 초기화한다.
  void _clear() {
    _engBuffer = '';
    _jamoList = [];
    _textController.clear();
    ref.read(converterNotifierProvider.notifier).clear();
  }

  // ── 빌드 ──

  /// 하단 네비게이션에서 Key Swap 탭(인덱스 1)으로 전환 시 텍스트 필드에 포커스.
  static const _converterTabIndex = 1;

  @override
  Widget build(BuildContext context) {
    // IndexedStack은 탭 전환 시 initState를 재호출하지 않으므로
    // provider 변경을 listen하여 탭 진입 시 포커스를 부여한다.
    ref.listen(activeShellTabProvider, (prev, next) {
      if (next == _converterTabIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_focusNode.hasFocus) _focusNode.requestFocus();
        });
      }
    });

    final l = L.of(context);
    final state = ref.watch(converterNotifierProvider);

    final output = switch (state) {
      ConverterInitial() => '',
      ConverterLoading() => '',
      ConverterSuccess(:final output) => output,
      ConverterError(:final message) => message,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l.converterTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: _labels(l).map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _tabController,
              builder: (context, _) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConverterInput(
                  controller: _textController,
                  focusNode: _focusNode,
                  output: output,
                  hintText: _hints(l)[_tabController.index],
                  onClear: _clear,
                  onPaste: _onPaste,
                  exampleInput: _examples[_tabController.index].$1,
                  exampleOutput: _examples[_tabController.index].$2,
                ),
              ),
            ),
          ),
          ListenableBuilder(
            listenable: _tabController,
            builder: (context, _) => KoreanKeyboard(
              isEngToKor: _isEngToKor,
              onCharacterTap: _onCharacterTap,
              onSymbolTap: _onSymbolTap,
              onBackspace: _onBackspace,
              onSpace: _onSpace,
            ),
          ),
        ],
      ),
    );
  }
}
