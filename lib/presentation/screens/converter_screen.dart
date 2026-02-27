import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  static const _modes = ConvertMode.values;
  static const _labels = ['영->한', '한->영', '발음'];
  static const _hints = [
    '영문을 입력하세요 (예: gksrmf)',
    '한글을 입력하세요 (예: 한글)',
    '한글을 입력하세요 (예: 사랑해요)',
  ];

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

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    // 탭 전환 시 현재 입력으로 재변환
    final input = _textController.text;
    if (input.isNotEmpty) {
      ref
          .read(converterNotifierProvider.notifier)
          .convert(input, _modes[_tabController.index]);
    }
  }

  void _onTextChanged(String value) {
    ref
        .read(converterNotifierProvider.notifier)
        .convert(value, _modes[_tabController.index]);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(converterNotifierProvider);

    final output = switch (state) {
      ConverterInitial() => '',
      ConverterResult(:final output) => output,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('변환기'),
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
