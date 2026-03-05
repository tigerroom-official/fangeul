import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/engines/keyboard_converter.dart';
import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/compact_phrase_filter_provider.dart';
import 'package:fangeul/presentation/providers/converter_providers.dart';
import 'package:fangeul/presentation/providers/copy_history_provider.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/theme/fangeul_colors.dart';
import 'package:fangeul/presentation/widgets/compact_phrase_list.dart';
import 'package:fangeul/presentation/widgets/converter_input.dart';
import 'package:fangeul/presentation/widgets/korean_keyboard.dart';

/// 미니 변환기 간편/확장 모드 상태.
///
/// `true` = 간편모드(기본), `false` = 확장모드(변환기).
final miniConverterCompactProvider =
    AutoDisposeStateProvider<bool>((ref) => true);

/// 미니 컨버터 전용 Platform Channel.
///
/// [MiniConverterActivity]에서 메인 앱을 여는 메서드를 제공한다.
const _miniChannel = MethodChannel('com.tigerroom.fangeul/mini_converter');

/// 미니 변환기 팝업 화면.
///
/// FloatingBubbleService에서 버블 탭 시 열리는 Flutter Activity 화면.
/// 2단 모드: 간편모드(기본, ~43%) <-> 확장모드(변환기, ~70%).
/// 드래그 핸들: 아래로 밀어 닫기, 위로 밀어 변환기 확장.
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
  double _dragDelta = 0;

  static const _modes = ConvertMode.values;

  /// 변환 모드별 탭 레이블 목록 (context 기반 i18n).
  List<String> _modeLabels(L l) => [
        l.converterTabEngToKor,
        l.converterTabKorToEng,
        l.converterTabRomanize,
      ];

  /// 변환 모드별 힌트 텍스트 목록 (context 기반 i18n).
  List<String> _modeHints(L l) => [
        l.converterHintEngToKor,
        l.converterHintKorToEng,
        l.converterHintRomanize,
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
    _applyEdgeToEdge();
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
      // 캐시된 엔진에서는 initState가 재실행되지 않으므로
      // Activity 재생성 시마다 edge-to-edge를 다시 적용한다.
      _applyEdgeToEdge();
      _syncFromMainEngine();
    }
  }

  /// 시스템 바를 투명하게 하고 edge-to-edge 렌더링을 활성화한다.
  void _applyEdgeToEdge() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// 메인 엔진에서 변경된 SharedPreferences 데이터를 미니 엔진으로 동기화한다.
  Future<void> _syncFromMainEngine() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.reload();
    if (!mounted) return;
    ref.invalidate(favoritePhrasesNotifierProvider);
    ref.invalidate(copyHistoryNotifierProvider);
    ref.invalidate(compactPhraseFilterNotifierProvider);
    ref.invalidate(themeModeNotifierProvider);
    ref.invalidate(myIdolNotifierProvider);
    ref.invalidate(myIdolDisplayNameProvider);
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

  void _dismiss() => SystemNavigator.pop();

  Future<void> _openMainApp() async {
    try {
      await _miniChannel.invokeMethod<bool>('openMainApp');
    } on PlatformException {
      // 실패 시 무시 — MiniConverterActivity가 아닌 환경에서 호출 시.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = ref.watch(miniConverterCompactProvider);

    // FangeulApp의 AnnotatedRegion(불투명 내비바)을 오버라이드.
    // 미니 컨버터는 투명 배경 + edge-to-edge가 필수.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _dismiss,
        // 외부 영역 vertical drag 제거 — 내부 드래그 핸들과 제스처 충돌 방지
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: math.max(
                120,
                (isCompact
                        ? MediaQuery.of(context).size.height * 0.43
                        : MediaQuery.of(context).size.height * 0.70) +
                    MediaQuery.of(context).viewPadding.bottom,
              ),
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
    ),
    );
  }

  Widget _buildCompactMode() {
    return Column(
      children: [
        _buildCompactHeader(),
        Expanded(
          child: CompactPhraseList(
            tabController: _compactTabController,
            onCopied: _dismiss,
          ),
        ),
      ],
    );
  }

  /// 간편모드 상단: 드래그 핸들(틸) + `···` 오버플로 메뉴.
  ///
  /// GestureDetector가 전체 영역을 감싸서 드래그 스와이프를 처리한다.
  /// 핸들 pill은 중앙, `···` 메뉴는 우측 끝에 배치.
  Widget _buildCompactHeader() {
    return GestureDetector(
      onVerticalDragStart: (_) => _dragDelta = 0,
      onVerticalDragUpdate: (details) => _dragDelta += details.delta.dy,
      onVerticalDragEnd: (details) {
        final vy = details.velocity.pixelsPerSecond.dy;
        if (vy > 300 || _dragDelta > 50) {
          _dismiss();
        } else if (vy < -300 || _dragDelta < -50) {
          _expandToConverter();
        }
        _dragDelta = 0;
      },
      child: Container(
        key: const ValueKey('drag_handle'),
        color: Colors.transparent,
        padding: const EdgeInsets.only(top: 8, bottom: 4, left: 8, right: 4),
        child: Row(
          children: [
            const Spacer(),
            // 핸들 바 — 틸 브랜드 컬러로 미니멀 브랜딩
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: FangeulColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildOverflowMenu(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedMode() {
    final l = L.of(context);
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
          tabs: _modeLabels(l).map((label) => Tab(text: label)).toList(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: ConverterInput(
              controller: _textController,
              output: output,
              hintText: _modeHints(l)[_converterTabController.index],
              onClear: _clearConverter,
              onCopied: (text) {
                ref.read(copyHistoryNotifierProvider.notifier).addEntry(text);
              },
            ),
          ),
        ),
        ListenableBuilder(
          listenable: _converterTabController,
          builder: (context, _) => KoreanKeyboard(
            isEngToKor: _isEngToKor,
            onCharacterTap: _onCharacterTap,
            onBackspace: _onBackspace,
            onSpace: _onSpace,
          ),
        ),
      ],
    );
  }

  /// 상세모드 상단: 핸들바(틸) + `···`.
  ///
  /// 핸들 아래 드래그 → 간편모드 복귀. 간편모드 헤더와 동일 구조.
  Widget _buildExpandedHeader() {
    return GestureDetector(
      onVerticalDragStart: (_) => _dragDelta = 0,
      onVerticalDragUpdate: (details) => _dragDelta += details.delta.dy,
      onVerticalDragEnd: (details) {
        final vy = details.velocity.pixelsPerSecond.dy;
        if (vy > 300 || _dragDelta > 50) {
          _collapseToCompact();
        }
        _dragDelta = 0;
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(top: 8, bottom: 4, left: 8, right: 4),
        child: Row(
          children: [
            const Spacer(),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: FangeulColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildOverflowMenu(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// `···` 오버플로 메뉴 — 메인 앱 열기 + 팝업 숨기기.
  Widget _buildOverflowMenu() {
    final l = L.of(context);
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz_rounded,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onSelected: (value) {
        switch (value) {
          case 'open_app':
            _openMainApp();
          case 'hide_popup':
            _dismiss();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'open_app',
          child: Text(l.miniMenuOpenApp),
        ),
        PopupMenuItem(
          value: 'hide_popup',
          child: Text(l.miniMenuCloseBubble),
        ),
      ],
    );
  }
}
