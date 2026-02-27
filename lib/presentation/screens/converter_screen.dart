import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/converter_providers.dart';
import 'package:fangeul/presentation/widgets/converter_input.dart';

/// 변환기 화면 -- 영<->한 변환 + 로마자 발음.
///
/// 3개 모드 탭: 영->한, 한->영, 발음(로마자).
/// "차분한 도구" 디자인 -- 미니멀, 인지 부하 최소.
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
  Timer? _debounce;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _modes.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    // 탭 전환 시 현재 입력으로 즉시 재변환 (디바운스 없이)
    final input = _textController.text;
    if (input.isNotEmpty) {
      ref
          .read(converterNotifierProvider.notifier)
          .convert(input, _modes[_tabController.index]);
    }
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(converterNotifierProvider.notifier)
          .convert(value, _modes[_tabController.index]);
    });
  }

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ConverterInput(
          controller: _textController,
          output: output,
          hintText: _hints[_tabController.index],
          onChanged: _onTextChanged,
        ),
      ),
    );
  }
}
