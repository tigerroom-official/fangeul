import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/engines/keyboard_converter.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/converter_providers.dart';
import 'package:fangeul/presentation/providers/copy_history_provider.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/widgets/compact_phrase_list.dart';
import 'package:fangeul/presentation/widgets/converter_input.dart';
import 'package:fangeul/presentation/widgets/korean_keyboard.dart';

/// 미니 변환기 간편/확장 모드 상태.
///
/// `true` = 간편모드(기본), `false` = 확장모드(변환기).
final miniConverterCompactProvider =
    AutoDisposeStateProvider<bool>((ref) => true);

/// 미니 변환기 팝업 화면.
///
/// FloatingBubbleService에서 버블 탭 시 열리는 Flutter Activity 화면.
/// 2단 모드: 간편모드(기본, ~25%) <-> 확장모드(변환기, ~70%).
class MiniConverterScreen extends ConsumerStatefulWidget {
  /// Creates the [MiniConverterScreen] widget.
  const MiniConverterScreen({super.key});

  @override
  ConsumerState<MiniConverterScreen> createState() =>
      _MiniConverterScreenState();
}

class _MiniConverterScreenState extends ConsumerState<MiniConverterScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _compactTabController;
  late final TabController _converterTabController;
  final _textController = TextEditingController();
  String _engBuffer = '';
  List<String> _jamoList = [];

  static const _modes = ConvertMode.values;
  static const _modeLabels = [
    UiStrings.converterTabEngToKor,
    UiStrings.converterTabKorToEng,
    UiStrings.converterTabRomanize,
  ];
  static const _modeHints = [
    UiStrings.converterHintEngToKor,
    UiStrings.converterHintKorToEng,
    UiStrings.converterHintRomanize,
  ];

  ConvertMode get _currentMode => _modes[_converterTabController.index];
  bool get _isEngToKor => _currentMode == ConvertMode.engToKor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _compactTabController = TabController(length: 2, vsync: this);
    _converterTabController = TabController(length: 3, vsync: this);
    _converterTabController.addListener(_onConverterTabChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _compactTabController.dispose();
    _converterTabController.removeListener(_onConverterTabChanged);
    _converterTabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 별도 엔진이므로 메인 앱에서 변경된 데이터를 다시 로드
      ref.invalidate(favoritePhrasesNotifierProvider);
      ref.invalidate(copyHistoryNotifierProvider);
    }
  }

  void _onConverterTabChanged() {
    if (_converterTabController.indexIsChanging) return;
    _clearConverter();
  }

  void _expandToConverter() {
    ref.read(miniConverterCompactProvider.notifier).state = false;
  }

  void _collapseToCompact() {
    _clearConverter();
    ref.read(miniConverterCompactProvider.notifier).state = true;
  }

  void _updateText(String text) {
    _textController.text = text;
    _textController.selection = TextSelection.collapsed(offset: text.length);
  }

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

  void _convert() {
    final text = _textController.text;
    if (text.isEmpty) {
      ref.read(converterNotifierProvider.notifier).clear();
    } else {
      ref.read(converterNotifierProvider.notifier).convert(text, _currentMode);
    }
  }

  void _clearConverter() {
    _engBuffer = '';
    _jamoList = [];
    _textController.clear();
    ref.read(converterNotifierProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = ref.watch(miniConverterCompactProvider);

    return Scaffold(
      backgroundColor: Colors.black54,
      body: GestureDetector(
        onTap: () => SystemNavigator.pop(),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isCompact
                  ? MediaQuery.of(context).size.height * 0.30
                  : MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: isCompact ? _buildCompactMode() : _buildExpandedMode(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactMode() {
    return Column(
      children: [
        _buildDragHandle(),
        Expanded(
          child: CompactPhraseList(
            tabController: _compactTabController,
            onCopied: () => SystemNavigator.pop(),
          ),
        ),
        _buildOpenConverterButton(),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant
              .withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildOpenConverterButton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _expandToConverter,
          icon: const Icon(Icons.search_rounded, size: 18),
          label: const Text(UiStrings.miniOpenConverter),
        ),
      ),
    );
  }

  Widget _buildExpandedMode() {
    final converterState = ref.watch(converterNotifierProvider);

    final output = switch (converterState) {
      ConverterInitial() => '',
      ConverterLoading() => '',
      ConverterSuccess(:final output) => output,
      ConverterError(:final message) => message,
    };

    return Column(
      children: [
        _buildExpandedHeader(),
        TabBar(
          controller: _converterTabController,
          tabs: _modeLabels.map((l) => Tab(text: l)).toList(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: ConverterInput(
              controller: _textController,
              output: output,
              hintText: _modeHints[_converterTabController.index],
              onClear: _clearConverter,
              onCopied: (text) {
                ref.read(copyHistoryNotifierProvider.notifier).addEntry(text);
              },
            ),
          ),
        ),
        KoreanKeyboard(
          isEngToKor: _isEngToKor,
          onCharacterTap: _onCharacterTap,
          onBackspace: _onBackspace,
          onSpace: _onSpace,
        ),
      ],
    );
  }

  Widget _buildExpandedHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: _collapseToCompact,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text(UiStrings.miniBackToCompact),
          ),
          const Spacer(),
          Text(
            UiStrings.miniConverterTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => SystemNavigator.pop(),
          ),
        ],
      ),
    );
  }
}
