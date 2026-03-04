# Phase B: 멤버 레벨 개인화 구현 계획서

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 유저가 그룹 + 멤버명을 설정하면 멤버 전용 문구(`{{member_name}}`)를 볼 수 있게 한다.

**Architecture:** 기존 마이 아이돌 인프라(MyIdolNotifier, resolveTemplatePhrase, sentinel 필터) 위에 `my_idol_member_name` SharedPreferences 키를 추가. `{{member_name}}` 템플릿 슬롯 + PhrasesScreen 멤버 칩으로 확장. 버블은 기존 myIdol 칩에서 그룹+멤버 통합 표시.

**Tech Stack:** Flutter/Dart, Riverpod, freezed, SharedPreferences, mocktail

**설계 문서:** `docs/plans/2026-03-03-phrases-myidol-design.md` §3

---

## Task 1: resolveTemplatePhrase 멤버명 확장

**Files:**
- Modify: `lib/presentation/providers/template_phrase_provider.dart`
- Test: `test/presentation/providers/template_phrase_provider_test.dart`

**Step 1: 멤버 치환 실패 테스트 작성**

`test/presentation/providers/template_phrase_provider_test.dart`에 group 추가:

```dart
group('member name support', () {
  test('should replace {{member_name}} with member name', () {
    final phrase = Phrase(
      ko: '{{member_name}} 사랑해!',
      roman: '{{member_name}} saranghae!',
      context: 'Template member love',
      isTemplate: true,
    );

    final resolved = resolveTemplatePhrase(phrase, 'BTS', memberName: '정국');
    expect(resolved.ko, '정국 사랑해!');
    expect(resolved.roman, '정국 saranghae!');
  });

  test('should replace both {{group_name}} and {{member_name}}', () {
    final phrase = Phrase(
      ko: '{{group_name}}의 {{member_name}} 최고!',
      roman: '{{group_name}}ui {{member_name}} choego!',
      context: 'Template combo',
      translations: {'en': '{{member_name}} of {{group_name}} is the best!'},
      isTemplate: true,
    );

    final resolved = resolveTemplatePhrase(phrase, 'BTS', memberName: '정국');
    expect(resolved.ko, 'BTS의 정국 최고!');
    expect(resolved.roman, 'BTSui 정국 choego!');
    expect(resolved.translations['en'], '정국 of BTS is the best!');
  });

  test('should not replace {{member_name}} when memberName is null', () {
    final phrase = Phrase(
      ko: '{{member_name}} 사랑해!',
      roman: '{{member_name}} saranghae!',
      context: 'Template member',
      isTemplate: true,
    );

    final resolved = resolveTemplatePhrase(phrase, 'BTS');
    expect(resolved.ko, '{{member_name}} 사랑해!');
  });
});
```

**Step 2: 테스트 실행 → 실패 확인**

Run: `flutter test test/presentation/providers/template_phrase_provider_test.dart -v`
Expected: FAIL — `memberName` parameter not accepted

**Step 3: resolveTemplatePhrase 확장 구현**

`lib/presentation/providers/template_phrase_provider.dart` 수정:

```dart
/// 템플릿 문구의 `{{group_name}}`과 `{{member_name}}`을 치환한다.
///
/// [memberName]이 null이면 `{{member_name}}`은 치환하지 않는다.
Phrase resolveTemplatePhrase(
  Phrase phrase,
  String groupName, {
  String? memberName,
}) {
  if (!phrase.isTemplate) return phrase;

  String replace(String text) {
    var result = text.replaceAll('{{group_name}}', groupName);
    if (memberName != null) {
      result = result.replaceAll('{{member_name}}', memberName);
    }
    return result;
  }

  return phrase.copyWith(
    ko: replace(phrase.ko),
    roman: replace(phrase.roman),
    translations: phrase.translations.map(
      (lang, text) => MapEntry(lang, replace(text)),
    ),
  );
}
```

**Step 4: needsMemberName 헬퍼 테스트 + 구현**

테스트 추가:

```dart
group('needsMemberName', () {
  test('should return true for member template', () {
    final phrase = Phrase(
      ko: '{{member_name}} 사랑해!',
      roman: '',
      context: '',
      isTemplate: true,
    );
    expect(needsMemberName(phrase), isTrue);
  });

  test('should return false for group-only template', () {
    final phrase = Phrase(
      ko: '{{group_name}} 사랑해요!',
      roman: '',
      context: '',
      isTemplate: true,
    );
    expect(needsMemberName(phrase), isFalse);
  });

  test('should return false for non-template', () {
    final phrase = Phrase(ko: '사랑해요', roman: '', context: '');
    expect(needsMemberName(phrase), isFalse);
  });
});
```

구현 추가 (`template_phrase_provider.dart`):

```dart
/// 문구가 `{{member_name}}` 슬롯을 포함하는지 확인.
bool needsMemberName(Phrase phrase) => phrase.ko.contains('{{member_name}}');
```

**Step 5: filterAndResolveTemplates 확장**

테스트 추가:

```dart
test('should filter member templates when memberName is null', () {
  final phrases = [
    Phrase(ko: '사랑해요', roman: '', context: 'A'),
    Phrase(
      ko: '{{group_name}} 화이팅!',
      roman: '',
      context: 'B',
      isTemplate: true,
    ),
    Phrase(
      ko: '{{member_name}} 사랑해!',
      roman: '',
      context: 'C',
      isTemplate: true,
    ),
  ];

  final resolved = filterAndResolveTemplates(phrases, 'BTS');
  expect(resolved, hasLength(2));
  expect(resolved[0].ko, '사랑해요');
  expect(resolved[1].ko, 'BTS 화이팅!');
});

test('should include member templates when memberName is set', () {
  final phrases = [
    Phrase(
      ko: '{{member_name}} 사랑해!',
      roman: '',
      context: 'A',
      isTemplate: true,
    ),
    Phrase(
      ko: '{{group_name}} 화이팅!',
      roman: '',
      context: 'B',
      isTemplate: true,
    ),
  ];

  final resolved =
      filterAndResolveTemplates(phrases, 'BTS', memberName: '정국');
  expect(resolved, hasLength(2));
  expect(resolved[0].ko, '정국 사랑해!');
  expect(resolved[1].ko, 'BTS 화이팅!');
});
```

구현 수정:

```dart
List<Phrase> filterAndResolveTemplates(
  List<Phrase> phrases,
  String? idolName, {
  String? memberName,
}) {
  if (idolName == null) {
    return phrases.where((p) => !p.isTemplate).toList();
  }

  return phrases
      .where((p) =>
          !p.isTemplate || !needsMemberName(p) || memberName != null)
      .map((p) => resolveTemplatePhrase(p, idolName, memberName: memberName))
      .toList();
}
```

**Step 6: 전체 테스트 통과 확인**

Run: `flutter test test/presentation/providers/template_phrase_provider_test.dart -v`
Expected: ALL PASS

**Step 7: 커밋**

```bash
git add lib/presentation/providers/template_phrase_provider.dart \
  test/presentation/providers/template_phrase_provider_test.dart
git commit -m "feat: extend resolveTemplatePhrase with {{member_name}} support"
```

---

## Task 2: MyIdolNotifier 멤버명 지원

**Files:**
- Modify: `lib/presentation/providers/my_idol_provider.dart`
- Regenerate: `lib/presentation/providers/my_idol_provider.g.dart`
- Test: `test/presentation/providers/my_idol_provider_test.dart`

**Step 1: 멤버명 테스트 작성**

`test/presentation/providers/my_idol_provider_test.dart`에 group 추가:

```dart
group('Member name', () {
  test('should return null member name when not set', () async {
    final result = await container.read(myIdolMemberNameProvider.future);
    expect(result, isNull);
  });

  test('should save and return member name after selectMember', () async {
    final notifier = container.read(myIdolNotifierProvider.notifier);
    await container.read(myIdolNotifierProvider.future);
    await notifier.select('bts');
    await notifier.selectMember('정국');

    final result = await container.read(myIdolMemberNameProvider.future);
    expect(result, '정국');
  });

  test('should persist member name to SharedPreferences', () async {
    final notifier = container.read(myIdolNotifierProvider.notifier);
    await container.read(myIdolNotifierProvider.future);
    await notifier.selectMember('원필');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('my_idol_member_name'), '원필');
  });

  test('should clear member name', () async {
    final notifier = container.read(myIdolNotifierProvider.notifier);
    await container.read(myIdolNotifierProvider.future);
    await notifier.selectMember('정국');
    await notifier.clearMember();

    final result = await container.read(myIdolMemberNameProvider.future);
    expect(result, isNull);
  });

  test('should clear member name when group is cleared', () async {
    final notifier = container.read(myIdolNotifierProvider.notifier);
    await container.read(myIdolNotifierProvider.future);
    await notifier.select('bts');
    await notifier.selectMember('정국');
    await notifier.clear();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('my_idol_member_name'), isNull);
  });

  test('should return null member when group is not set', () async {
    SharedPreferences.setMockInitialValues({
      'my_idol_member_name': '정국', // 멤버만 있고 그룹 없음
    });

    final container2 = ProviderContainer();
    addTearDown(() => container2.dispose());

    final result = await container2.read(myIdolMemberNameProvider.future);
    expect(result, isNull); // 그룹 없으면 멤버도 null
  });

  test('should load persisted member name on rebuild', () async {
    SharedPreferences.setMockInitialValues({
      'my_idol_group_id': 'bts',
      'my_idol_member_name': '정국',
    });

    final container2 = ProviderContainer();
    addTearDown(() => container2.dispose());

    final result = await container2.read(myIdolMemberNameProvider.future);
    expect(result, '정국');
  });
});
```

**Step 2: 테스트 실행 → 실패 확인**

Run: `flutter test test/presentation/providers/my_idol_provider_test.dart -v`
Expected: FAIL — `selectMember`, `clearMember`, `myIdolMemberNameProvider` 미정의

**Step 3: MyIdolNotifier에 selectMember/clearMember 추가**

`lib/presentation/providers/my_idol_provider.dart` — MyIdolNotifier 클래스에 추가:

```dart
static const _memberKey = 'my_idol_member_name';

/// 멤버명을 저장한다.
Future<void> selectMember(String memberName) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_memberKey, memberName);
  } catch (e) {
    debugPrint('MyIdolNotifier: save member failed — $e');
  }
}

/// 멤버명을 삭제한다.
Future<void> clearMember() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_memberKey);
  } catch (e) {
    debugPrint('MyIdolNotifier: clear member failed — $e');
  }
}
```

`clear()` 메서드에 멤버 삭제 추가:

```dart
Future<void> clear() async {
  try {
    await future;
  } catch (_) {}
  state = const AsyncData(null);
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_memberKey);
  } catch (e) {
    debugPrint('MyIdolNotifier: clear failed — $e');
  }
}
```

**Step 4: myIdolMemberNameProvider 추가**

같은 파일 하단에:

```dart
/// 현재 설정된 멤버명.
///
/// 멤버 전용 템플릿 치환에 사용. 그룹 미설정이면 null 반환.
@riverpod
Future<String?> myIdolMemberName(MyIdolMemberNameRef ref) async {
  final groupId = await ref.watch(myIdolNotifierProvider.future);
  if (groupId == null) return null;

  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  return prefs.getString('my_idol_member_name');
}
```

**Step 5: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 6: 테스트 통과 확인**

Run: `flutter test test/presentation/providers/my_idol_provider_test.dart -v`
Expected: ALL PASS

**Step 7: 커밋**

```bash
git add lib/presentation/providers/my_idol_provider.dart \
  lib/presentation/providers/my_idol_provider.g.dart \
  test/presentation/providers/my_idol_provider_test.dart
git commit -m "feat: add member name support to MyIdolNotifier"
```

---

## Task 3: 멤버 전용 템플릿 문구 JSON 추가

**Files:**
- Modify: `assets/phrases/my_idol_pack.json`

**Step 1: 기존 10개 그룹 템플릿 뒤에 6개 멤버 템플릿 추가**

`phrases` 배열 끝에 추가:

```json
{
  "ko": "{{member_name}} 사랑해!",
  "roman": "{{member_name}} saranghae!",
  "context": "Template: express love to specific member",
  "tags": ["love"],
  "translations": {
    "en": "I love you, {{member_name}}!",
    "id": "Aku cinta {{member_name}}!",
    "th": "รัก {{member_name}}!",
    "pt": "Te amo, {{member_name}}!",
    "es": "¡Te amo, {{member_name}}!",
    "vi": "Yêu {{member_name}}!"
  },
  "situation": "daily",
  "is_template": true
},
{
  "ko": "{{member_name}} 생일 축하해!",
  "roman": "{{member_name}} saengil chukahae!",
  "context": "Template: birthday wishes to specific member",
  "tags": ["birthday"],
  "translations": {
    "en": "Happy birthday, {{member_name}}!",
    "id": "Selamat ulang tahun, {{member_name}}!",
    "th": "สุขสันต์วันเกิด {{member_name}}!",
    "pt": "Feliz aniversário, {{member_name}}!",
    "es": "¡Feliz cumpleaños, {{member_name}}!",
    "vi": "Chúc mừng sinh nhật {{member_name}}!"
  },
  "situation": "birthday",
  "is_template": true
},
{
  "ko": "{{member_name}} 오늘도 고마워",
  "roman": "{{member_name}} oneuldo gomawo",
  "context": "Template: thank specific member",
  "tags": ["daily"],
  "translations": {
    "en": "Thank you as always, {{member_name}}",
    "id": "Terima kasih selalu, {{member_name}}",
    "th": "ขอบคุณเสมอนะ {{member_name}}",
    "pt": "Obrigado como sempre, {{member_name}}",
    "es": "Gracias como siempre, {{member_name}}",
    "vi": "Cảm ơn như mọi ngày, {{member_name}}"
  },
  "situation": "daily",
  "is_template": true
},
{
  "ko": "{{member_name}} 화이팅!",
  "roman": "{{member_name}} hwaiting!",
  "context": "Template: cheer for specific member",
  "tags": ["cheer"],
  "translations": {
    "en": "Go {{member_name}}!",
    "id": "Semangat {{member_name}}!",
    "th": "สู้ๆ {{member_name}}!",
    "pt": "Força {{member_name}}!",
    "es": "¡Ánimo {{member_name}}!",
    "vi": "Cố lên {{member_name}}!"
  },
  "situation": "support",
  "is_template": true
},
{
  "ko": "{{group_name}}의 {{member_name}} 최고!",
  "roman": "{{group_name}}ui {{member_name}} choego!",
  "context": "Template: member of group is the best",
  "tags": ["cheer", "love"],
  "translations": {
    "en": "{{member_name}} of {{group_name}} is the best!",
    "id": "{{member_name}} dari {{group_name}} yang terbaik!",
    "th": "{{member_name}} แห่ง {{group_name}} เก่งที่สุด!",
    "pt": "{{member_name}} do {{group_name}} é o melhor!",
    "es": "¡{{member_name}} de {{group_name}} es lo mejor!",
    "vi": "{{member_name}} của {{group_name}} là nhất!"
  },
  "situation": "daily",
  "is_template": true
},
{
  "ko": "{{member_name}} 보고 싶어!",
  "roman": "{{member_name}} bogo sipeo!",
  "context": "Template: miss specific member",
  "tags": ["love", "emotional"],
  "translations": {
    "en": "I miss you, {{member_name}}!",
    "id": "Kangen {{member_name}}!",
    "th": "คิดถึง {{member_name}}!",
    "pt": "Sinto sua falta, {{member_name}}!",
    "es": "¡Te extraño, {{member_name}}!",
    "vi": "Nhớ {{member_name}} quá!"
  },
  "situation": "daily",
  "is_template": true
}
```

**Step 2: 기존 테스트 통과 확인**

Run: `flutter test`
Expected: 기존 337 tests ALL PASS (JSON은 위젯 테스트에서 mock되므로 무영향)

**Step 3: 커밋**

```bash
git add assets/phrases/my_idol_pack.json
git commit -m "feat: add 6 member template phrases with {{member_name}}"
```

---

## Task 4: UI Strings 추가

**Files:**
- Modify: `lib/presentation/constants/ui_strings.dart`

**Step 1: 멤버 관련 문자열 추가**

`// 마이 아이돌` 섹션에 추가:

```dart
static const idolMemberHint = '멤버 이름 (선택사항)';
static const idolMemberLabel = '최애 멤버';

/// 멤버 칩 레이블. 예: '♡ 정국'.
static String phrasesMemberChip(String name) => '♡ $name';

/// 멤버 설정 시 그룹 칩 레이블 (♡ 없음).
static String phrasesGroupChip(String name) => name;

static const phrasesMemberEmpty = '멤버 전용 문구가 없습니다';
```

**Step 2: 커밋**

```bash
git add lib/presentation/constants/ui_strings.dart
git commit -m "feat: add member personalization UI strings"
```

---

## Task 5: IdolSelectScreen 멤버명 입력 필드

**Files:**
- Modify: `lib/presentation/screens/idol_select_screen.dart`
- Create: `test/presentation/screens/idol_select_screen_test.dart`

**핵심 변경:** 프리셋 그룹 탭 시 즉시 confirm 대신, 선택 → 멤버 입력(선택사항) → 확인 버튼 플로우.

**Step 1: 위젯 테스트 작성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/idol_group.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/screens/idol_select_screen.dart';

const _testGroups = [
  IdolGroup(id: 'bts', nameEn: 'BTS', nameKo: '방탄소년단'),
  IdolGroup(id: 'blackpink', nameEn: 'BLACKPINK', nameKo: '블랙핑크'),
];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildSubject({bool isOnboarding = false}) {
    return ProviderScope(
      overrides: [
        availableGroupsProvider.overrideWith((ref) async => _testGroups),
      ],
      child: MaterialApp(
        home: IdolSelectScreen(isOnboarding: isOnboarding),
      ),
    );
  }

  group('IdolSelectScreen member input', () {
    testWidgets('should show member input field after group selected',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.idolMemberHint), findsOneWidget);
    });

    testWidgets('should show confirm button after group selected',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.idolSelectConfirm), findsOneWidget);
    });

    testWidgets('should not show member input before group selected',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.idolMemberHint), findsNothing);
    });

    testWidgets('should save member name when entered and confirmed',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // 그룹 선택
      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      // 멤버명 입력
      await tester.enterText(
        find.widgetWithText(TextField, UiStrings.idolMemberHint),
        '정국',
      );

      // 확인
      await tester.tap(find.text(UiStrings.idolSelectConfirm));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('my_idol_group_id'), 'bts');
      expect(prefs.getString('my_idol_member_name'), '정국');
    });

    testWidgets('should clear member name when confirmed without input',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'my_idol_member_name': '이전멤버',
      });

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      // 멤버 입력 안 하고 확인
      await tester.tap(find.text(UiStrings.idolSelectConfirm));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('my_idol_member_name'), isNull);
    });

    testWidgets('should pre-populate member name from prefs',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'my_idol_group_id': 'bts',
        'my_idol_member_name': '정국',
      });

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // 그룹 선택하면 기존 멤버명이 채워져 있어야 함
      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextField, '정국'),
        findsOneWidget,
      );
    });
  });
}
```

**Step 2: 테스트 실행 → 실패 확인**

Run: `flutter test test/presentation/screens/idol_select_screen_test.dart -v`
Expected: FAIL

**Step 3: IdolSelectScreen 수정**

`lib/presentation/screens/idol_select_screen.dart` 주요 변경:

1. `_memberController` 필드 추가
2. `initState`에서 기존 멤버명 로드
3. `_selectGroup()` → setState만 (confirm 제거)
4. 하단에 멤버 입력 필드 + 확인 버튼 추가
5. `_confirmSelection()` — 그룹 + 멤버 동시 저장

```dart
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

  Future<void> _loadExistingMember() async {
    final prefs = await SharedPreferences.getInstance();
    final memberName = prefs.getString('my_idol_member_name');
    if (memberName != null && mounted) {
      _memberController.text = memberName;
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  // _selectGroup: setState만, _confirm 호출 제거
  void _selectGroup(String groupId) {
    setState(() {
      _selectedGroupId = groupId;
      _isCustomInput = false;
    });
  }

  // _confirmCustom 제거 — _confirmSelection으로 통합

  // 통합 확인 핸들러
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

  @override
  Widget build(BuildContext context) {
    // ... 기존 상단 (AppBar, title, subtitle) 유지 ...

    // body Column에 추가:
    // - 기존 그룹 리스트 (Expanded)
    // - 멤버 입력 필드 (selectedGroupId != null || _isCustomInput 일 때만)
    // - 확인 버튼 (선택 완료 시)
    // - 스킵 버튼 (onboarding)
  }

  // 새로: build() 내에서 그룹 선택 후 표시되는 섹션
  Widget _buildMemberInput(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: _memberController,
        decoration: const InputDecoration(
          hintText: UiStrings.idolMemberHint,
          prefixIcon: Icon(Icons.person_outline),
          isDense: true,
        ),
      ),
    );
  }
}
```

**주의사항:**
- `_buildCustomInputTile`의 기존 확인 버튼 로직 → `_confirmSelection`으로 통합
- 그룹 선택 OR 커스텀 입력이 있을 때만 멤버 필드 + 확인 버튼 표시
- `_isCustomInput && _customController.text.trim().isEmpty` 가드 유지

**Step 4: 테스트 통과 확인**

Run: `flutter test test/presentation/screens/idol_select_screen_test.dart -v`
Expected: ALL PASS

**Step 5: 전체 테스트 확인**

Run: `flutter test`
Expected: ALL PASS

**Step 6: 커밋**

```bash
git add lib/presentation/screens/idol_select_screen.dart \
  test/presentation/screens/idol_select_screen_test.dart
git commit -m "feat: add member name input to IdolSelectScreen"
```

---

## Task 6: PhrasesScreen 멤버 칩 + 필터 로직

**Files:**
- Modify: `lib/presentation/screens/phrases_screen.dart`
- Modify: `lib/presentation/widgets/tag_filter_chips.dart`
- Test: `test/presentation/screens/phrases_screen_myidol_test.dart`
- Test: `test/presentation/widgets/tag_filter_chips_test.dart`

### 6a: TagFilterChips 멤버 칩 파라미터 추가

**Step 1: TagFilterChips 테스트 추가**

`test/presentation/widgets/tag_filter_chips_test.dart`에 추가:

```dart
group('Member chip', () {
  testWidgets('should show member chip when showMemberChip is true',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TagFilterChips(
          tags: const ['love'],
          selectedTag: null,
          onTagSelected: (_) {},
          showMemberChip: true,
          isMemberSelected: false,
          onMemberSelected: () {},
          memberLabel: '♡ 정국',
        ),
      ),
    ));

    expect(find.text('♡ 정국'), findsOneWidget);
  });

  testWidgets('should not show member chip when showMemberChip is false',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TagFilterChips(
          tags: const ['love'],
          selectedTag: null,
          onTagSelected: (_) {},
          showMemberChip: false,
        ),
      ),
    ));

    expect(find.text('♡ 정국'), findsNothing);
  });

  testWidgets('should place member chip before idol chip',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TagFilterChips(
          tags: const ['love'],
          selectedTag: null,
          onTagSelected: (_) {},
          showMyIdolChip: true,
          isMyIdolSelected: false,
          onMyIdolSelected: () {},
          myIdolLabel: 'BTS',
          showMemberChip: true,
          isMemberSelected: true,
          onMemberSelected: () {},
          memberLabel: '♡ 정국',
        ),
      ),
    ));

    // 멤버 칩이 아이돌 칩보다 먼저 (좌측)
    final memberChip = tester.getTopLeft(find.text('♡ 정국'));
    final idolChip = tester.getTopLeft(find.text('BTS'));
    expect(memberChip.dx, lessThan(idolChip.dx));
  });

  testWidgets('should call onMemberSelected when member chip tapped',
      (tester) async {
    var called = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TagFilterChips(
          tags: const ['love'],
          selectedTag: null,
          onTagSelected: (_) {},
          showMemberChip: true,
          isMemberSelected: false,
          onMemberSelected: () => called = true,
          memberLabel: '♡ 정국',
        ),
      ),
    ));

    await tester.tap(find.text('♡ 정국'));
    expect(called, isTrue);
  });
});
```

**Step 2: TagFilterChips에 멤버 칩 파라미터 추가**

`lib/presentation/widgets/tag_filter_chips.dart`:

```dart
/// 멤버 칩 표시 여부.
final bool showMemberChip;

/// 멤버 칩 선택 상태.
final bool isMemberSelected;

/// 멤버 칩 탭 콜백.
final VoidCallback? onMemberSelected;

/// 멤버 칩 레이블. 예: '♡ 정국'.
final String? memberLabel;
```

생성자에 추가:

```dart
const TagFilterChips({
  // ... 기존 ...
  this.showMemberChip = false,
  this.isMemberSelected = false,
  this.onMemberSelected,
  this.memberLabel,
});
```

`build()` — children 순서:

```dart
children: [
  // 1. 멤버 칩 (전체 앞에 배치)
  if (showMemberChip)
    Padding(
      padding: const EdgeInsets.only(right: 8),
      child: _buildChip(
        context,
        label: memberLabel ?? UiStrings.idolMemberLabel,
        selected: isMemberSelected,
        onSelected: (_) => onMemberSelected?.call(),
        primary: primary,
        theme: theme,
      ),
    ),
  // 2. 마이아이돌 칩
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
  // 3. 전체 칩 (selected 조건 업데이트)
  Padding(
    padding: const EdgeInsets.only(right: 8),
    child: _buildChip(
      context,
      label: UiStrings.tagAll,
      selected: !isMyIdolSelected && !isMemberSelected && selectedTag == null,
      onSelected: (_) => onTagSelected(null),
      primary: primary,
      theme: theme,
    ),
  ),
  // 4. 태그 칩들 (selected 조건 업데이트)
  ...tags.map(
    (tag) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: _buildChip(
        context,
        label: _tagLabels[tag] ?? tag,
        selected: !isMyIdolSelected && !isMemberSelected && selectedTag == tag,
        onSelected: (_) => onTagSelected(tag),
        primary: primary,
        theme: theme,
      ),
    ),
  ),
],
```

### 6b: PhrasesScreen 멤버 필터 로직

**Step 3: PhrasesScreen 테스트 추가**

`test/presentation/screens/phrases_screen_myidol_test.dart`에 멤버 테스트 추가:

```dart
group('Member personalization', () {
  // 테스트 셋업: myIdolDisplayNameProvider + myIdolMemberNameProvider + allPhrasesProvider override

  testWidgets('should show member chip when member is set',
      (tester) async {
    // myIdolDisplayNameProvider → 'BTS'
    // myIdolMemberNameProvider → '정국'
    // → '♡ 정국' 칩 + 'BTS' 칩 표시
    // expect(find.text('♡ 정국'), findsOneWidget);
    // expect(find.text('BTS'), findsOneWidget);
  });

  testWidgets('should default to member chip when member is set',
      (tester) async {
    // 멤버 설정 → 기본 랜딩 = 멤버 칩
  });

  testWidgets('should show member-only phrases when member chip selected',
      (tester) async {
    // {{member_name}} 포함 문구만 표시, 치환 확인
  });

  testWidgets('should show group-only phrases when group chip selected',
      (tester) async {
    // {{group_name}}만 포함 ({{member_name}} 미포함) 문구 표시
  });

  testWidgets('should not show member chip when member not set',
      (tester) async {
    // myIdolMemberNameProvider → null
    // 기존 동작 유지 (♡ BTS 칩만)
  });
});
```

**Step 4: PhrasesScreen 수정**

`lib/presentation/screens/phrases_screen.dart`:

새 sentinel 추가:

```dart
const _filterMyMember = '__my_member__';
```

`build()` 내 멤버 상태 추적:

```dart
final memberNameAsync = ref.watch(myIdolMemberNameProvider);
final memberName = memberNameAsync.valueOrNull;
final hasMember = memberName != null;

final isMemberSelected =
    selectedTag == _filterMyMember || (selectedTag == null && hasMember);
final isMyIdolSelected =
    selectedTag == _filterMyIdol || (selectedTag == null && hasIdol && !hasMember);
final isAllSelected =
    selectedTag == _filterAll || (selectedTag == null && !hasIdol);
```

TagFilterChips 호출 업데이트:

```dart
TagFilterChips(
  tags: _availableTags,
  selectedTag: isMemberSelected || isMyIdolSelected || isAllSelected
      ? null
      : selectedTag,
  onTagSelected: (tag) {
    if (tag == null) {
      ref.read(selectedTagProvider.notifier).state =
          hasIdol ? _filterAll : null;
    } else {
      ref.read(selectedTagProvider.notifier).state = tag;
    }
  },
  // 멤버 칩
  showMemberChip: hasMember,
  isMemberSelected: isMemberSelected,
  onMemberSelected: () =>
      ref.read(selectedTagProvider.notifier).state = _filterMyMember,
  memberLabel:
      hasMember ? UiStrings.phrasesMemberChip(memberName) : null,
  // 그룹 칩 (멤버 있으면 ♡ 없이, 없으면 ♡ 포함)
  showMyIdolChip: hasIdol,
  isMyIdolSelected: isMyIdolSelected,
  onMyIdolSelected: () =>
      ref.read(selectedTagProvider.notifier).state = _filterMyIdol,
  myIdolLabel: hasIdol
      ? (hasMember
          ? UiStrings.phrasesGroupChip(idolName!)
          : UiStrings.phrasesMyIdolChip(idolName!))
      : null,
),
```

Expanded child 업데이트:

```dart
Expanded(
  child: isMemberSelected
      ? _buildMyMemberPhrases(ref, idolName, memberName)
      : isMyIdolSelected
          ? _buildMyIdolPhrases(ref, idolName, memberName: memberName)
          : isAllSelected
              ? _buildAllPhrases(ref)
              : _buildFilteredPhrases(ref, selectedTag!),
),
```

새 메서드 `_buildMyMemberPhrases`:

```dart
/// 멤버 전용 문구 표시 ({{member_name}} 포함 템플릿만).
Widget _buildMyMemberPhrases(
    WidgetRef ref, String? idolName, String? memberName) {
  if (idolName == null || memberName == null) {
    return const Center(child: Text(UiStrings.phrasesMemberEmpty));
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
        return const Center(child: Text(UiStrings.phrasesMemberEmpty));
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
```

기존 `_buildMyIdolPhrases` 수정 — 멤버 설정 시 그룹 전용만:

```dart
Widget _buildMyIdolPhrases(WidgetRef ref, String? idolName,
    {String? memberName}) {
  if (idolName == null) {
    return const Center(child: Text(UiStrings.phrasesMyIdolEmpty));
  }

  final packsAsync = ref.watch(allPhrasesProvider);

  return packsAsync.when(
    data: (packs) {
      final phrases = packs
          .where((p) => p.isFree)
          .expand((p) => p.phrases)
          .where((p) => p.isTemplate)
          .where((p) => !needsMemberName(p) || memberName == null)
          .map((p) => resolveTemplatePhrase(p, idolName))
          .toList();
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
```

**Step 5: 테스트 통과 확인**

Run: `flutter test test/presentation/screens/phrases_screen_myidol_test.dart test/presentation/widgets/tag_filter_chips_test.dart -v`
Expected: ALL PASS

**Step 6: 커밋**

```bash
git add lib/presentation/screens/phrases_screen.dart \
  lib/presentation/widgets/tag_filter_chips.dart \
  test/presentation/screens/phrases_screen_myidol_test.dart \
  test/presentation/widgets/tag_filter_chips_test.dart
git commit -m "feat: add member chip and filter to PhrasesScreen"
```

---

## Task 7: 버블 compact_phrase_filter 멤버 지원

**Files:**
- Modify: `lib/presentation/providers/compact_phrase_filter_provider.dart`
- Test: `test/presentation/providers/compact_phrase_filter_provider_test.dart`

**핵심:** 버블의 myIdol 칩은 그룹+멤버 통합 표시 (PhrasesScreen처럼 분리하지 않음).

**Step 1: 테스트 추가**

기존 `_buildMyIdolPhrases` 테스트 그룹에 추가:

```dart
test('should include member templates when memberName is set', () async {
  SharedPreferences.setMockInitialValues({
    'compact_phrase_filter': 'my_idol',
    'my_idol_group_id': 'custom:BTS',
    'my_idol_member_name': '정국',
  });

  // allPhrasesProvider override에 {{member_name}} 포함 문구 추가
  // → filteredCompactPhrases에 멤버 문구 포함 확인

  final phrases = await container.read(filteredCompactPhrasesProvider.future);
  // 그룹 템플릿 + 멤버 템플릿 모두 포함
  expect(
    phrases.any((p) => p.ko.contains('정국')),
    isTrue,
  );
});

test('should exclude member templates when memberName is null', () async {
  SharedPreferences.setMockInitialValues({
    'compact_phrase_filter': 'my_idol',
    'my_idol_group_id': 'custom:BTS',
    // my_idol_member_name 없음
  });

  final phrases = await container.read(filteredCompactPhrasesProvider.future);
  // {{member_name}} 원문이 노출되면 안 됨
  expect(
    phrases.any((p) => p.ko.contains('{{member_name}}')),
    isFalse,
  );
});
```

**Step 2: _buildMyIdolPhrases 수정**

`lib/presentation/providers/compact_phrase_filter_provider.dart`:

```dart
Future<List<Phrase>> _buildMyIdolPhrases(FilteredCompactPhrasesRef ref) async {
  final idolName = await ref.watch(myIdolDisplayNameProvider.future);
  if (idolName == null) return [];

  final memberName = await ref.watch(myIdolMemberNameProvider.future);
  final packs = await ref.watch(allPhrasesProvider.future);
  final templates = packs
      .expand((p) => p.phrases)
      .where((p) => p.isTemplate)
      .where((p) => !needsMemberName(p) || memberName != null)
      .toList();

  return templates
      .map((p) => resolveTemplatePhrase(p, idolName, memberName: memberName))
      .toList();
}
```

import 추가:

```dart
import 'package:fangeul/presentation/providers/template_phrase_provider.dart';
// needsMemberName은 이미 resolveTemplatePhrase와 같은 파일
```

**Step 3: 테스트 통과 확인**

Run: `flutter test test/presentation/providers/compact_phrase_filter_provider_test.dart -v`
Expected: ALL PASS

**Step 4: 커밋**

```bash
git add lib/presentation/providers/compact_phrase_filter_provider.dart \
  test/presentation/providers/compact_phrase_filter_provider_test.dart
git commit -m "feat: support member name in bubble myIdol phrases"
```

---

## Task 8: 통합 검증 + 정리

**Step 1: 전체 테스트**

Run: `flutter test`
Expected: ALL PASS (기존 337 + 새 테스트)

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: No issues

**Step 3: 포맷 검증**

Run: `dart format --set-exit-if-changed .`
Expected: No changes needed

**Step 4: 핸드오프 문서 갱신**

`docs/HANDOFF.md` 업데이트:
- 완료된 마일스톤에 "Phase B: 멤버 레벨 개인화" 추가
- 세션 히스토리 갱신
- 다음 단계: Phase 6 수익화

**Step 5: 최종 커밋**

```bash
git add docs/HANDOFF.md
git commit -m "chore: session handoff — Phase B 멤버 개인화 완료"
```

---

## 칩 바 상태 정리

| 조건 | 칩 순서 | 기본 선택 |
|------|---------|-----------|
| 멤버+그룹 설정 | `[♡ 원필] [BTS] [전체] [태그...]` | ♡ 원필 (멤버 칩) |
| 그룹만 설정 | `[♡ BTS] [전체] [태그...]` | ♡ BTS (그룹 칩) |
| 미설정 | `[전체] [태그...]` | 전체 |

## Sentinel 값 정리

| sentinel | 의미 |
|----------|------|
| `null` | 자동 (멤버→member, 그룹→idol, 미설정→all) |
| `__my_member__` | 멤버 전용 문구 |
| `__my_idol__` | 그룹 문구 (멤버 시 그룹만, 그룹만 시 전체 템플릿) |
| `__all__` | 전체 (아이돌 유저의 명시 선택) |
| `'love'` 등 | 태그 필터 |
