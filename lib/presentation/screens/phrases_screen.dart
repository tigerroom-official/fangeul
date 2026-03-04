import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/phrase_providers.dart';
import 'package:fangeul/presentation/providers/template_phrase_provider.dart';
import 'package:fangeul/presentation/widgets/phrase_card.dart';
import 'package:fangeul/presentation/widgets/tag_filter_chips.dart';

/// 마이아이돌 필터 sentinel.
const _filterMyIdol = '__my_idol__';

/// 멤버 필터 sentinel.
const _filterMyMember = '__my_member__';

/// 전체 필터 sentinel (아이돌 설정 유저가 명시적으로 '전체' 선택 시).
const _filterAll = '__all__';

/// 선택된 필터 상태 Provider.
///
/// - null: 초기 상태 (멤버 설정 시 멤버, 아이돌만이면 아이돌, 미설정이면 전체)
/// - [_filterMyMember]: 멤버 전용 문구
/// - [_filterMyIdol]: 마이아이돌 문구
/// - [_filterAll]: 전체 문구 (아이돌 유저의 명시 선택)
/// - 그 외 문자열: 태그명
final selectedTagProvider = StateProvider<String?>((ref) => null);

/// 문구 화면 -- 팬 문구 라이브러리.
///
/// 아이돌 설정 유저에게는 개인화 문구가 기본 랜딩.
/// 태그 필터 칩으로 카테고리를 선택하고, 해당 문구 목록을 표시한다.
class PhrasesScreen extends ConsumerWidget {
  /// Creates the [PhrasesScreen] widget.
  const PhrasesScreen({super.key});

  static const _availableTags = [
    'love',
    'cheer',
    'daily',
    'greeting',
    'emotional',
    'praise',
    'fandom',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final selectedTag = ref.watch(selectedTagProvider);
    final idolNameAsync = ref.watch(myIdolDisplayNameProvider);
    final idolName = idolNameAsync.valueOrNull;
    final hasIdol = idolName != null;

    final memberNameAsync = ref.watch(myIdolMemberNameProvider);
    final memberName = memberNameAsync.valueOrNull;
    final hasMember = memberName != null;

    // 필터 상태 해석 — 멤버 > 아이돌 > 전체 우선순위
    final isMemberSelected =
        hasMember && (selectedTag == _filterMyMember || selectedTag == null);
    final isMyIdolSelected = selectedTag == _filterMyIdol ||
        (selectedTag == null && hasIdol && !hasMember);
    final isAllSelected =
        selectedTag == _filterAll || (selectedTag == null && !hasIdol);

    return Scaffold(
      appBar: AppBar(title: Text(l.phrasesTitle)),
      body: Column(
        children: [
          TagFilterChips(
            tags: _availableTags,
            selectedTag: isMemberSelected || isMyIdolSelected || isAllSelected
                ? null
                : selectedTag,
            onTagSelected: (tag) {
              if (tag == null) {
                // "전체" 탭: 아이돌 유저는 sentinel 사용
                ref.read(selectedTagProvider.notifier).state =
                    hasIdol ? _filterAll : null;
              } else {
                ref.read(selectedTagProvider.notifier).state = tag;
              }
            },
            // member
            showMemberChip: hasMember,
            isMemberSelected: isMemberSelected,
            onMemberSelected: () =>
                ref.read(selectedTagProvider.notifier).state = _filterMyMember,
            memberLabel: hasMember ? l.phrasesMemberChip(memberName) : null,
            // idol (label changes when member is set)
            showMyIdolChip: hasIdol,
            isMyIdolSelected: isMyIdolSelected,
            onMyIdolSelected: () =>
                ref.read(selectedTagProvider.notifier).state = _filterMyIdol,
            myIdolLabel: hasIdol
                ? (hasMember
                    ? l.phrasesGroupChip(idolName)
                    : l.phrasesMyIdolChip(idolName))
                : null,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: isMemberSelected
                ? _buildMyMemberPhrases(ref, idolName, memberName, l)
                : isMyIdolSelected
                    ? _buildMyIdolPhrases(ref, idolName, l,
                        memberName: memberName)
                    : isAllSelected
                        ? _buildAllPhrases(ref, l)
                        : _buildFilteredPhrases(ref, selectedTag!, l),
          ),
        ],
      ),
    );
  }

  /// 멤버 전용 문구 표시 (`{{member_name}}` 포함 템플릿만).
  Widget _buildMyMemberPhrases(
      WidgetRef ref, String? idolName, String? memberName, L l) {
    if (idolName == null || memberName == null) {
      return Center(child: Text(l.phrasesMemberEmpty));
    }

    final packsAsync = ref.watch(allPhrasesProvider);

    return packsAsync.when(
      data: (packs) {
        final phrases = packs
            .where((p) => p.isFree)
            .expand((p) => p.phrases)
            .where((p) => p.isTemplate && needsMemberName(p))
            .map((p) =>
                resolveTemplatePhrase(p, idolName, memberName: memberName))
            .toList();
        if (phrases.isEmpty) {
          return Center(child: Text(l.phrasesMemberEmpty));
        }
        return ListView.builder(
          itemCount: phrases.length,
          itemBuilder: (context, index) => PhraseCard(
            phrase: phrases[index],
            translationLang: l.defaultTranslationLang,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l.errorPrefix} $e')),
    );
  }

  /// 마이아이돌 그룹 전용 개인화 문구 표시.
  ///
  /// `{{member_name}}` 슬롯을 포함하는 템플릿은 항상 제외한다.
  /// 멤버 설정 시 해당 템플릿은 [_buildMyMemberPhrases]에서 표시한다.
  Widget _buildMyIdolPhrases(WidgetRef ref, String? idolName, L l,
      {String? memberName}) {
    if (idolName == null) {
      return Center(child: Text(l.phrasesMyIdolEmpty));
    }

    final packsAsync = ref.watch(allPhrasesProvider);

    return packsAsync.when(
      data: (packs) {
        final phrases = packs
            .where((p) => p.isFree)
            .expand((p) => p.phrases)
            .where((p) => p.isTemplate)
            .where((p) => !needsMemberName(p))
            .map((p) => resolveTemplatePhrase(p, idolName))
            .toList();
        if (phrases.isEmpty) {
          return Center(child: Text(l.phrasesMyIdolEmpty));
        }
        return ListView.builder(
          itemCount: phrases.length,
          itemBuilder: (context, index) => PhraseCard(
            phrase: phrases[index],
            translationLang: l.defaultTranslationLang,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l.errorPrefix} $e')),
    );
  }

  /// 전체 문구 (팩 기반) 표시.
  Widget _buildAllPhrases(WidgetRef ref, L l) {
    final packsAsync = ref.watch(allPhrasesProvider);

    return packsAsync.when(
      data: (packs) {
        final phrases = _flattenPacks(packs);
        if (phrases.isEmpty) {
          return Center(child: Text(l.phrasesEmpty));
        }
        return ListView.builder(
          itemCount: phrases.length,
          itemBuilder: (context, index) => PhraseCard(
            phrase: phrases[index],
            translationLang: l.defaultTranslationLang,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l.errorPrefix} $e')),
    );
  }

  /// 태그 필터링된 문구 표시.
  Widget _buildFilteredPhrases(WidgetRef ref, String tag, L l) {
    final phrasesAsync = ref.watch(phrasesByTagProvider(tag));

    return phrasesAsync.when(
      data: (phrases) {
        // 템플릿 문구 제외 — {{group_name}} 원문 노출 방지
        final filtered = phrases.where((p) => !p.isTemplate).toList();
        if (filtered.isEmpty) {
          return Center(child: Text(l.phrasesEmpty));
        }
        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) => PhraseCard(
            phrase: filtered[index],
            translationLang: l.defaultTranslationLang,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l.errorPrefix} $e')),
    );
  }

  /// 무료 팩의 문구를 평탄화하여 단일 리스트로 변환.
  ///
  /// 템플릿 문구(`isTemplate`)는 제외 — 마이 아이돌 전용 치환 경로에서만 사용.
  List<Phrase> _flattenPacks(List<PhrasePack> packs) {
    return packs
        .where((pack) => pack.isFree)
        .expand((pack) => pack.phrases)
        .where((phrase) => !phrase.isTemplate)
        .toList();
  }
}
