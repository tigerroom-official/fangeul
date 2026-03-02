# MVP 통합 (마이 아이돌 + 템플릿 문구) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 마이 아이돌 선택 + 템플릿 문구 시스템을 Fangeul MVP에 통합하여 "내 아이돌 이름이 들어간 문구"를 Day 1부터 제공한다.

**Architecture:** `Phrase` entity에 `isTemplate` 필드 추가. `MyIdolNotifier`(AsyncNotifier + SharedPreferences)가 선택 그룹명을 관리. Provider 레이어에서 `{{group_name}}` 런타임 치환. 미설정 유저에게 템플릿 문구 미노출.

**Tech Stack:** Flutter + Riverpod + freezed + SharedPreferences + GoRouter

**Design:** `docs/plans/2026-03-03-mvp-integration-design.md`

---

## Layer 1: 기반 데이터 (병렬, 의존 없음)

### Task 1: groups.json lite (5그룹 데이터)

**Files:**
- Create: `assets/groups/groups.json`
- Modify: `pubspec.yaml` (assets 경로 추가)

**Step 1: groups.json 작성**

```json
{
  "groups": [
    {
      "id": "bts",
      "name_en": "BTS",
      "name_ko": "방탄소년단"
    },
    {
      "id": "blackpink",
      "name_en": "BLACKPINK",
      "name_ko": "블랙핑크"
    },
    {
      "id": "stray_kids",
      "name_en": "Stray Kids",
      "name_ko": "스트레이 키즈"
    },
    {
      "id": "seventeen",
      "name_en": "SEVENTEEN",
      "name_ko": "세븐틴"
    },
    {
      "id": "twice",
      "name_en": "TWICE",
      "name_ko": "트와이스"
    }
  ]
}
```

**Step 2: pubspec.yaml에 assets 경로 추가**

`assets/calendar/` 아래에 추가:
```yaml
    - assets/groups/
```

**Step 3: Commit**

```bash
git add assets/groups/groups.json pubspec.yaml
git commit -m "feat: add groups.json lite (5 pilot groups)"
```

---

### Task 2: IdolGroup entity + MyIdolNotifier

**Files:**
- Create: `lib/core/entities/idol_group.dart`
- Create: `lib/presentation/providers/my_idol_provider.dart`
- Test: `test/presentation/providers/my_idol_provider_test.dart`

**Step 1: IdolGroup entity 작성**

```dart
// lib/core/entities/idol_group.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'idol_group.freezed.dart';
part 'idol_group.g.dart';

/// K-pop 그룹 기본 정보.
@freezed
class IdolGroup with _$IdolGroup {
  const factory IdolGroup({
    required String id,
    @JsonKey(name: 'name_en') required String nameEn,
    @JsonKey(name: 'name_ko') required String nameKo,
  }) = _IdolGroup;

  factory IdolGroup.fromJson(Map<String, dynamic> json) =>
      _$IdolGroupFromJson(json);
}
```

**Step 2: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 3: MyIdolNotifier provider 작성**

```dart
// lib/presentation/providers/my_idol_provider.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/idol_group.dart';

part 'my_idol_provider.g.dart';

/// 마이 아이돌 선택 Notifier.
///
/// SharedPreferences에 선택된 그룹 ID를 저장한다.
/// 듀얼 FlutterEngine 환경에서 cross-engine sync를 위해 `prefs.reload()` 수행.
@Riverpod(keepAlive: true)
class MyIdolNotifier extends _$MyIdolNotifier {
  static const _key = 'my_idol_group_id';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getString(_key);
  }

  /// 마이 아이돌 그룹을 선택한다.
  Future<void> select(String groupId) async {
    state = AsyncData(groupId);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, groupId);
    } catch (e) {
      debugPrint('MyIdolNotifier: save failed — $e');
    }
  }

  /// 마이 아이돌 선택을 초기화한다.
  Future<void> clear() async {
    state = const AsyncData(null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('MyIdolNotifier: clear failed — $e');
    }
  }
}

/// 사용 가능한 그룹 목록 (assets/groups/groups.json 로드).
@Riverpod(keepAlive: true)
Future<List<IdolGroup>> availableGroups(AvailableGroupsRef ref) async {
  final jsonStr = await rootBundle.loadString('assets/groups/groups.json');
  final data = json.decode(jsonStr) as Map<String, dynamic>;
  final list = data['groups'] as List<dynamic>;
  return list
      .map((e) => IdolGroup.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// 현재 선택된 그룹의 표시 이름 (name_en).
///
/// 템플릿 치환에 사용. 미설정 시 null.
@riverpod
Future<String?> myIdolDisplayName(MyIdolDisplayNameRef ref) async {
  final groupId = await ref.watch(myIdolNotifierProvider.future);
  if (groupId == null) return null;

  final groups = await ref.watch(availableGroupsProvider.future);
  final group = groups.where((g) => g.id == groupId).firstOrNull;
  return group?.nameEn;
}
```

**Step 4: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 5: 테스트 작성**

```dart
// test/presentation/providers/my_idol_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/my_idol_provider.dart';

void main() {
  group('MyIdolNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should return null when no idol selected', () async {
      final result = await container.read(myIdolNotifierProvider.future);
      expect(result, isNull);
    });

    test('should return group id after select', () async {
      final notifier = container.read(myIdolNotifierProvider.notifier);
      // build 완료 대기
      await container.read(myIdolNotifierProvider.future);

      await notifier.select('bts');
      final result = await container.read(myIdolNotifierProvider.future);
      expect(result, 'bts');
    });

    test('should persist selection to SharedPreferences', () async {
      final notifier = container.read(myIdolNotifierProvider.notifier);
      await container.read(myIdolNotifierProvider.future);

      await notifier.select('blackpink');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('my_idol_group_id'), 'blackpink');
    });

    test('should return null after clear', () async {
      final notifier = container.read(myIdolNotifierProvider.notifier);
      await container.read(myIdolNotifierProvider.future);

      await notifier.select('bts');
      await notifier.clear();

      final result = await container.read(myIdolNotifierProvider.future);
      expect(result, isNull);
    });

    test('should load persisted selection on rebuild', () async {
      SharedPreferences.setMockInitialValues(
          {'my_idol_group_id': 'seventeen'});

      final container2 = ProviderContainer();
      addTearDown(() => container2.dispose());

      final result = await container2.read(myIdolNotifierProvider.future);
      expect(result, 'seventeen');
    });
  });
}
```

**Step 6: 테스트 실행**

Run: `flutter test test/presentation/providers/my_idol_provider_test.dart -v`
Expected: 5 tests PASS

**Step 7: Commit**

```bash
git add lib/core/entities/idol_group.dart lib/core/entities/idol_group.freezed.dart lib/core/entities/idol_group.g.dart lib/presentation/providers/my_idol_provider.dart lib/presentation/providers/my_idol_provider.g.dart test/presentation/providers/my_idol_provider_test.dart
git commit -m "feat: add IdolGroup entity + MyIdolNotifier provider"
```

---

### Task 3: Phrase.isTemplate 필드 추가

**Files:**
- Modify: `lib/core/entities/phrase.dart`
- Test: `test/core/entities/phrase_test.dart` (기존 파일에 추가)

**Step 1: Phrase entity에 isTemplate 필드 추가**

`lib/core/entities/phrase.dart`의 `situation` 필드 다음에 추가:

```dart
    /// 템플릿 문구 여부. true이면 {{group_name}} 등 치환 슬롯 포함.
    @JsonKey(name: 'is_template') @Default(false) bool isTemplate,
```

**Step 2: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 3: 테스트 추가**

기존 phrase 테스트 파일에 추가:

```dart
test('should parse isTemplate field from JSON', () {
  final json = {
    'ko': '{{group_name}} 컴백 축하해요!',
    'roman': '{{group_name}} keombaek chukahaeyo!',
    'context': 'Template: comeback congratulations',
    'tags': ['comeback'],
    'translations': {'en': 'Congratulations on {{group_name}} comeback!'},
    'situation': 'comeback',
    'is_template': true,
  };
  final phrase = Phrase.fromJson(json);
  expect(phrase.isTemplate, true);
  expect(phrase.ko, contains('{{group_name}}'));
});

test('should default isTemplate to false', () {
  final json = {
    'ko': '사랑해요',
    'roman': 'saranghaeyo',
    'context': 'Love',
    'tags': <String>[],
    'translations': <String, String>{},
  };
  final phrase = Phrase.fromJson(json);
  expect(phrase.isTemplate, false);
});
```

**Step 4: 테스트 실행**

Run: `flutter test test/core/entities/ -v`
Expected: PASS (기존 + 신규 2개)

**Step 5: Commit**

```bash
git add lib/core/entities/phrase.dart lib/core/entities/phrase.freezed.dart lib/core/entities/phrase.g.dart test/core/entities/
git commit -m "feat: add isTemplate field to Phrase entity"
```

---

### Task 4: 템플릿 문구 JSON 작성

**Files:**
- Create: `assets/phrases/my_idol_pack.json`

**Step 1: 템플릿 문구팩 JSON 작성**

```json
{
  "id": "my_idol",
  "name": "My Idol",
  "name_ko": "내 아이돌",
  "is_free": true,
  "phrases": [
    {
      "ko": "{{group_name}} 사랑해요!",
      "roman": "{{group_name}} saranghaeyo!",
      "context": "Template: express love to your idol group",
      "tags": ["love"],
      "translations": {
        "en": "I love {{group_name}}!",
        "id": "Aku cinta {{group_name}}!",
        "th": "รัก {{group_name}}!",
        "pt": "Eu amo {{group_name}}!",
        "es": "¡Amo a {{group_name}}!",
        "vi": "Yêu {{group_name}}!"
      },
      "situation": "daily",
      "is_template": true
    },
    {
      "ko": "{{group_name}} 화이팅!",
      "roman": "{{group_name}} hwaiting!",
      "context": "Template: cheer for your idol group",
      "tags": ["cheer"],
      "translations": {
        "en": "Go {{group_name}}!",
        "id": "Semangat {{group_name}}!",
        "th": "สู้ๆ {{group_name}}!",
        "pt": "Força {{group_name}}!",
        "es": "¡Ánimo {{group_name}}!",
        "vi": "Cố lên {{group_name}}!"
      },
      "situation": "support",
      "is_template": true
    },
    {
      "ko": "{{group_name}} 컴백 축하해요!",
      "roman": "{{group_name}} keombaek chukahaeyo!",
      "context": "Template: congratulate comeback",
      "tags": ["comeback"],
      "translations": {
        "en": "Congratulations on the comeback, {{group_name}}!",
        "id": "Selamat comeback {{group_name}}!",
        "th": "ยินดีกับคัมแบ็ค {{group_name}}!",
        "pt": "Parabéns pelo comeback, {{group_name}}!",
        "es": "¡Felicidades por el comeback, {{group_name}}!",
        "vi": "Chúc mừng comeback {{group_name}}!"
      },
      "situation": "comeback",
      "is_template": true
    },
    {
      "ko": "{{group_name}} 생일 축하해요!",
      "roman": "{{group_name}} saengil chukahaeyo!",
      "context": "Template: birthday wishes",
      "tags": ["birthday"],
      "translations": {
        "en": "Happy birthday, {{group_name}}!",
        "id": "Selamat ulang tahun {{group_name}}!",
        "th": "สุขสันต์วันเกิด {{group_name}}!",
        "pt": "Feliz aniversário, {{group_name}}!",
        "es": "¡Feliz cumpleaños, {{group_name}}!",
        "vi": "Chúc mừng sinh nhật {{group_name}}!"
      },
      "situation": "birthday",
      "is_template": true
    },
    {
      "ko": "{{group_name}} 1위 축하해요!",
      "roman": "{{group_name}} irwi chukahaeyo!",
      "context": "Template: celebrate music show win",
      "tags": ["comeback", "cheer"],
      "translations": {
        "en": "Congrats on #1, {{group_name}}!",
        "id": "Selamat juara 1, {{group_name}}!",
        "th": "ยินดีที่ได้อันดับ 1 {{group_name}}!",
        "pt": "Parabéns pelo 1º lugar, {{group_name}}!",
        "es": "¡Felicidades por el #1, {{group_name}}!",
        "vi": "Chúc mừng hạng 1 {{group_name}}!"
      },
      "situation": "comeback",
      "is_template": true
    },
    {
      "ko": "{{group_name}} 최고!",
      "roman": "{{group_name}} choego!",
      "context": "Template: express that your idol is the best",
      "tags": ["cheer", "love"],
      "translations": {
        "en": "{{group_name}} is the best!",
        "id": "{{group_name}} yang terbaik!",
        "th": "{{group_name}} เก่งที่สุด!",
        "pt": "{{group_name}} é o melhor!",
        "es": "¡{{group_name}} es lo mejor!",
        "vi": "{{group_name}} là nhất!"
      },
      "situation": "daily",
      "is_template": true
    },
    {
      "ko": "{{group_name}} 덕분에 행복해요",
      "roman": "{{group_name}} deokbune haengbokhaeyo",
      "context": "Template: express gratitude and happiness",
      "tags": ["love", "daily"],
      "translations": {
        "en": "I'm happy because of {{group_name}}",
        "id": "Aku bahagia karena {{group_name}}",
        "th": "มีความสุขเพราะ {{group_name}}",
        "pt": "Sou feliz por causa de {{group_name}}",
        "es": "Soy feliz gracias a {{group_name}}",
        "vi": "Hạnh phúc nhờ có {{group_name}}"
      },
      "situation": "daily",
      "is_template": true
    },
    {
      "ko": "{{group_name}} 오래오래 함께해요",
      "roman": "{{group_name}} oraeorae hamkkehaeyo",
      "context": "Template: wish to stay together forever",
      "tags": ["love"],
      "translations": {
        "en": "Let's be together forever, {{group_name}}",
        "id": "Mari bersama selamanya, {{group_name}}",
        "th": "อยู่ด้วยกันตลอดไปนะ {{group_name}}",
        "pt": "Vamos ficar juntos para sempre, {{group_name}}",
        "es": "Estemos juntos para siempre, {{group_name}}",
        "vi": "Hãy bên nhau mãi nhé {{group_name}}"
      },
      "situation": "daily",
      "is_template": true
    },
    {
      "ko": "{{group_name}} 콘서트 가고 싶어요!",
      "roman": "{{group_name}} konseoteu gago sipeoyo!",
      "context": "Template: express desire to attend concert",
      "tags": ["fandom"],
      "translations": {
        "en": "I want to go to {{group_name}} concert!",
        "id": "Aku mau nonton konser {{group_name}}!",
        "th": "อยากไปคอนเสิร์ต {{group_name}}!",
        "pt": "Quero ir ao show do {{group_name}}!",
        "es": "¡Quiero ir al concierto de {{group_name}}!",
        "vi": "Muốn đi concert {{group_name}} quá!"
      },
      "situation": "daily",
      "is_template": true
    },
    {
      "ko": "{{group_name}} 노래 또 듣고 있어요",
      "roman": "{{group_name}} norae tto deutgo isseoyo",
      "context": "Template: express listening to their music again",
      "tags": ["daily"],
      "translations": {
        "en": "I'm listening to {{group_name}} again",
        "id": "Aku dengerin lagu {{group_name}} lagi",
        "th": "ฟังเพลง {{group_name}} อีกแล้ว",
        "pt": "Estou ouvindo {{group_name}} de novo",
        "es": "Estoy escuchando a {{group_name}} otra vez",
        "vi": "Lại nghe nhạc {{group_name}} rồi"
      },
      "situation": "daily",
      "is_template": true
    }
  ]
}
```

**Step 2: Commit**

```bash
git add assets/phrases/my_idol_pack.json
git commit -m "feat: add my_idol template phrase pack (10 phrases)"
```

---

### Task 5: rules 수정 — 템플릿 삽입 허용

**Files:**
- Modify: `.claude/rules/00-project.md`

**Step 1: "아이돌 이름" 규칙에 템플릿 예외 추가**

`.claude/rules/00-project.md`에서 "아이돌 이름/이미지/로고 직접 사용 금지" 항목에 추가:

```markdown
- 아이돌 이름/이미지/로고 직접 사용 금지 → 초상권 + 상표권
  - **예외:** 유저 선택 기반 개인화 내 이름 사용은 **템플릿 삽입으로 허용** (`{{group_name}}` → 런타임 치환)
  - 스토어/마케팅에서는 절대 특정 아이돌 이름 사용 금지 유지
```

**Step 2: Commit**

```bash
git add .claude/rules/00-project.md
git commit -m "docs: allow idol name template insertion in rules"
```

---

## Layer 2: 핵심 로직 (Layer 1 완료 후)

### Task 6: 템플릿 치환 Provider

**Files:**
- Create: `lib/presentation/providers/template_phrase_provider.dart`
- Test: `test/presentation/providers/template_phrase_provider_test.dart`

**Step 1: 테스트 작성**

```dart
// test/presentation/providers/template_phrase_provider_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/providers/template_phrase_provider.dart';

void main() {
  group('resolveTemplatePhrases', () {
    test('should replace {{group_name}} with idol name', () {
      final phrase = Phrase(
        ko: '{{group_name}} 사랑해요!',
        roman: '{{group_name}} saranghaeyo!',
        context: 'Template love',
        isTemplate: true,
      );

      final resolved = resolveTemplatePhrase(phrase, 'BTS');
      expect(resolved.ko, 'BTS 사랑해요!');
      expect(resolved.roman, 'BTS saranghaeyo!');
      expect(resolved.isTemplate, true); // 유지
    });

    test('should replace in translations too', () {
      final phrase = Phrase(
        ko: '{{group_name}} 화이팅!',
        roman: '{{group_name}} hwaiting!',
        context: 'Template',
        translations: {'en': 'Go {{group_name}}!'},
        isTemplate: true,
      );

      final resolved = resolveTemplatePhrase(phrase, 'TWICE');
      expect(resolved.translations['en'], 'Go TWICE!');
    });

    test('should not modify non-template phrases', () {
      final phrase = Phrase(
        ko: '사랑해요',
        roman: 'saranghaeyo',
        context: 'Love',
        isTemplate: false,
      );

      final resolved = resolveTemplatePhrase(phrase, 'BTS');
      expect(resolved.ko, '사랑해요'); // 변경 없음
    });

    test('should filter template phrases when idol is null', () {
      final phrases = [
        Phrase(ko: '사랑해요', roman: 'saranghaeyo', context: 'A'),
        Phrase(ko: '{{group_name}} 화이팅!', roman: '', context: 'B', isTemplate: true),
      ];

      final filtered = filterAndResolveTemplates(phrases, null);
      expect(filtered, hasLength(1));
      expect(filtered.first.ko, '사랑해요');
    });

    test('should resolve template phrases when idol is set', () {
      final phrases = [
        Phrase(ko: '사랑해요', roman: 'saranghaeyo', context: 'A'),
        Phrase(ko: '{{group_name}} 화이팅!', roman: '{{group_name}} hwaiting!', context: 'B', isTemplate: true),
      ];

      final resolved = filterAndResolveTemplates(phrases, 'BTS');
      expect(resolved, hasLength(2));
      expect(resolved[1].ko, 'BTS 화이팅!');
    });
  });
}
```

**Step 2: 테스트 실행 (실패 확인)**

Run: `flutter test test/presentation/providers/template_phrase_provider_test.dart -v`
Expected: FAIL (함수 미정의)

**Step 3: 구현**

```dart
// lib/presentation/providers/template_phrase_provider.dart
import 'package:fangeul/core/entities/phrase.dart';

/// 템플릿 문구의 `{{group_name}}`을 실제 그룹명으로 치환한다.
///
/// [isTemplate]이 false인 문구는 그대로 반환한다.
Phrase resolveTemplatePhrase(Phrase phrase, String groupName) {
  if (!phrase.isTemplate) return phrase;

  return phrase.copyWith(
    ko: phrase.ko.replaceAll('{{group_name}}', groupName),
    roman: phrase.roman.replaceAll('{{group_name}}', groupName),
    translations: phrase.translations.map(
      (lang, text) => MapEntry(lang, text.replaceAll('{{group_name}}', groupName)),
    ),
  );
}

/// 문구 리스트에서 템플릿 문구를 필터링/치환한다.
///
/// - [idolName]이 null이면 `isTemplate == true` 문구를 제거한다.
/// - [idolName]이 있으면 `{{group_name}}`을 치환한다.
List<Phrase> filterAndResolveTemplates(List<Phrase> phrases, String? idolName) {
  if (idolName == null) {
    return phrases.where((p) => !p.isTemplate).toList();
  }

  return phrases
      .map((p) => resolveTemplatePhrase(p, idolName))
      .toList();
}
```

**Step 4: 테스트 실행 (성공 확인)**

Run: `flutter test test/presentation/providers/template_phrase_provider_test.dart -v`
Expected: 5 tests PASS

**Step 5: Commit**

```bash
git add lib/presentation/providers/template_phrase_provider.dart test/presentation/providers/template_phrase_provider_test.dart
git commit -m "feat: add template phrase resolution logic"
```

---

### Task 7: CompactPhraseFilter에 myIdol 케이스 추가 + filteredCompactPhrases 치환 통합

**Files:**
- Modify: `lib/presentation/providers/compact_phrase_filter_provider.dart`
- Modify: 관련 테스트

**Step 1: CompactPhraseFilter sealed class에 myIdol 추가**

`lib/presentation/providers/compact_phrase_filter_provider.dart`에서:

```dart
@freezed
sealed class CompactPhraseFilter with _$CompactPhraseFilter {
  const factory CompactPhraseFilter.favorites() = _Favorites;
  const factory CompactPhraseFilter.pack(String packId) = _Pack;
  const factory CompactPhraseFilter.myIdol() = _MyIdol;  // 추가
}
```

**Step 2: Notifier에 selectMyIdol 메서드 추가**

```dart
/// 마이 아이돌 필터로 전환.
Future<void> selectMyIdol() async {
  const filter = CompactPhraseFilter.myIdol();
  state = const AsyncData(filter);
  await _saveToPrefs(filter);
  ref.read(analyticsServiceProvider).logEvent(
    AnalyticsEvents.filterChange,
    {AnalyticsParams.filterType: 'my_idol'},
  );
}
```

**Step 3: _saveToPrefs에 myIdol 직렬화 추가**

```dart
final value = switch (filter) {
  _Favorites() => 'favorites',
  _Pack(:final packId) => 'pack:$packId',
  _MyIdol() => 'my_idol',  // 추가
};
```

**Step 4: build() 메서드에 my_idol 역직렬화 추가**

`if (saved.startsWith('pack:'))` 블록 바로 위에:
```dart
if (saved == 'my_idol') return const CompactPhraseFilter.myIdol();
```

**Step 5: filteredCompactPhrases에 myIdol 분기 + 치환 로직 추가**

import 추가:
```dart
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/template_phrase_provider.dart';
```

`filteredCompactPhrases` 함수의 switch에 추가:
```dart
return switch (filter) {
  _Favorites() => _buildFavoritesPhrases(ref),
  _Pack(:final packId) => _buildPackPhrases(ref, packId),
  _MyIdol() => _buildMyIdolPhrases(ref),  // 추가
};
```

새 함수 추가:
```dart
/// 마이 아이돌 템플릿 문구 목록.
///
/// isTemplate == true인 문구를 수집하고 마이 아이돌 이름으로 치환한다.
Future<List<Phrase>> _buildMyIdolPhrases(
    FilteredCompactPhrasesRef ref) async {
  final idolName = await ref.watch(myIdolDisplayNameProvider.future);
  if (idolName == null) return [];

  final packs = await ref.watch(allPhrasesProvider.future);
  final templates = packs
      .expand((p) => p.phrases)
      .where((p) => p.isTemplate)
      .toList();

  return templates
      .map((p) => resolveTemplatePhrase(p, idolName))
      .toList();
}
```

**Step 6: isSelectedPackLocked에 myIdol 분기 추가**

```dart
return switch (filter) {
  _Favorites() => false,
  _Pack(:final packId) => _isPackLocked(ref, packId),
  _MyIdol() => false,  // 추가
};
```

**Step 7: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 8: 테스트 실행**

Run: `flutter test test/ -v`
Expected: 기존 테스트 + 전부 PASS

**Step 9: Commit**

```bash
git add lib/presentation/providers/compact_phrase_filter_provider.dart lib/presentation/providers/compact_phrase_filter_provider.freezed.dart lib/presentation/providers/compact_phrase_filter_provider.g.dart
git commit -m "feat: add myIdol filter case + template resolution in compact phrases"
```

---

### Task 8: 마이 아이돌 선택 UI (온보딩 + 설정)

**Files:**
- Create: `lib/presentation/screens/idol_select_screen.dart`
- Modify: `lib/presentation/router/app_router.dart` (라우트 추가)
- Modify: `lib/main.dart` (첫 실행 시 온보딩 분기)
- Modify: `lib/presentation/screens/settings_screen.dart` (마이 아이돌 변경 섹션)
- Modify: `lib/presentation/constants/ui_strings.dart` (문자열 추가)

**Step 1: UiStrings에 마이 아이돌 관련 문자열 추가**

```dart
// 마이 아이돌
static const idolSelectTitle = '좋아하는 그룹을 선택하세요';
static const idolSelectSubtitle = '설정에서 언제든 바꿀 수 있어요';
static const idolSelectSkip = '나중에 설정하기';
static const idolSelectOther = '기타 (직접 입력)';
static const idolSelectOtherHint = '그룹 이름을 입력하세요';
static const idolSelectConfirm = '확인';
static const idolSettingLabel = '마이 아이돌';
static const idolSettingEmpty = '아직 선택하지 않았어요';
static String idolSettingCurrent(String name) => '현재: $name';
static const idolSettingChange = '변경';
```

**Step 2: IdolSelectScreen 작성**

```dart
// lib/presentation/screens/idol_select_screen.dart
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
  const IdolSelectScreen({super.key, this.isOnboarding = false});

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
      appBar: widget.isOnboarding ? null : AppBar(title: const Text(UiStrings.idolSettingLabel)),
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
                  loading: () => const Center(child: CircularProgressIndicator()),
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
                Text(UiStrings.idolSelectOther, style: theme.textTheme.titleMedium),
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
    // 커스텀 입력은 ID=name_en으로 저장, displayName으로 직접 사용
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
```

**Step 3: myIdolDisplayName에서 custom: 접두사 처리**

`lib/presentation/providers/my_idol_provider.dart`의 `myIdolDisplayName` 수정:

```dart
@riverpod
Future<String?> myIdolDisplayName(MyIdolDisplayNameRef ref) async {
  final groupId = await ref.watch(myIdolNotifierProvider.future);
  if (groupId == null) return null;

  // 커스텀 입력: "custom:그룹명" 형태
  if (groupId.startsWith('custom:')) {
    return groupId.substring(7);
  }

  final groups = await ref.watch(availableGroupsProvider.future);
  final group = groups.where((g) => g.id == groupId).firstOrNull;
  return group?.nameEn;
}
```

**Step 4: 라우터에 온보딩 경로 추가**

`lib/presentation/router/app_router.dart`에 import 추가:
```dart
import 'package:fangeul/presentation/screens/idol_select_screen.dart';
```

`/mini-converter` GoRoute 아래에 추가:
```dart
GoRoute(
  path: '/onboarding/idol-select',
  builder: (context, state) => const IdolSelectScreen(isOnboarding: true),
),
GoRoute(
  path: '/settings/idol-select',
  builder: (context, state) => const IdolSelectScreen(),
),
```

`_validInitialRoutes`에 추가:
```dart
const _validInitialRoutes = {'/home', '/mini-converter', '/onboarding/idol-select'};
```

**Step 5: main.dart에서 첫 실행 분기**

`lib/main.dart` 수정 — prefs 기반으로 온보딩 완료 여부 체크:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // 첫 실행 체크: 온보딩 미완료 시 아이돌 선택으로 시작
  final isOnboardingDone = prefs.getBool('onboarding_done') ?? false;
  if (!isOnboardingDone) {
    await prefs.setBool('onboarding_done', true);
  }

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      if (!isOnboardingDone)
        initialRouteOverrideProvider.overrideWithValue('/onboarding/idol-select'),
    ],
  );

  container.read(analyticsServiceProvider).logEvent(AnalyticsEvents.appOpen);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FangeulApp(),
    ),
  );
}
```

`lib/presentation/router/app_router.dart`에 override provider 추가:
```dart
/// 첫 실행 시 온보딩 경로를 주입하기 위한 override.
@riverpod
String? initialRouteOverride(InitialRouteOverrideRef ref) => null;
```

appRouter에서 이를 반영:
```dart
final overrideRoute = ref.read(initialRouteOverrideProvider);
final initialLocation = overrideRoute ??
    (_validInitialRoutes.contains(platformRoute) ? platformRoute : '/home');
```

**Step 6: 설정 화면에 마이 아이돌 섹션 추가**

`lib/presentation/screens/settings_screen.dart`에 import 추가:
```dart
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
```

`_BubbleToggleTile()` 바로 위에 마이 아이돌 섹션 추가:
```dart
const Divider(),
const _MyIdolTile(),
```

새 위젯:
```dart
class _MyIdolTile extends ConsumerWidget {
  const _MyIdolTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idolNameAsync = ref.watch(myIdolDisplayNameProvider);

    return ListTile(
      leading: const Icon(Icons.favorite_outline),
      title: const Text(UiStrings.idolSettingLabel),
      subtitle: idolNameAsync.when(
        data: (name) => Text(
          name != null
              ? UiStrings.idolSettingCurrent(name)
              : UiStrings.idolSettingEmpty,
        ),
        loading: () => const Text('...'),
        error: (_, __) => const Text(UiStrings.idolSettingEmpty),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/settings/idol-select'),
    );
  }
}
```

import `go_router` 추가: `import 'package:go_router/go_router.dart';`

**Step 7: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 8: Commit**

```bash
git add lib/presentation/screens/idol_select_screen.dart lib/presentation/router/app_router.dart lib/presentation/router/app_router.g.dart lib/main.dart lib/presentation/screens/settings_screen.dart lib/presentation/constants/ui_strings.dart lib/presentation/providers/my_idol_provider.dart lib/presentation/providers/my_idol_provider.g.dart
git commit -m "feat: add idol selection UI (onboarding + settings)"
```

---

### Task 9: 홈 인사말 한 줄

**Files:**
- Modify: `lib/presentation/screens/home_screen.dart`

**Step 1: 홈 화면 AppBar에 마이 아이돌 인사말 추가**

`home_screen.dart`에 import 추가:
```dart
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
```

AppBar title을 Consumer 기반으로 교체:
```dart
appBar: AppBar(
  title: Consumer(
    builder: (context, ref, _) {
      final idolName = ref.watch(myIdolDisplayNameProvider);
      return idolName.when(
        data: (name) => name != null
            ? Text('안녕하세요, $name 팬님!')
            : const Text(UiStrings.appName),
        loading: () => const Text(UiStrings.appName),
        error: (_, __) => const Text(UiStrings.appName),
      );
    },
  ),
  // ... 기존 actions 유지
),
```

**Step 2: Commit**

```bash
git add lib/presentation/screens/home_screen.dart
git commit -m "feat: add my idol greeting on home app bar"
```

---

### Task 10: 캘린더 필터 기본값 마이 아이돌 연동

**Files:**
- Modify: `lib/presentation/providers/calendar_providers.dart`

**Step 1: todaySuggestedPhrases에 마이 아이돌 필터 적용**

import 추가:
```dart
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/template_phrase_provider.dart';
```

`todaySuggestedPhrases` 수정:
```dart
@riverpod
Future<List<Phrase>> todaySuggestedPhrases(TodaySuggestedPhrasesRef ref) async {
  final events = await ref.watch(todayEventsProvider.future);
  if (events.isEmpty) return [];

  final idolName = await ref.watch(myIdolDisplayNameProvider.future);

  // 마이 아이돌 설정 시 해당 그룹 이벤트만 필터링
  final filteredEvents = idolName != null
      ? events.where((e) => e.group == idolName || e.artist == idolName).toList()
      : events;

  if (filteredEvents.isEmpty) return [];

  final situations = filteredEvents.map((e) => e.situation).toSet();
  final allPacks = await ref.watch(allPhrasesProvider.future);
  final phrases = allPacks
      .expand((p) => p.phrases)
      .where((p) => p.situation != null && situations.contains(p.situation))
      .toList();

  return filterAndResolveTemplates(phrases, idolName);
}
```

**Step 2: Commit**

```bash
git add lib/presentation/providers/calendar_providers.dart
git commit -m "feat: filter todaySuggestedPhrases by my idol group"
```

---

## Layer 3: UI 통합 (Layer 2 완료 후)

### Task 11: PackFilterChips에 "내 아이돌" 칩 추가

**Files:**
- Modify: `lib/presentation/widgets/pack_filter_chips.dart`

**Step 1: 마이 아이돌 칩 관련 속성 추가**

```dart
class PackFilterChips extends StatelessWidget {
  const PackFilterChips({
    super.key,
    required this.packs,
    required this.isFavoritesSelected,
    this.selectedPackId,
    this.onFavoritesSelected,
    this.onPackSelected,
    this.isMyIdolSelected = false,      // 추가
    this.onMyIdolSelected,              // 추가
    this.showMyIdolChip = false,        // 추가
  });

  // ... 기존 필드 유지

  final bool isMyIdolSelected;
  final VoidCallback? onMyIdolSelected;
  final bool showMyIdolChip;
```

**Step 2: build 메서드에 마이 아이돌 칩 삽입 (즐찾 다음, 팩 전)**

```dart
@override
Widget build(BuildContext context) {
  final chipCount = packs.length + 1 + (showMyIdolChip ? 1 : 0);

  return SizedBox(
    height: 36,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: chipCount,
      separatorBuilder: (_, __) => const SizedBox(width: 6),
      itemBuilder: (context, index) {
        if (index == 0) return _buildFavoritesChip(context);
        if (showMyIdolChip && index == 1) return _buildMyIdolChip(context);
        final packIndex = index - 1 - (showMyIdolChip ? 1 : 0);
        return _buildPackChip(context, packs[packIndex]);
      },
    ),
  );
}
```

**Step 3: _buildMyIdolChip 메서드 추가**

```dart
Widget _buildMyIdolChip(BuildContext context) {
  final theme = Theme.of(context);

  return FilterChip(
    label: Text(
      UiStrings.idolSettingLabel,
      style: TextStyle(
        color: isMyIdolSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
        fontWeight: isMyIdolSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
    selected: isMyIdolSelected,
    selectedColor: theme.colorScheme.primary,
    backgroundColor: theme.colorScheme.surfaceContainer,
    checkmarkColor: theme.colorScheme.onPrimary,
    showCheckmark: false,
    side: isMyIdolSelected
        ? BorderSide.none
        : BorderSide(color: theme.colorScheme.outlineVariant),
    visualDensity: VisualDensity.compact,
    onSelected: (_) => onMyIdolSelected?.call(),
  );
}
```

**Step 4: _buildFavoritesChip, _buildPackChip의 selected 판정 수정**

`_buildFavoritesChip`에서:
```dart
selected: isFavoritesSelected && !isMyIdolSelected,
```

`_buildPackChip`에서:
```dart
final isSelected = !isFavoritesSelected && !isMyIdolSelected && selectedPackId == pack.id;
```

**Step 5: UiStrings import 추가** (이미 있으면 스킵)

**Step 6: PackFilterChips를 사용하는 위젯에서 마이 아이돌 관련 props 전달**

MiniConverterScreen 또는 CompactPhraseList에서 `PackFilterChips` 호출하는 부분을 찾아서 `showMyIdolChip`, `isMyIdolSelected`, `onMyIdolSelected` 전달. 마이 아이돌 미설정 시 `showMyIdolChip: false`.

**Step 7: Commit**

```bash
git add lib/presentation/widgets/pack_filter_chips.dart
git commit -m "feat: add my idol filter chip to PackFilterChips"
```

---

### Task 12: cross-engine sync — 마이 아이돌 Provider 추가

**Files:**
- Modify: `lib/presentation/screens/mini_converter_screen.dart` (또는 버블 sync가 있는 파일)

**Step 1: _syncFromMainEngine에 myIdolNotifierProvider invalidate 추가**

버블 진입 시 `didChangeAppLifecycleState(resumed)` 또는 `_syncFromMainEngine()`에서:

```dart
ref.invalidate(myIdolNotifierProvider);
ref.invalidate(myIdolDisplayNameProvider);
```

**Step 2: Commit**

```bash
git add lib/presentation/screens/mini_converter_screen.dart
git commit -m "feat: add myIdol provider to cross-engine sync"
```

---

## Layer 4: 버블 "오늘" 칩 (Layer 3 완료 후)

### Task 13: CompactPhraseFilter에 today 케이스 + 버블 "오늘" 칩

**Files:**
- Modify: `lib/presentation/providers/compact_phrase_filter_provider.dart`

**Step 1: CompactPhraseFilter에 today 추가**

```dart
@freezed
sealed class CompactPhraseFilter with _$CompactPhraseFilter {
  const factory CompactPhraseFilter.favorites() = _Favorites;
  const factory CompactPhraseFilter.pack(String packId) = _Pack;
  const factory CompactPhraseFilter.myIdol() = _MyIdol;
  const factory CompactPhraseFilter.today() = _Today;  // 추가
}
```

**Step 2: Notifier에 selectToday 추가**

```dart
Future<void> selectToday() async {
  const filter = CompactPhraseFilter.today();
  state = const AsyncData(filter);
  await _saveToPrefs(filter);
  ref.read(analyticsServiceProvider).logEvent(
    AnalyticsEvents.filterChange,
    {AnalyticsParams.filterType: 'today'},
  );
}
```

**Step 3: 직렬화/역직렬화에 today 추가**

`_saveToPrefs`:
```dart
_Today() => 'today',
```

`build()`:
```dart
if (saved == 'today') return const CompactPhraseFilter.today();
```

**Step 4: filteredCompactPhrases에 today 분기 추가**

import 추가: `import 'package:fangeul/presentation/providers/calendar_providers.dart';`

switch에 추가:
```dart
_Today() => _buildTodayPhrases(ref),
```

```dart
Future<List<Phrase>> _buildTodayPhrases(
    FilteredCompactPhrasesRef ref) async {
  return ref.watch(todaySuggestedPhrasesProvider.future);
}
```

**Step 5: isSelectedPackLocked에 today 분기**

```dart
_Today() => false,
```

**Step 6: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 7: PackFilterChips에 "오늘" 칩 로직**

마이 아이돌 설정 + 오늘 이벤트 존재 시에만 "오늘" 칩 노출. 이 로직은 MiniConverterScreen에서 `todayEventsProvider`와 `myIdolNotifierProvider`를 watch하여 결정.

**Step 8: Commit**

```bash
git add lib/presentation/providers/compact_phrase_filter_provider.dart lib/presentation/providers/compact_phrase_filter_provider.freezed.dart lib/presentation/providers/compact_phrase_filter_provider.g.dart
git commit -m "feat: add today filter for bubble context-aware phrases"
```

---

## Layer 5: 통합 테스트

### Task 14: 전체 검증

**Step 1: 전체 테스트 실행**

Run: `flutter test`
Expected: 280+ (기존) + 신규 테스트 전부 PASS

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 포맷 검증**

Run: `dart format --set-exit-if-changed .`
Expected: 0 changed

**Step 4: 최종 커밋**

```bash
git add .
git commit -m "chore: MVP integration complete — my idol + template phrases"
```

---

## 의존 관계 요약

```
Task 1 (groups.json)     ─┐
Task 2 (MyIdolNotifier)  ─┤─→ Task 6 (치환) ─→ Task 7 (필터) ─→ Task 11 (칩) ─→ Task 13 (오늘칩)
Task 3 (isTemplate)      ─┤─→ Task 8 (UI)    → Task 9 (인사말)                    ↓
Task 4 (JSON)            ─┤                   → Task 10 (캘린더)                 Task 14 (검증)
Task 5 (rules)           ─┘                   → Task 12 (sync)  ─────────────────→↑
```

## 7일 초과 시 컷 라인

- **보존:** Task 1~8, 11~12, 14
- **v1.2 이동:** Task 9(홈 인사말), Task 10(캘린더 연동), Task 13(버블 오늘 칩)
