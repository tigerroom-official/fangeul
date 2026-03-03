import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/idol_group.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';

/// 마이 아이돌 선택 화면.
///
/// 온보딩(첫 실행)과 설정에서 재사용한다.
/// [isOnboarding]이 true이면 스킵 버튼 표시 + 완료 시 /home으로 이동.
///
/// 그룹 선택 → 멤버명 입력(선택사항) → 확인 버튼 플로우.
class IdolSelectScreen extends ConsumerStatefulWidget {
  /// Creates the [IdolSelectScreen] widget.
  const IdolSelectScreen({super.key, this.isOnboarding = false});

  /// 온보딩 모드 여부. true이면 스킵 버튼 표시.
  final bool isOnboarding;

  @override
  ConsumerState<IdolSelectScreen> createState() => _IdolSelectScreenState();
}

class _IdolSelectScreenState extends ConsumerState<IdolSelectScreen> {
  String? _selectedGroupId;
  bool _isCustomInput = false;
  final _customController = TextEditingController();
  final _memberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingMember();
  }

  @override
  void dispose() {
    _customController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  /// 기존에 저장된 멤버명을 불러와 TextField에 표시한다.
  Future<void> _loadExistingMember() async {
    final prefs = await SharedPreferences.getInstance();
    final memberName = prefs.getString('my_idol_member_name');
    if (memberName != null && mounted) {
      _memberController.text = memberName;
    }
  }

  /// 그룹 선택 여부. 프리셋 또는 커스텀 입력 중 하나라도 활성화되면 true.
  bool get _hasGroupSelection => _selectedGroupId != null || _isCustomInput;

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(availableGroupsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.isOnboarding
          ? null
          : AppBar(title: const Text(UiStrings.idolSettingLabel)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isOnboarding) ...[
                const SizedBox(height: 32),
                Text(
                  UiStrings.idolSelectTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  UiStrings.idolSelectSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
              Expanded(
                child: groupsAsync.when(
                  data: (groups) => _buildGroupList(groups, theme),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                ),
              ),
              if (_hasGroupSelection) ...[
                _buildMemberInput(theme),
                const SizedBox(height: 12),
                _buildConfirmButton(),
              ],
              if (widget.isOnboarding) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _skip,
                  child: const Text(UiStrings.idolSelectSkip),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupList(List<IdolGroup> groups, ThemeData theme) {
    return ListView(
      children: [
        ...groups.map((g) => _buildGroupTile(g, theme)),
        const Divider(height: 24),
        _buildCustomInputTile(theme),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: _isCustomInput
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainer,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() {
            _isCustomInput = true;
            _selectedGroupId = null;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(UiStrings.idolSelectOther,
                    style: theme.textTheme.titleMedium),
                if (_isCustomInput) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _customController,
                    decoration: const InputDecoration(
                      hintText: UiStrings.idolSelectOtherHint,
                      isDense: true,
                    ),
                    autofocus: true,
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
      controller: _memberController,
      decoration: const InputDecoration(
        hintText: UiStrings.idolMemberHint,
        prefixIcon: Icon(Icons.person_outline),
      ),
    );
  }

  /// 확인 버튼. 그룹(+ 선택적 멤버) 저장 후 네비게이션.
  Widget _buildConfirmButton() {
    return FilledButton(
      onPressed: _confirmSelection,
      child: const Text(UiStrings.idolSelectConfirm),
    );
  }

  /// 프리셋 그룹 선택. 하이라이트만 하고 즉시 확인하지 않는다.
  void _selectGroup(String groupId) {
    setState(() {
      _selectedGroupId = groupId;
      _isCustomInput = false;
    });
  }

  /// 그룹 + 멤버명 저장 후 네비게이션.
  ///
  /// 프리셋 그룹과 커스텀 입력 모두 이 메서드로 확인한다.
  Future<void> _confirmSelection() async {
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
    await _markOnboardingDone();
    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _markOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
  }
}
