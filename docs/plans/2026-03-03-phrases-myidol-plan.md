# PhrasesScreen 마이아이돌 개인화 — 구현 계획서

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 메인 앱 문구 탭에 마이아이돌 칩을 추가하여 개인화 문구를 기본 랜딩으로 표시한다.

**Architecture:** TagFilterChips에 optional myIdol 칩 파라미터를 추가하고, PhrasesScreen에서 아이돌 설정 여부에 따라 칩 바와 콘텐츠 영역을 분기한다. sentinel 값(`__my_idol__`, `__all__`)으로 기존 StateProvider를 확장하여 myIdol/전체/태그 3가지 필터 모드를 지원한다.

**Tech Stack:** Flutter, Riverpod (StateProvider), freezed Phrase entity, `resolveTemplatePhrase()`

**설계서:** `docs/plans/2026-03-03-phrases-myidol-design.md`

---

## Task 1: 태그 필터 뷰 템플릿 노출 버그 수정

`GetPhrasesByTagUseCase`가 `isTemplate: true` 문구를 필터링하지 않아 태그 선택 시 `{{group_name}}` 원문이 노출되는 버그.

**Files:**
- Modify: `lib/presentation/screens/phrases_screen.dart:84-103` (`_buildFilteredPhrases`)
- Test: `test/presentation/screens/phrases_screen_myidol_test.dart` (신규)

**Step 1: 실패하는 테스트 작성**

`test/presentation/screens/phrases_screen_myidol_test.dart` 파일 생성:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fangeul/core/entities/phrase.dart';

void main() {
  group('Template filtering', () {
    test('should not include template phrases in tag-filtered results', () {
      final phrases = [
        const Phrase(
          ko: '사랑해요',
          roman: 'saranghaeyo',
          context: 'love',
          tags: ['love'],
          translations: {'en': 'I love you'},
          situation: 'daily',
        ),
        const Phrase(
          ko: '{{group_name}} 사랑해요!',
          roman: '{{group_name}} saranghaeyo!',
          context: 'template',
          tags: ['love'],
          translations: {'en': 'I love {{group_name}}!'},
          situation: 'daily',
          isTemplate: true,
        ),
      ];

      final filtered = phrases.where((p) => !p.isTemplate).toList();
      expect(filtered.length, 1);
      expect(filtered.first.ko, '사랑해요');
      expect(filtered.any((p) => p.ko.contains('{{group_name}}')), isFalse);
    });
  });
}
```

**Step 2: 테스트 실행 — 통과 확인 (필터 로직 자체는 맞음)**

Run: `flutter test test/presentation/screens/phrases_screen_myidol_test.dart`
Expected: PASS — 이 테스트는 필터 로직 검증용. 실제 버그는 `_buildFilteredPhrases`에서 이 필터를 적용하지 않는 것.

**Step 3: PhrasesScreen에 템플릿 필터 추가**

`lib/presentation/screens/phrases_screen.dart:84-103`의 `_buildFilteredPhrases`에서 태그 필터 결과에 `!isTemplate` 필터 추가:

```dart
  /// 태그 필터링된 문구 표시.
  Widget _buildFilteredPhrases(WidgetRef ref, String tag) {
    final phrasesAsync = ref.watch(phrasesByTagProvider(tag));

    return phrasesAsync.when(
      data: (phrases) {
        // 템플릿 문구 제외 — {{group_name}} 원문 노출 방지
        final filtered = phrases.where((p) => !p.isTemplate).toList();
        if (filtered.isEmpty) {
          return const Center(child: Text(UiStrings.phrasesEmpty));
        }
        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) => PhraseCard(
            phrase: filtered[index],
            translationLang: UiStrings.defaultTranslationLang,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${UiStrings.errorPrefix} $e')),
    );
  }
```

**Step 4: 전체 테스트 실행**

Run: `flutter test`
Expected: 전체 PASS (기존 317개 + 신규 1개)

**Step 5: 커밋**

```bash
git add lib/presentation/screens/phrases_screen.dart test/presentation/screens/phrases_screen_myidol_test.dart
git commit -m "fix: filter template phrases from tag-filtered view in PhrasesScreen"
```

---

## Task 2: UI 문자열 상수 추가

**Files:**
- Modify: `lib/presentation/constants/ui_strings.dart`

**Step 1: 상수 추가**

`lib/presentation/constants/ui_strings.dart`의 `// 문구 화면` 섹션(line 39-41)에 추가:

```dart
  // 문구 화면
  static const phrasesTitle = '문구';
  static const phrasesEmpty = '문구가 없습니다';
  static const phrasesMyIdolEmpty = '설정에서 아이돌을 선택하면\n맞춤 문구가 표시됩니다';

  /// 마이아이돌 칩 레이블. 예: '♡ BTS'.
  static String phrasesMyIdolChip(String name) => '♡ $name';
```

**Step 2: 커밋**

```bash
git add lib/presentation/constants/ui_strings.dart
git commit -m "feat: add PhrasesScreen myIdol UI string constants"
```

---

## Task 3: TagFilterChips에 myIdol 칩 파라미터 추가

**Files:**
- Modify: `lib/presentation/widgets/tag_filter_chips.dart`
- Test: `test/presentation/widgets/tag_filter_chips_test.dart` (신규)

**Step 1: 실패하는 테스트 작성**

`test/presentation/widgets/tag_filter_chips_test.dart` 신규 생성:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/widgets/tag_filter_chips.dart';

void main() {
  const tags = ['love', 'cheer', 'daily'];

  Widget buildTestWidget({
    String? selectedTag,
    ValueChanged<String?>? onTagSelected,
    bool showMyIdolChip = false,
    bool isMyIdolSelected = false,
    VoidCallback? onMyIdolSelected,
    String myIdolLabel = '♡ TestIdol',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: TagFilterChips(
          tags: tags,
          selectedTag: selectedTag,
          onTagSelected: onTagSelected ?? (_) {},
          showMyIdolChip: showMyIdolChip,
          isMyIdolSelected: isMyIdolSelected,
          onMyIdolSelected: onMyIdolSelected,
          myIdolLabel: myIdolLabel,
        ),
      ),
    );
  }

  group('TagFilterChips — myIdol chip', () {
    testWidgets('should show myIdol chip when showMyIdolChip is true',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(showMyIdolChip: true));
      await tester.pumpAndSettle();

      expect(find.text('♡ TestIdol'), findsOneWidget);
    });

    testWidgets('should not show myIdol chip when showMyIdolChip is false',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('♡ TestIdol'), findsNothing);
    });

    testWidgets('should highlight myIdol chip when isMyIdolSelected is true',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        showMyIdolChip: true,
        isMyIdolSelected: true,
      ));
      await tester.pumpAndSettle();

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final myIdolChip = chips.first; // myIdol is first chip
      expect(myIdolChip.selected, isTrue);
    });

    testWidgets('should not highlight 전체 when myIdol is selected',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        showMyIdolChip: true,
        isMyIdolSelected: true,
      ));
      await tester.pumpAndSettle();

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final allChip = chips.elementAt(1); // 0=myIdol, 1=전체
      expect(allChip.selected, isFalse);
    });

    testWidgets('should highlight 전체 when myIdol not selected and tag is null',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(showMyIdolChip: true));
      await tester.pumpAndSettle();

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final allChip = chips.elementAt(1); // 0=myIdol, 1=전체
      expect(allChip.selected, isTrue);
    });

    testWidgets('should call onMyIdolSelected on myIdol chip tap',
        (tester) async {
      var called = false;
      await tester.pumpWidget(buildTestWidget(
        showMyIdolChip: true,
        onMyIdolSelected: () => called = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('♡ TestIdol'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('should place myIdol chip before 전체 chip', (tester) async {
      await tester.pumpWidget(buildTestWidget(showMyIdolChip: true));
      await tester.pumpAndSettle();

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      // 순서: myIdol, 전체, 사랑, 응원, 일상
      expect(chips.length, 5); // 1(myIdol) + 1(전체) + 3(tags)
    });
  });

  group('TagFilterChips — existing behavior', () {
    testWidgets('should show 전체 as selected when selectedTag is null',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final allChip = chips.first;
      expect(allChip.selected, isTrue);
    });

    testWidgets('should call onTagSelected with tag on chip tap',
        (tester) async {
      String? selected;
      await tester.pumpWidget(buildTestWidget(
        onTagSelected: (tag) => selected = tag,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(UiStrings.tagLove));
      await tester.pumpAndSettle();

      expect(selected, 'love');
    });

    testWidgets('should call onTagSelected with null on 전체 tap',
        (tester) async {
      String? selected = 'love';
      await tester.pumpWidget(buildTestWidget(
        selectedTag: 'love',
        onTagSelected: (tag) => selected = tag,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(UiStrings.tagAll));
      await tester.pumpAndSettle();

      expect(selected, isNull);
    });
  });
}
```

**Step 2: 테스트 실행 — 실패 확인**

Run: `flutter test test/presentation/widgets/tag_filter_chips_test.dart`
Expected: FAIL — `showMyIdolChip` 파라미터 없음

**Step 3: TagFilterChips 구현**

`lib/presentation/widgets/tag_filter_chips.dart` 전체 교체:

```dart
import 'package:flutter/material.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';

/// 태그 필터 칩 -- 문구 카테고리 필터링.
///
/// 수평 스크롤 칩 목록으로, '전체' + 개별 태그를 선택할 수 있다.
/// [showMyIdolChip]이 true이면 좌측에 마이아이돌 칩을 추가 표시한다.
class TagFilterChips extends StatelessWidget {
  /// Creates the [TagFilterChips] widget.
  const TagFilterChips({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
    this.showMyIdolChip = false,
    this.isMyIdolSelected = false,
    this.onMyIdolSelected,
    this.myIdolLabel,
  });

  /// 사용 가능한 태그 목록.
  final List<String> tags;

  /// 현재 선택된 태그. null이면 '전체' 선택.
  final String? selectedTag;

  /// 태그 선택 콜백. null을 전달하면 '전체' 선택.
  final ValueChanged<String?> onTagSelected;

  /// 마이아이돌 칩 표시 여부.
  final bool showMyIdolChip;

  /// 마이아이돌 칩 선택 상태.
  final bool isMyIdolSelected;

  /// 마이아이돌 칩 탭 콜백.
  final VoidCallback? onMyIdolSelected;

  /// 마이아이돌 칩 레이블 (예: '♡ BTS').
  final String? myIdolLabel;

  static const _tagLabels = {
    'love': UiStrings.tagLove,
    'cheer': UiStrings.tagCheer,
    'daily': UiStrings.tagDaily,
    'greeting': UiStrings.tagGreeting,
    'emotional': UiStrings.tagEmotional,
    'praise': UiStrings.tagPraise,
    'fandom': UiStrings.tagFandom,
    'birthday': UiStrings.tagBirthday,
    'comeback': UiStrings.tagComeback,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // 마이아이돌 칩 (좌측 고정)
          if (showMyIdolChip)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                context,
                label: myIdolLabel ?? UiStrings.idolSettingLabel,
                selected: isMyIdolSelected,
                onSelected: (_) => onMyIdolSelected?.call(),
                primary: primary,
                theme: theme,
              ),
            ),
          // 전체 칩
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildChip(
              context,
              label: UiStrings.tagAll,
              selected: !isMyIdolSelected && selectedTag == null,
              onSelected: (_) => onTagSelected(null),
              primary: primary,
              theme: theme,
            ),
          ),
          // 태그 칩
          ...tags.map(
            (tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                context,
                label: _tagLabels[tag] ?? tag,
                selected: !isMyIdolSelected && selectedTag == tag,
                onSelected: (_) => onTagSelected(tag),
                primary: primary,
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    required Color primary,
    required ThemeData theme,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: primary,
      backgroundColor: theme.colorScheme.surfaceContainer,
      checkmarkColor: theme.colorScheme.onPrimary,
      showCheckmark: false,
      side: selected
          ? BorderSide.none
          : BorderSide(color: theme.colorScheme.outlineVariant),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
```

**Step 4: 테스트 실행 — 통과 확인**

Run: `flutter test test/presentation/widgets/tag_filter_chips_test.dart`
Expected: 전체 PASS

**Step 5: 커밋**

```bash
git add lib/presentation/widgets/tag_filter_chips.dart test/presentation/widgets/tag_filter_chips_test.dart
git commit -m "feat: add myIdol chip support to TagFilterChips"
```

---

## Task 4: PhrasesScreen에 마이아이돌 필터 로직 추가

**Files:**
- Modify: `lib/presentation/screens/phrases_screen.dart` (전체 리팩토링)
- Test: `test/presentation/screens/phrases_screen_myidol_test.dart` (기존 파일에 추가)

**Step 1: 실패하는 테스트 작성**

`test/presentation/screens/phrases_screen_myidol_test.dart`에 위젯 테스트 추가:

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/screens/phrases_screen.dart';

/// 테스트용 mock asset 로더 설정.
void setupMockAssets() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
    final key = utf8.decode(message!.buffer.asUint8List());

    if (key == 'assets/phrases/basic_love.json') {
      return ByteData.sublistView(utf8.encode(jsonEncode({
        'id': 'basic_love',
        'name': 'Love & Support',
        'name_ko': '사랑 & 응원',
        'is_free': true,
        'phrases': [
          {
            'ko': '사랑해요',
            'roman': 'saranghaeyo',
            'context': 'express love',
            'tags': ['love'],
            'translations': {'en': 'I love you'},
            'situation': 'daily',
          },
        ],
      })));
    }
    if (key == 'assets/phrases/my_idol_pack.json') {
      return ByteData.sublistView(utf8.encode(jsonEncode({
        'id': 'my_idol',
        'name': 'My Idol',
        'name_ko': '내 아이돌',
        'is_free': true,
        'phrases': [
          {
            'ko': '{{group_name}} 사랑해요!',
            'roman': '{{group_name}} saranghaeyo!',
            'context': 'template',
            'tags': ['love'],
            'translations': {'en': 'I love {{group_name}}!'},
            'situation': 'daily',
            'is_template': true,
          },
          {
            'ko': '{{group_name}} 화이팅!',
            'roman': '{{group_name}} hwaiting!',
            'context': 'template',
            'tags': ['cheer'],
            'translations': {'en': 'Go {{group_name}}!'},
            'situation': 'support',
            'is_template': true,
          },
        ],
      })));
    }
    if (key == 'assets/phrases/pack_manifest.json') {
      return ByteData.sublistView(utf8.encode(jsonEncode({
        'packs': ['basic_love', 'my_idol_pack'],
      })));
    }
    if (key == 'assets/groups/groups.json') {
      return ByteData.sublistView(utf8.encode(jsonEncode({
        'groups': [
          {'id': 'bts', 'name_en': 'BTS', 'name_ko': '방탄소년단'},
        ],
      })));
    }

    return null;
  });
}

void main() {
  // (기존 테스트 유지)
  group('Template filtering', () {
    test('should not include template phrases in tag-filtered results', () {
      final phrases = [
        const Phrase(
          ko: '사랑해요',
          roman: 'saranghaeyo',
          context: 'love',
          tags: ['love'],
          translations: {'en': 'I love you'},
          situation: 'daily',
        ),
        const Phrase(
          ko: '{{group_name}} 사랑해요!',
          roman: '{{group_name}} saranghaeyo!',
          context: 'template',
          tags: ['love'],
          translations: {'en': 'I love {{group_name}}!'},
          situation: 'daily',
          isTemplate: true,
        ),
      ];

      final filtered = phrases.where((p) => !p.isTemplate).toList();
      expect(filtered.length, 1);
      expect(filtered.first.ko, '사랑해요');
      expect(filtered.any((p) => p.ko.contains('{{group_name}}')), isFalse);
    });
  });

  group('PhrasesScreen myIdol chip', () {
    setUp(() {
      setupMockAssets();
    });

    testWidgets('should show myIdol chip when idol is set', (tester) async {
      SharedPreferences.setMockInitialValues({'my_idol_group_id': 'custom:DaySix'});
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const PhrasesScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.phrasesMyIdolChip('DaySix')), findsOneWidget);
    });

    testWidgets('should not show myIdol chip when idol is not set',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const PhrasesScreen())),
      );
      await tester.pumpAndSettle();

      // 아이돌 칩 없어야 함
      expect(find.byType(FilterChip), findsWidgets);
      // "전체" 첫 번째 칩이 selected
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      expect(chips.first.selected, isTrue);
    });

    testWidgets('should default to myIdol chip when idol is set',
        (tester) async {
      SharedPreferences.setMockInitialValues({'my_idol_group_id': 'custom:DaySix'});
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const PhrasesScreen())),
      );
      await tester.pumpAndSettle();

      // 아이돌 칩이 selected 상태여야 함
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      expect(chips.first.selected, isTrue); // myIdol chip = first
    });

    testWidgets('should show resolved template phrases when myIdol chip selected',
        (tester) async {
      SharedPreferences.setMockInitialValues({'my_idol_group_id': 'custom:DaySix'});
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const PhrasesScreen())),
      );
      await tester.pumpAndSettle();

      // 치환된 문구가 표시되어야 함
      expect(find.textContaining('DaySix 사랑해요!'), findsOneWidget);
      expect(find.textContaining('DaySix 화이팅!'), findsOneWidget);
      // {{group_name}} 원문은 절대 노출되면 안 됨
      expect(find.textContaining('{{group_name}}'), findsNothing);
    });

    testWidgets('should switch to tag view when tag chip tapped',
        (tester) async {
      SharedPreferences.setMockInitialValues({'my_idol_group_id': 'custom:DaySix'});
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const PhrasesScreen())),
      );
      await tester.pumpAndSettle();

      // 태그 칩 탭
      await tester.tap(find.text(UiStrings.tagLove));
      await tester.pumpAndSettle();

      // 일반 문구 표시, 템플릿 미표시
      expect(find.text('사랑해요'), findsOneWidget);
      expect(find.textContaining('{{group_name}}'), findsNothing);
    });

    testWidgets('should switch back to myIdol view on myIdol chip tap',
        (tester) async {
      SharedPreferences.setMockInitialValues({'my_idol_group_id': 'custom:DaySix'});
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const PhrasesScreen())),
      );
      await tester.pumpAndSettle();

      // 태그 칩 탭 → 다시 아이돌 칩 탭
      await tester.tap(find.text(UiStrings.tagLove));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UiStrings.phrasesMyIdolChip('DaySix')));
      await tester.pumpAndSettle();

      expect(find.textContaining('DaySix 사랑해요!'), findsOneWidget);
    });
  });
}
```

> **Note:** 위 위젯 테스트는 asset mock이 필요해 다소 복잡하다. 실제 구현 시 mock 설정이 프로젝트 테스트 인프라와 맞지 않으면 `ProviderContainer` 기반 유닛 테스트로 대체한다. 핵심은 (1) 아이돌 칩 표시/미표시, (2) 기본 랜딩, (3) 치환 문구 표시, (4) 태그 전환 동작을 검증하는 것.

**Step 2: PhrasesScreen 구현**

`lib/presentation/screens/phrases_screen.dart` 전체 교체:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/phrase_providers.dart';
import 'package:fangeul/presentation/providers/template_phrase_provider.dart';
import 'package:fangeul/presentation/widgets/phrase_card.dart';
import 'package:fangeul/presentation/widgets/tag_filter_chips.dart';

/// 마이아이돌 필터 sentinel.
const _filterMyIdol = '__my_idol__';

/// 전체 필터 sentinel (아이돌 설정 유저가 명시적으로 '전체' 선택 시).
const _filterAll = '__all__';

/// 선택된 필터 상태 Provider.
///
/// - null: 초기 상태 (아이돌 설정 유저는 아이돌, 미설정이면 전체)
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
    final selectedTag = ref.watch(selectedTagProvider);
    final idolNameAsync = ref.watch(myIdolDisplayNameProvider);
    final idolName = idolNameAsync.valueOrNull;
    final hasIdol = idolName != null;

    // 필터 상태 해석:
    // null + hasIdol → 아이돌 (기본 랜딩)
    // null + !hasIdol → 전체 (기존 동작)
    // __my_idol__ → 아이돌 (명시 선택)
    // __all__ → 전체 (명시 선택)
    // 그 외 → 태그
    final isMyIdolSelected =
        selectedTag == _filterMyIdol || (selectedTag == null && hasIdol);
    final isAllSelected =
        selectedTag == _filterAll || (selectedTag == null && !hasIdol);

    return Scaffold(
      appBar: AppBar(title: const Text(UiStrings.phrasesTitle)),
      body: Column(
        children: [
          // 칩 바
          TagFilterChips(
            tags: _availableTags,
            selectedTag: isMyIdolSelected || isAllSelected
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
            showMyIdolChip: hasIdol,
            isMyIdolSelected: isMyIdolSelected,
            onMyIdolSelected: () =>
                ref.read(selectedTagProvider.notifier).state = _filterMyIdol,
            myIdolLabel:
                hasIdol ? UiStrings.phrasesMyIdolChip(idolName) : null,
          ),
          const SizedBox(height: 8),
          // 콘텐츠 영역
          Expanded(
            child: isMyIdolSelected
                ? _buildMyIdolPhrases(ref, idolName)
                : isAllSelected
                    ? _buildAllPhrases(ref)
                    : _buildFilteredPhrases(ref, selectedTag!),
          ),
        ],
      ),
    );
  }

  /// 마이아이돌 개인화 문구 표시.
  Widget _buildMyIdolPhrases(WidgetRef ref, String? idolName) {
    if (idolName == null) {
      return const Center(child: Text(UiStrings.phrasesMyIdolEmpty));
    }

    final packsAsync = ref.watch(allPhrasesProvider);

    return packsAsync.when(
      data: (packs) {
        final phrases = _resolveTemplates(packs, idolName);
        if (phrases.isEmpty) {
          return const Center(child: Text(UiStrings.phrasesMyIdolEmpty));
        }
        return ListView.builder(
          itemCount: phrases.length,
          itemBuilder: (context, index) => PhraseCard(
            phrase: phrases[index],
            translationLang: UiStrings.defaultTranslationLang,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${UiStrings.errorPrefix} $e')),
    );
  }

  /// 전체 문구 (팩 기반) 표시.
  Widget _buildAllPhrases(WidgetRef ref) {
    final packsAsync = ref.watch(allPhrasesProvider);

    return packsAsync.when(
      data: (packs) {
        final phrases = _flattenPacks(packs);
        if (phrases.isEmpty) {
          return const Center(child: Text(UiStrings.phrasesEmpty));
        }
        return ListView.builder(
          itemCount: phrases.length,
          itemBuilder: (context, index) => PhraseCard(
            phrase: phrases[index],
            translationLang: UiStrings.defaultTranslationLang,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${UiStrings.errorPrefix} $e')),
    );
  }

  /// 태그 필터링된 문구 표시.
  Widget _buildFilteredPhrases(WidgetRef ref, String tag) {
    final phrasesAsync = ref.watch(phrasesByTagProvider(tag));

    return phrasesAsync.when(
      data: (phrases) {
        // 템플릿 문구 제외 — {{group_name}} 원문 노출 방지
        final filtered = phrases.where((p) => !p.isTemplate).toList();
        if (filtered.isEmpty) {
          return const Center(child: Text(UiStrings.phrasesEmpty));
        }
        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) => PhraseCard(
            phrase: filtered[index],
            translationLang: UiStrings.defaultTranslationLang,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${UiStrings.errorPrefix} $e')),
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

  /// 모든 팩에서 템플릿 문구를 수집하여 치환 후 반환.
  List<Phrase> _resolveTemplates(List<PhrasePack> packs, String idolName) {
    return packs
        .expand((p) => p.phrases)
        .where((p) => p.isTemplate)
        .map((p) => resolveTemplatePhrase(p, idolName))
        .toList();
  }
}
```

**Step 3: 테스트 실행**

Run: `flutter test test/presentation/screens/phrases_screen_myidol_test.dart`
Expected: PASS

Run: `flutter test`
Expected: 전체 PASS

**Step 4: 정적 분석**

Run: `flutter analyze`
Expected: no issues

**Step 5: 커밋**

```bash
git add lib/presentation/screens/phrases_screen.dart test/presentation/screens/phrases_screen_myidol_test.dart
git commit -m "feat: add myIdol personalized phrases to PhrasesScreen"
```

---

## Task 5: 탭 전환 시 필터 리셋

문구 탭에서 다른 탭(홈/변환기)으로 갔다가 돌아올 때 `selectedTagProvider`가 이전 상태를 유지한다. 이는 의도된 동작이지만, 아이돌을 새로 설정한 후 문구 탭에 돌아왔을 때 자동 반영되도록 보장해야 한다.

**Files:**
- 변경 없음 — 현재 설계에서 자동 동작 확인

**확인 사항:**
- `selectedTagProvider`는 `null` 기본값 (auto-dispose 아님, 앱 세션 유지)
- `myIdolDisplayNameProvider` 변경 시 PhrasesScreen이 리빌드됨 (`ref.watch`)
- 아이돌을 새로 설정하면 `hasIdol`이 true로 변경 → `selectedTag == null && hasIdol` → 아이돌 칩 자동 선택
- 아이돌을 해제하면 `hasIdol`이 false → `selectedTag == null && !hasIdol` → 전체 자동 선택

이미 `selectedTag == null` (초기 상태)에서 `hasIdol` 변경에 반응하므로 별도 작업 불필요.

단, 사용자가 태그를 명시 선택한 상태(`selectedTag == 'love'`)에서 아이돌을 설정하면 칩 바에 아이돌 칩이 나타나지만 love 필터가 유지됨. 이는 올바른 동작 — 사용자의 명시 선택을 존중.

---

## Task 6: 전체 테스트 + 정적 분석 최종 검증

**Step 1: 전체 테스트**

Run: `flutter test`
Expected: 전체 PASS (기존 317 + 신규 ~12개)

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: no issues

**Step 3: 포맷 검증**

Run: `dart format --set-exit-if-changed .`
Expected: no changes

**Step 4: 최종 커밋 (필요 시)**

누락 파일이 있으면 추가 커밋.

---

## 요약

| Task | 내용 | 파일 |
|------|------|------|
| 1 | 태그 필터 템플릿 노출 버그 수정 | phrases_screen.dart, 테스트 |
| 2 | UI 문자열 상수 추가 | ui_strings.dart |
| 3 | TagFilterChips myIdol 칩 지원 | tag_filter_chips.dart, 테스트 |
| 4 | PhrasesScreen 아이돌 필터 로직 | phrases_screen.dart, 테스트 |
| 5 | 탭 전환 동작 검증 (코드 변경 없음) | — |
| 6 | 전체 검증 | — |
