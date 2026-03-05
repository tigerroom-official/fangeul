import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/idol_group.dart';
import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/widgets/multi_mode_keyboard.dart';

/// 마이 아이돌 선택 화면.
///
/// 온보딩(첫 실행)과 설정에서 재사용한다.
/// [isOnboarding]이 true이면 스킵 버튼 표시 + 완료 시 /home으로 이동.
///
/// 그룹 선택 → 멤버명 입력(선택사항) → 확인 버튼 플로우.
/// 동남아 팬을 위해 커스텀 그룹/멤버 입력 시 [MultiModeKeyboard]를
/// 제공하여 한글 키보드가 없어도 한글 입력이 가능하다.
class IdolSelectScreen extends ConsumerStatefulWidget {
  /// Creates the [IdolSelectScreen] widget.
  const IdolSelectScreen({super.key, this.isOnboarding = false});

  /// 온보딩 모드 여부. true이면 스킵 버튼 표시.
  final bool isOnboarding;

  @override
  ConsumerState<IdolSelectScreen> createState() => _IdolSelectScreenState();
}

/// 현재 활성 입력 필드.
enum _ActiveField { custom, member }

class _IdolSelectScreenState extends ConsumerState<IdolSelectScreen> {
  String? _selectedGroupId;
  bool _isCustomInput = false;
  final _customController = TextEditingController();
  final _memberController = TextEditingController();

  final _keyboardKey = GlobalKey<MultiModeKeyboardState>();
  final _scrollController = ScrollController();
  final _customFieldKey = GlobalKey();
  final _memberFieldKey = GlobalKey();
  _ActiveField? _activeField;
  bool _showKeyboard = false;

  @override
  void initState() {
    super.initState();
    _loadExistingSelection();
  }

  @override
  void dispose() {
    _customController.dispose();
    _memberController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 기존에 저장된 그룹 ID + 멤버명을 불러와 화면에 복원한다.
  Future<void> _loadExistingSelection() async {
    final prefs = await SharedPreferences.getInstance();

    final groupId = prefs.getString('my_idol_group_id');
    if (groupId != null && mounted) {
      if (groupId.startsWith('custom:')) {
        _isCustomInput = true;
        _customController.text = groupId.substring(7);
      } else {
        _selectedGroupId = groupId;
      }
      setState(() {});
    }

    final memberName = prefs.getString(myIdolMemberPrefsKey);
    if (memberName != null && mounted) {
      _memberController.text = memberName;
    }
  }

  /// 그룹 선택 여부. 프리셋 또는 커스텀 입력 중 하나라도 활성화되면 true.
  bool get _hasGroupSelection => _selectedGroupId != null || _isCustomInput;

  /// 활성 필드의 컨트롤러 반환.
  TextEditingController? get _activeController => switch (_activeField) {
        _ActiveField.custom => _customController,
        _ActiveField.member => _memberController,
        null => null,
      };

  /// 필드 포커스 전환. 기존 필드 텍스트를 저장하고 새 필드 텍스트를 키보드에 설정.
  void _onFieldFocus(_ActiveField field) {
    if (_activeField != null && _activeField != field) {
      // 이전 필드에 현재 키보드 텍스트 저장
      _activeController?.text = _keyboardKey.currentState?.currentText ?? '';
    }
    _activeField = field;
    final text = _activeController?.text ?? '';
    // 키보드가 이미 마운트된 경우 즉시 설정
    _keyboardKey.currentState?.setText(text);
    setState(() => _showKeyboard = true);
    // 키보드가 아직 마운트 전이면 다음 프레임에서 설정 + 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardKey.currentState?.setText(text);
      _scrollToActiveField(field);
    });
  }

  /// 활성 필드가 보이도록 ListView를 자동 스크롤한다.
  void _scrollToActiveField(_ActiveField field) {
    final key = field == _ActiveField.custom ? _customFieldKey : _memberFieldKey;
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    }
  }

  /// 키보드 텍스트를 활성 필드에 라우팅.
  void _onKeyboardText(String text) {
    _activeController?.text = text;
  }

  /// 키보드 해제.
  void _dismissKeyboard() {
    if (!_showKeyboard) return;
    // flush 후 활성 필드에 최종 텍스트 저장
    _activeController?.text = _keyboardKey.currentState?.currentText ?? '';
    setState(() {
      _showKeyboard = false;
      _activeField = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final groupsAsync = ref.watch(availableGroupsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar:
          widget.isOnboarding ? null : AppBar(title: Text(l.idolSettingLabel)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isOnboarding) ...[
                const SizedBox(height: 32),
                Text(
                  l.idolSelectTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l.idolSelectSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
              Expanded(
                child: groupsAsync.when(
                  data: (groups) => _buildScrollableContent(groups, theme),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                ),
              ),
              if (_showKeyboard)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: MultiModeKeyboard(
                    key: _keyboardKey,
                    onText: _onKeyboardText,
                    onDone: _dismissKeyboard,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 그룹 목록 + 멤버 입력 + 확인/스킵 버튼을 하나의 ListView에 배치.
  ///
  /// 키보드가 올라와도 모든 콘텐츠가 스크롤 가능하다.
  Widget _buildScrollableContent(List<IdolGroup> groups, ThemeData theme) {
    return ListView(
      controller: _scrollController,
      children: [
        ...groups.map((g) => _buildGroupTile(g, theme)),
        const Divider(height: 24),
        _buildCustomInputTile(theme),
        if (_hasGroupSelection) ...[
          const SizedBox(height: 16),
          _buildMemberInput(theme),
          const SizedBox(height: 12),
          _buildConfirmButton(),
        ],
        if (widget.isOnboarding) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: _skip,
            child: Text(L.of(context).idolSelectSkip),
          ),
        ],
        // 키보드 올라왔을 때 하단 여백 — 카드 하단까지 보이도록 충분한 공간
        if (_showKeyboard) const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildGroupTile(IdolGroup group, ThemeData theme) {
    final isSelected = _selectedGroupId == group.id && !_isCustomInput;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainer,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectGroup(group.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.nameEn, style: theme.textTheme.titleMedium),
                      Text(group.nameKo, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomInputTile(ThemeData theme) {
    final l = L.of(context);
    return Padding(
      key: _customFieldKey,
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: _isCustomInput
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainer,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _isCustomInput = true;
              _selectedGroupId = null;
            });
            // 커스텀 입력 활성화 시 키보드 표시
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _onFieldFocus(_ActiveField.custom);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.idolSelectOther, style: theme.textTheme.titleMedium),
                if (_isCustomInput) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _customController,
                    readOnly: true,
                    showCursor: true,
                    decoration: InputDecoration(
                      hintText: l.idolSelectOtherHint,
                      isDense: true,
                    ),
                    onTap: () => _onFieldFocus(_ActiveField.custom),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 멤버명 입력 필드. 그룹 선택 후 하단에 표시된다.
  Widget _buildMemberInput(ThemeData theme) {
    return TextField(
      key: _memberFieldKey,
      controller: _memberController,
      readOnly: true,
      showCursor: true,
      decoration: InputDecoration(
        hintText: L.of(context).idolMemberHint,
        prefixIcon: const Icon(Icons.person_outline),
      ),
      onTap: () => _onFieldFocus(_ActiveField.member),
    );
  }

  /// 확인 버튼. 그룹(+ 선택적 멤버) 저장 후 네비게이션.
  Widget _buildConfirmButton() {
    return FilledButton(
      onPressed: _confirmSelection,
      child: Text(L.of(context).idolSelectConfirm),
    );
  }

  /// 프리셋 그룹 선택. 키보드 해제 후 하이라이트.
  void _selectGroup(String groupId) {
    _dismissKeyboard();
    setState(() {
      _selectedGroupId = groupId;
      _isCustomInput = false;
    });
  }

  /// 그룹 + 멤버명 저장 후 네비게이션.
  ///
  /// 프리셋 그룹과 커스텀 입력 모두 이 메서드로 확인한다.
  Future<void> _confirmSelection() async {
    _dismissKeyboard();

    final groupId = _isCustomInput
        ? 'custom:${_customController.text.trim()}'
        : _selectedGroupId;
    if (groupId == null) return;
    if (_isCustomInput && _customController.text.trim().isEmpty) return;

    final notifier = ref.read(myIdolNotifierProvider.notifier);
    await notifier.select(groupId);

    final memberName = _memberController.text.trim();
    if (memberName.isNotEmpty) {
      await notifier.selectMember(memberName);
    } else {
      await notifier.clearMember();
    }

    if (!mounted) return;
    if (widget.isOnboarding) {
      await _markOnboardingDone();
      if (!mounted) return;
      context.go('/home');
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _skip() async {
    _dismissKeyboard();
    await _markOnboardingDone();
    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _markOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
  }
}
