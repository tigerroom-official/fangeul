import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/phrase_providers.dart';

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
}

/// 간편모드 문구 필터 Notifier.
@riverpod
class CompactPhraseFilterNotifier extends _$CompactPhraseFilterNotifier {
  @override
  CompactPhraseFilter build() => const CompactPhraseFilter.favorites();

  /// 즐겨찾기 필터로 전환.
  void selectFavorites() {
    state = const CompactPhraseFilter.favorites();
  }

  /// 팩 필터로 전환.
  void selectPack(String packId) {
    state = CompactPhraseFilter.pack(packId);
  }
}

/// 현재 필터에 맞는 문구 목록.
///
/// - favorites: 즐겨찾기 ko Set + 전체 팩에서 Phrase 룩업.
/// - pack: 해당 팩의 phrases (잠금 팩은 빈 리스트).
@riverpod
Future<List<Phrase>> filteredCompactPhrases(
    FilteredCompactPhrasesRef ref) async {
  final filter = ref.watch(compactPhraseFilterNotifierProvider);

  return switch (filter) {
    _Favorites() => _buildFavoritesPhrases(ref),
    _Pack(:final packId) => _buildPackPhrases(ref, packId),
  };
}

/// 즐겨찾기 문구 목록.
///
/// [favoritePhrasesNotifierProvider]가 AsyncNotifier이므로 `.future`로
/// SharedPreferences 로드 완료를 자연스럽게 대기한다.
Future<List<Phrase>> _buildFavoritesPhrases(
    FilteredCompactPhrasesRef ref) async {
  final favoriteKos =
      await ref.watch(favoritePhrasesNotifierProvider.future);
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
  return pack.phrases;
}

/// 현재 선택된 팩이 잠금 상태인지.
@riverpod
Future<bool> isSelectedPackLocked(IsSelectedPackLockedRef ref) async {
  final filter = ref.watch(compactPhraseFilterNotifierProvider);

  return switch (filter) {
    _Favorites() => false,
    _Pack(:final packId) => _isPackLocked(ref, packId),
  };
}

Future<bool> _isPackLocked(IsSelectedPackLockedRef ref, String packId) async {
  final packs = await ref.watch(allPhrasesProvider.future);
  final pack = packs.where((p) => p.id == packId).firstOrNull;
  return pack != null && !pack.isFree;
}
