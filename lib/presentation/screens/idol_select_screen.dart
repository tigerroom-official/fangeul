import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fangeul/core/entities/idol_group.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';

/// 마이 아이돌 선택 화면.
///
/// 온보딩(첫 실행)과 설정에서 재사용한다.
/// [isOnboarding]이 true이면 스킵 버튼 표시 + 완료 시 /home으로 이동.
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

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

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
              if (widget.isOnboarding) ...[
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customController,
                          decoration: const InputDecoration(
                            hintText: UiStrings.idolSelectOtherHint,
                            isDense: true,
                          ),
                          autofocus: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _confirmCustom,
                        child: const Text(UiStrings.idolSelectConfirm),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectGroup(String groupId) {
    setState(() {
      _selectedGroupId = groupId;
      _isCustomInput = false;
    });
    _confirm(groupId);
  }

  void _confirmCustom() {
    final name = _customController.text.trim();
    if (name.isEmpty) return;
    _confirm('custom:$name');
  }

  Future<void> _confirm(String groupId) async {
    await ref.read(myIdolNotifierProvider.notifier).select(groupId);
    if (!mounted) return;
    if (widget.isOnboarding) {
      context.go('/home');
    } else {
      Navigator.of(context).pop();
    }
  }

  void _skip() {
    if (!mounted) return;
    context.go('/home');
  }
}
