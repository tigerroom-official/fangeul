# TTS 문구 재생 기능 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 문구 카드에 🔊 재생 버튼을 추가하여 R2 CDN의 mp3를 재생하고, 허니문/제한/보상형/IAP 수익화 퍼널을 완성한다.

**Architecture:** Phrase JSON에 `audioId` 필드 추가 → `TtsService`에 R2 URL 구성 + 로컬 캐싱 → PhraseCard/CompactPhraseList에 🔊 버튼 → `playTtsProvider`로 재생+카운터 → 제한 도달 시 보상형/IAP CTA 팝업.

**Tech Stack:** just_audio, path_provider, Cloudflare R2 (`tts.tigerroom.app`), Riverpod, freezed

---

## 파일 구조

| 작업 | 파일 | 역할 |
|------|------|------|
| 수정 | `assets/phrases/*.json` (5개) | audioId 필드 추가 |
| 수정 | `lib/core/entities/phrase.dart` | audioId 필드 추가 |
| 수정 | `lib/services/tts_service.dart` | R2 URL 구성 + 로컬 캐싱 |
| 수정 | `lib/presentation/providers/tts_provider.dart` | 중복 매핑 + 같은문구 재재생 스킵 |
| 수정 | `lib/presentation/providers/monetization_provider.dart` | 보상형 TTS 보너스 메서드 |
| 수정 | `lib/presentation/widgets/phrase_card.dart` | 🔊 버튼 + 재생 애니메이션 |
| 수정 | `lib/presentation/widgets/compact_phrase_list.dart` | 버블용 🔊 버튼 |
| 신규 | `lib/presentation/widgets/tts_limit_popup.dart` | 제한 도달 팝업 (보상형 + IAP CTA) |
| 수정 | `lib/core/entities/remote_config_values.dart` | ttsRewardedBonus 필드 추가 |
| 수정 | `lib/services/firebase_remote_config_service.dart` | tts_rewarded_bonus RC 연동 |
| 수정 | 8개 arb 파일 | TTS 제한 관련 다국어 문자열 |

---

### Task 1: Phrase JSON에 audioId 추가

**Files:**
- Modify: `assets/phrases/basic_love.json`
- Modify: `assets/phrases/birthday_pack.json`
- Modify: `assets/phrases/comeback_pack.json`
- Modify: `assets/phrases/daily_pack.json`
- Modify: `assets/phrases/my_idol_pack.json`
- Modify: `lib/core/entities/phrase.dart`

- [ ] **Step 1: Phrase entity에 audioId 필드 추가**

```dart
// lib/core/entities/phrase.dart — Phrase factory에 추가
String? audioId,  // TTS 오디오 ID (예: "love_01"). null이면 TTS 미지원.
```

- [ ] **Step 2: freezed 코드 재생성**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: 5개 JSON 파일에 audioId 추가**

스크립트로 일괄 추가. `docs/tts-phrase-list.txt` 매핑 기반:
- 비템플릿 문구: `audioId` = 목록의 audio_id 그대로
- 템플릿 문구 (중복 매핑): `idol_01` → `"audioId": "love_01"`, `idol_03` → `"audioId": "cback_01"` 등
- 템플릿 문구 (이중 변수, "의 최고!"): `audioId` = null (TTS 미지원)

- [ ] **Step 4: 기존 테스트 통과 확인**

Run: `flutter test test/core/entities/`
Expected: PASS (audioId는 optional이므로 기존 테스트 영향 없음)

- [ ] **Step 5: Commit**

```
feat: add audioId field to Phrase entity + all phrase JSONs
```

---

### Task 2: TtsService에 R2 URL 구성 + 로컬 캐싱

**Files:**
- Modify: `lib/services/tts_service.dart`

- [ ] **Step 1: TTS URL 구성 + 캐싱 로직 추가**

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

static const _baseUrl = 'https://tts.tigerroom.app/ko';

/// audioId → R2 URL. 팩 접두사로 서브폴더 결정.
static String audioUrl(String audioId) {
  final pack = audioId.split('_').first; // love, bday, cback, daily, idol
  return '$_baseUrl/$pack/$audioId.mp3';
}

/// audioId로 재생. 로컬 캐시 우선, 없으면 다운로드 후 재생.
Future<void> playById(String audioId) async {
  final file = await _cachedFile(audioId);
  if (file.existsSync()) {
    await play(file.path);  // 기존 play() 재사용
  } else {
    final url = audioUrl(audioId);
    await play(url);  // 스트리밍 재생
    _cacheInBackground(audioId, url);  // 백그라운드 캐싱
  }
}

Future<File> _cachedFile(String audioId) async {
  final dir = await getApplicationCacheDirectory();
  return File('${dir.path}/tts/$audioId.mp3');
}

Future<void> _cacheInBackground(String audioId, String url) async {
  try {
    final file = await _cachedFile(audioId);
    if (file.existsSync()) return;
    await file.parent.create(recursive: true);
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    await response.pipe(file.openWrite());
    client.close();
  } catch (_) {
    // 캐싱 실패는 무시 — 다음에 다시 스트리밍
  }
}
```

- [ ] **Step 2: 기존 play() 메서드 — 파일 경로 지원 추가**

기존 `play()`에서 `source.startsWith('/')` 도 로컬 파일로 처리:
```dart
if (source.startsWith('http')) {
  await _player!.setUrl(source);
} else if (source.startsWith('/')) {
  await _player!.setFilePath(source);
} else {
  await _player!.setAsset(source);
}
```

- [ ] **Step 3: 테스트**

Run: `flutter test test/services/`
Expected: 기존 TTS 서비스 테스트 PASS

- [ ] **Step 4: Commit**

```
feat: TtsService R2 URL routing + local mp3 caching
```

---

### Task 3: tts_provider에 중복 매핑 + 재재생 스킵

**Files:**
- Modify: `lib/presentation/providers/tts_provider.dart`

- [ ] **Step 1: 중복 audioId 매핑 상수**

```dart
/// 중복 TTS 매핑 — idol 템플릿 문구 중 다른 팩과 동일한 음성.
const _audioIdAliases = {
  'idol_01': 'love_01',
  'idol_03': 'cback_01',
  'idol_04': 'bday_01',
  'idol_07': 'love_25',
  'idol_14': 'idol_02',
};

/// audioId를 실제 오디오 파일 ID로 변환.
String resolveAudioId(String audioId) => _audioIdAliases[audioId] ?? audioId;
```

- [ ] **Step 2: playTtsProvider를 audioId 기반으로 변경**

기존 `source` 파라미터 → `audioId` 파라미터:
```dart
@riverpod
Future<bool> playTts(PlayTtsRef ref, String audioId) async {
  final resolved = resolveAudioId(audioId);
  final ttsService = ref.read(ttsServiceProvider);
  // ... 기존 허니문/카운터 로직 유지 ...
  try {
    await ttsService.playById(resolved);
    return true;
  } catch (e) {
    debugPrint('[playTts] play failed — $e');
    return false;
  }
}
```

- [ ] **Step 3: 세션 내 재재생 카운트 스킵**

`playTtsProvider` 내부에서 세션 재생 이력 추적:
```dart
/// 이번 세션에서 이미 카운트된 audioId 목록 (재재생 시 카운트 스킵)
final _sessionPlayedIds = <String>{};
```

카운터 증가 전 체크:
```dart
if (!isHoneymoon && !_sessionPlayedIds.contains(resolved)) {
  final success = await monetization.recordTtsPlay();
  if (!success) return false;
  _sessionPlayedIds.add(resolved);
}
```

- [ ] **Step 4: build_runner 재생성**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: 기존 TTS 테스트 업데이트 + 새 테스트 추가**

기존 `playTtsProvider` 테스트의 `source` → `audioId` 파라미터 변경.
추가 테스트:
- `resolveAudioId('idol_01')` → `'love_01'`
- 같은 audioId 두 번 재생 시 카운터 1회만 증가
- 다른 audioId 재생 시 카운터 증가

Run: `flutter test test/presentation/providers/tts_provider_test.dart`
Expected: ALL PASS

- [ ] **Step 6: Commit**

```
feat: audioId-based TTS playback with alias mapping + replay skip
```

---

### Task 4: PhraseCard에 🔊 재생 버튼 추가

**Files:**
- Modify: `lib/presentation/widgets/phrase_card.dart`

- [ ] **Step 1: 🔊 아이콘 버튼 추가 — 하단 액션 바**

기존 복사 버튼 앞에 TTS 버튼 삽입 (line ~100):
```dart
// TTS 재생 버튼 — audioId가 있는 문구만 표시
if (phrase.audioId != null)
  _TtsPlayButton(audioId: phrase.audioId!),
```

- [ ] **Step 2: _TtsPlayButton 위젯 구현**

```dart
class _TtsPlayButton extends ConsumerStatefulWidget {
  const _TtsPlayButton({required this.audioId});
  final String audioId;

  @override
  ConsumerState<_TtsPlayButton> createState() => _TtsPlayButtonState();
}

class _TtsPlayButtonState extends ConsumerState<_TtsPlayButton>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);
    _pulseController.repeat(reverse: true);

    final success = await ref.read(playTtsProvider(widget.audioId).future);

    if (!success && mounted) {
      // 제한 도달 — 팝업 표시
      showTtsLimitPopup(context, ref);
    }

    if (mounted) {
      _pulseController.stop();
      _pulseController.reset();
      setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.15);
        return IconButton(
          icon: Transform.scale(
            scale: _isPlaying ? scale : 1.0,
            child: Icon(
              _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
              color: _isPlaying
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          tooltip: 'Play',
          onPressed: _play,
          visualDensity: VisualDensity.compact,
        );
      },
    );
  }
}
```

- [ ] **Step 3: Commit**

```
feat: add TTS play button to PhraseCard with pulse animation
```

---

### Task 5: CompactPhraseList(버블)에도 🔊 버튼 추가

**Files:**
- Modify: `lib/presentation/widgets/compact_phrase_list.dart`

- [ ] **Step 1: _PhraseCard 위젯의 버튼 행에 TTS 버튼 추가**

PhraseCard와 동일한 `_TtsPlayButton`을 공용 위젯으로 추출하여 재사용.
`lib/presentation/widgets/tts_play_button.dart` 신규 생성 → 양쪽에서 import.

- [ ] **Step 2: Commit**

```
feat: add TTS play button to compact phrase list (bubble)
```

---

### Task 6: TTS 제한 팝업 (보상형 + IAP CTA)

**Files:**
- Create: `lib/presentation/widgets/tts_limit_popup.dart`
- Modify: `lib/core/entities/remote_config_values.dart`
- Modify: `lib/services/firebase_remote_config_service.dart`
- Modify: `lib/presentation/providers/monetization_provider.dart`
- Modify: 8개 arb 파일

- [ ] **Step 1: RC에 ttsRewardedBonus 추가**

`remote_config_values.dart`:
```dart
this.ttsRewardedBonus = 2,
```

`firebase_remote_config_service.dart` setDefaults:
```dart
'tts_rewarded_bonus': 2,
```

값 읽기:
```dart
ttsRewardedBonus: _rc.getInt('tts_rewarded_bonus'),
```

- [ ] **Step 2: MonetizationNotifier에 보상형 TTS 보너스 메서드**

```dart
/// 보상형 시청 후 TTS 보너스 횟수 추가.
Future<void> addTtsRewardedBonus(int bonus) async {
  final current = state.valueOrNull;
  if (current == null) return;
  final updated = current.copyWith(
    ttsPlayCount: (current.ttsPlayCount - bonus).clamp(0, 999),
  );
  await _updateState(updated);
}
```

(카운트를 줄이는 방식 — 잔여 횟수가 늘어나는 효과)

- [ ] **Step 3: arb 키 추가 (8개 언어)**

```
ttsLimitTitle: "오늘 재생 횟수를 다 사용했어요"
ttsLimitRewarded: "광고 보고 {count}회 더 듣기"
ttsLimitIap: "무제한 해금"
ttsLimitTomorrow: "내일 다시 들을 수 있어요"
ttsRemainingCount: "오늘 {remaining}/{total}회"
```

- [ ] **Step 4: TTS 제한 팝업 위젯**

```dart
Future<void> showTtsLimitPopup(BuildContext context, WidgetRef ref) {
  final l = L.of(context);
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.ttsLimitTitle),
      content: Text(l.ttsLimitTomorrow),
      actions: [
        // 보상형 버튼
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _showRewardedForTts(context, ref);
          },
          child: Text(l.ttsLimitRewarded(ref.read(remoteConfigValuesProvider).ttsRewardedBonus)),
        ),
        // IAP 버튼
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // 테마 피커 시트 열기 (IAP CTA)
          },
          child: Text(l.ttsLimitIap),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 5: 보상형 → TTS 보너스 연동**

```dart
Future<void> _showRewardedForTts(BuildContext context, WidgetRef ref) async {
  final adService = ref.read(adServiceProvider);
  if (!adService.isRewardedReady) {
    adService.preloadRewarded();
    return;
  }
  await adService.showRewarded(
    onRewarded: () {
      final bonus = ref.read(remoteConfigValuesProvider).ttsRewardedBonus;
      ref.read(monetizationNotifierProvider.notifier).addTtsRewardedBonus(bonus);
    },
  );
}
```

- [ ] **Step 6: Commit**

```
feat: TTS limit popup with rewarded ad bonus + IAP CTA
```

---

### Task 7: IAP 구매 시 TTS 무제한 연동

**Files:**
- Modify: `lib/presentation/providers/tts_provider.dart`

- [ ] **Step 1: canPlayTts에 IAP 체크 추가**

`canPlayTtsProvider` 수정:
```dart
// 허니문 OR IAP 구매 → 무제한
final monState = asyncState.valueOrNull;
final hasIap = (monState?.hasThemePicker ?? false) || (monState?.hasThemeSlots ?? false);
if (isHoneymoon || hasIap) return true;
```

`playTtsProvider`도 동일:
```dart
if (!isHoneymoon && !hasIap && !_sessionPlayedIds.contains(resolved)) {
  // 카운터 증가
}
```

- [ ] **Step 2: 기존 IAP 테스트에 TTS 무제한 케이스 추가**

```dart
test('should allow unlimited TTS when IAP purchased', () async {
  // hasThemePicker = true → canPlayTts = true regardless of count
});
```

- [ ] **Step 3: Commit**

```
feat: IAP purchase unlocks unlimited TTS playback
```

---

### Task 8: 카운터 UI (허니문 ∞ / Day 14+ N/5)

**Files:**
- Modify: `lib/presentation/widgets/tts_play_button.dart`

- [ ] **Step 1: 🔊 아이콘 옆 카운터 뱃지**

허니문 중: 표시 없음 (깔끔하게)
Day 14+ / 비IAP: `🔊 ³` — 남은 횟수 뱃지
IAP 구매: 표시 없음 (무제한)
0회: 아이콘 회색 처리

```dart
// 뱃지 로직
final monState = ref.watch(monetizationNotifierProvider).valueOrNull;
final isHoneymoon = ref.watch(isHoneymoonProvider);
final hasIap = (monState?.hasThemePicker ?? false) || (monState?.hasThemeSlots ?? false);
final showCounter = !isHoneymoon && !hasIap;
final remaining = showCounter
    ? (ref.watch(remoteConfigValuesProvider).dailyTtsLimit - (monState?.ttsPlayCount ?? 0)).clamp(0, 99)
    : null;
```

- [ ] **Step 2: Commit**

```
feat: TTS counter badge on play button (remaining/total)
```

---

### Task 9: flutter gen-l10n + 전체 테스트 + 분석

- [ ] **Step 1: l10n 재생성**

Run: `flutter gen-l10n`

- [ ] **Step 2: build_runner 재생성**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: 정적 분석**

Run: `flutter analyze`
Expected: No issues

- [ ] **Step 4: 전체 테스트**

Run: `flutter test`
Expected: ALL PASS (기존 실패 3개는 무시 — 기존 이슈)

- [ ] **Step 5: 에뮬레이터 테스트**

1. 온보딩 완료 → 문구 탭 → 🔊 탭 → R2에서 재생 확인
2. 같은 문구 재탭 → 카운터 증가 안 함 확인
3. 5회 소진 → 제한 팝업 표시 확인
4. 버블 팝업에서도 🔊 동작 확인

- [ ] **Step 6: Codex 교차 리뷰**

- [ ] **Step 7: Commit + Push**

```
chore: TTS playback feature complete — tests + analysis pass
```

---

### Task 10: 버전 범프 + AAB 빌드

- [ ] **Step 1: pubspec.yaml → v1.1.0+18**

TTS는 유저 체감 신기능이므로 minor 버전 업.

- [ ] **Step 2: AAB 빌드**

Run: `flutter build appbundle --release`

- [ ] **Step 3: Push both remotes**

- [ ] **Step 4: HANDOFF.md 업데이트**
