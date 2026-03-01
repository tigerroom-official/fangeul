import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/engines/keyboard_converter.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/converter_providers.dart';
import 'package:fangeul/presentation/widgets/converter_input.dart';
import 'package:fangeul/presentation/widgets/korean_keyboard.dart';

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
  late final TabController _tabController;
  final _textController = TextEditingController();

  /// 영->한 모드에서 누적된 영문 입력.
  String _engBuffer = '';

  /// 한->영/발음 모드에서 누적된 자모 리스트.
  List<String> _jamoList = [];

  static const _modes = ConvertMode.values;
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

  /// 현재 선택된 변환 모드.
  ConvertMode get _currentMode => _modes[_tabController.index];

  /// 영->한 모드 여부.
  bool get _isEngToKor => _currentMode == ConvertMode.engToKor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _modes.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // ── 탭 전환 ──

  /// 탭 전환 시 모든 버퍼와 변환 상태를 초기화한다.
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _clear();
  }

  // ── 텍스트 업데이트 ──

  /// 컨트롤러 텍스트를 갱신하고 커서를 끝으로 이동한다.
  ///
  /// `controller.text = ...` 만 하면 커서가 position 0으로 리셋되므로,
  /// 반드시 이 메서드를 통해 selection도 함께 설정한다.
  void _updateText(String text) {
    _textController.text = text;
    _textController.selection = TextSelection.collapsed(offset: text.length);
  }

  // ── 키보드 입력 핸들러 ──

  /// 문자 키 입력 처리.
  ///
  /// 영->한 모드: 영문 문자를 _engBuffer에 축적하고 controller에 표시.
  /// 한->영/발음 모드: 한글 자모를 _jamoList에 축적하고 assembleJamos로 조합하여 표시.
  void _onCharacterTap(String eng, String kor) {
    if (_isEngToKor) {
      _engBuffer += eng;
      _updateText(_engBuffer);
    } else {
      _jamoList = [..._jamoList, kor];
      _updateText(KeyboardConverter.assembleJamos(_jamoList));
    }
    _convert();
  }

  /// 백스페이스 입력 처리.
  ///
  /// 영->한 모드: _engBuffer에서 마지막 문자 제거.
  /// 한->영/발음 모드: _jamoList에서 마지막 자모 제거 후 재조합.
  void _onBackspace() {
    if (_isEngToKor) {
      if (_engBuffer.isEmpty) return;
      _engBuffer = _engBuffer.substring(0, _engBuffer.length - 1);
      _updateText(_engBuffer);
    } else {
      if (_jamoList.isEmpty) return;
      _jamoList = _jamoList.sublist(0, _jamoList.length - 1);
      _updateText(KeyboardConverter.assembleJamos(_jamoList));
    }
    _convert();
  }

  /// 스페이스바 입력 처리.
  void _onSpace() {
    if (_isEngToKor) {
      _engBuffer += ' ';
      _updateText(_engBuffer);
    } else {
      _jamoList = [..._jamoList, ' '];
      _updateText(KeyboardConverter.assembleJamos(_jamoList));
    }
    _convert();
  }

  // ── 변환 & 초기화 ──

  /// 현재 입력을 변환기에 전달한다.
  void _convert() {
    final text = _textController.text;
    if (text.isEmpty) {
      ref.read(converterNotifierProvider.notifier).clear();
    } else {
      ref.read(converterNotifierProvider.notifier).convert(text, _currentMode);
    }
  }

  /// 모든 버퍼, 컨트롤러, 변환 상태를 초기화한다.
  void _clear() {
    _engBuffer = '';
    _jamoList = [];
    _textController.clear();
    ref.read(converterNotifierProvider.notifier).clear();
  }

  // ── 빌드 ──

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(converterNotifierProvider);

    final output = switch (state) {
      ConverterInitial() => '',
      ConverterLoading() => '',
      ConverterSuccess(:final output) => output,
      ConverterError(:final message) => message,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(UiStrings.converterTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: Column(
        children: [
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
          ListenableBuilder(
            listenable: _tabController,
            builder: (context, _) => KoreanKeyboard(
              isEngToKor: _isEngToKor,
              onCharacterTap: _onCharacterTap,
              onBackspace: _onBackspace,
              onSpace: _onSpace,
            ),
          ),
        ],
      ),
    );
  }
}
