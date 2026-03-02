import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/providers/analytics_providers.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/phrase_providers.dart';
import 'package:fangeul/presentation/providers/calendar_providers.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/template_phrase_provider.dart';
import 'package:fangeul/services/analytics_events.dart';

part 'compact_phrase_filter_provider.freezed.dart';
part 'compact_phrase_filter_provider.g.dart';

/// 간편모드 문구 탭 필터 상태.
///
/// [favorites] — 즐겨찾기 문구만 표시 (기본).
/// [pack] — 특정 팩의 문구를 표시.
@freezed
sealed class CompactPhraseFilter with _$CompactPhraseFilter {
  const factory CompactPhraseFilter.favorites() = _Favorites;
  const factory CompactPhraseFilter.pack(String packId) = _Pack;
  const factory CompactPhraseFilter.myIdol() = _MyIdol;
  const factory CompactPhraseFilter.today() = _Today;
}

/// 간편모드 문구 필터 Notifier.
///
/// SharedPreferences에 마지막 선택 필터를 저장하여 재시작 시 복원한다.
/// 듀얼 FlutterEngine 환경에서 cross-engine sync를 위해 `prefs.reload()` 수행.
@riverpod
class CompactPhraseFilterNotifier extends _$CompactPhraseFilterNotifier {
  static const _key = 'compact_phrase_filter';

  @override
  Future<CompactPhraseFilter> build() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final saved = prefs.getString(_key);
    if (saved == null) return const CompactPhraseFilter.favorites();
    if (saved == 'favorites') return const CompactPhraseFilter.favorites();
    if (saved == 'my_idol') return const CompactPhraseFilter.myIdol();
    if (saved == 'today') return const CompactPhraseFilter.today();
    if (saved.startsWith('pack:')) {
      return CompactPhraseFilter.pack(saved.substring(5));
    }
    return const CompactPhraseFilter.favorites();
  }

  /// 즐겨찾기 필터로 전환.
  Future<void> selectFavorites() async {
    const filter = CompactPhraseFilter.favorites();
    state = const AsyncData(filter);
    await _saveToPrefs(filter);
    ref.read(analyticsServiceProvider).logEvent(
      AnalyticsEvents.filterChange,
      {AnalyticsParams.filterType: 'favorites'},
    );
  }

  /// 팩 필터로 전환.
  Future<void> selectPack(String packId) async {
    final filter = CompactPhraseFilter.pack(packId);
    state = AsyncData(filter);
    await _saveToPrefs(filter);
    ref.read(analyticsServiceProvider).logEvent(
      AnalyticsEvents.filterChange,
      {
        AnalyticsParams.filterType: 'pack',
        AnalyticsParams.packId: packId,
      },
    );
  }

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

  /// "오늘" 필터로 전환.
  Future<void> selectToday() async {
    const filter = CompactPhraseFilter.today();
    state = const AsyncData(filter);
    await _saveToPrefs(filter);
    ref.read(analyticsServiceProvider).logEvent(
      AnalyticsEvents.filterChange,
      {AnalyticsParams.filterType: 'today'},
    );
  }

  Future<void> _saveToPrefs(CompactPhraseFilter filter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = switch (filter) {
        _Favorites() => 'favorites',
        _Pack(:final packId) => 'pack:$packId',
        _MyIdol() => 'my_idol',
        _Today() => 'today',
      };
      await prefs.setString(_key, value);
    } catch (e) {
      debugPrint('CompactPhraseFilterNotifier: save failed — $e');
    }
  }
}

/// 현재 필터에 맞는 문구 목록.
///
/// - favorites: 즐겨찾기 ko Set + 전체 팩에서 Phrase 룩업.
/// - pack: 해당 팩의 phrases (잠금 팩은 빈 리스트).
@riverpod
Future<List<Phrase>> filteredCompactPhrases(
    FilteredCompactPhrasesRef ref) async {
  final filter = await ref.watch(compactPhraseFilterNotifierProvider.future);

  return switch (filter) {
    _Favorites() => _buildFavoritesPhrases(ref),
    _Pack(:final packId) => _buildPackPhrases(ref, packId),
    _MyIdol() => _buildMyIdolPhrases(ref),
    _Today() => _buildTodayPhrases(ref),
  };
}

/// 즐겨찾기 문구 목록.
///
/// [favoritePhrasesNotifierProvider]가 AsyncNotifier이므로 `.future`로
/// SharedPreferences 로드 완료를 자연스럽게 대기한다.
Future<List<Phrase>> _buildFavoritesPhrases(
    FilteredCompactPhrasesRef ref) async {
  final favoriteKos = await ref.watch(favoritePhrasesNotifierProvider.future);
  if (favoriteKos.isEmpty) return [];

  final packs = await ref.watch(allPhrasesProvider.future);

  // 전체 문구에서 ko→Phrase 룩업 맵 생성 (O(1) lookup)
  final lookup = <String, Phrase>{};
  for (final pack in packs) {
    for (final phrase in pack.phrases) {
      lookup[phrase.ko] = phrase;
    }
  }

  return favoriteKos
      .map((ko) => lookup[ko] ?? Phrase(ko: ko, roman: '', context: ''))
      .toList();
}

Future<List<Phrase>> _buildPackPhrases(
    FilteredCompactPhrasesRef ref, String packId) async {
  final packs = await ref.watch(allPhrasesProvider.future);
  final pack = packs.where((p) => p.id == packId).firstOrNull;
  if (pack == null) return [];
  if (!pack.isFree) return [];
  // 템플릿 문구 제외 — 마이 아이돌 전용 치환 경로에서만 사용
  return pack.phrases.where((p) => !p.isTemplate).toList();
}

/// 마이 아이돌 템플릿 문구 목록.
///
/// isTemplate == true인 문구를 수집하고 마이 아이돌 이름으로 치환한다.
Future<List<Phrase>> _buildMyIdolPhrases(FilteredCompactPhrasesRef ref) async {
  final idolName = await ref.watch(myIdolDisplayNameProvider.future);
  if (idolName == null) return [];

  final packs = await ref.watch(allPhrasesProvider.future);
  final templates =
      packs.expand((p) => p.phrases).where((p) => p.isTemplate).toList();

  return templates.map((p) => resolveTemplatePhrase(p, idolName)).toList();
}

/// 오늘 이벤트 기반 추천 문구 (버블 "오늘" 칩).
Future<List<Phrase>> _buildTodayPhrases(FilteredCompactPhrasesRef ref) async {
  return ref.watch(todaySuggestedPhrasesProvider.future);
}

/// 현재 선택된 팩이 잠금 상태인지.
@riverpod
Future<bool> isSelectedPackLocked(IsSelectedPackLockedRef ref) async {
  final filter = await ref.watch(compactPhraseFilterNotifierProvider.future);

  return switch (filter) {
    _Favorites() => false,
    _Pack(:final packId) => _isPackLocked(ref, packId),
    _MyIdol() => false,
    _Today() => false,
  };
}

Future<bool> _isPackLocked(IsSelectedPackLockedRef ref, String packId) async {
  final packs = await ref.watch(allPhrasesProvider.future);
  final pack = packs.where((p) => p.id == packId).firstOrNull;
  return pack != null && !pack.isFree;
}
