import 'dart:convert';

import 'package:fangeul/core/entities/daily_card.dart';
import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/repositories/phrase_repository.dart';

/// 오늘의 카드 생성 유스케이스.
///
/// 솔트+해시 기반으로 매일 결정론적으로 하나의 문구를 선정한다.
/// 동일 날짜에는 항상 동일 카드가 반환된다.
class GetDailyCardUseCase {
  final PhraseRepository _repository;

  /// 해시 솔트 — 인덱스 예측 방지용
  static const String _salt = 'fangeul_daily_2026';

  GetDailyCardUseCase(this._repository);

  /// [date]에 해당하는 오늘의 카드를 반환한다.
  ///
  /// 무료 팩에서만 선정. 팩이 비어있으면 null 반환.
  Future<DailyCard?> execute({required String date}) async {
    final packs = await _repository.getAllPacks();
    final freePacks = packs.where((p) => p.isFree).toList();

    // 무료 팩의 모든 문구를 (packId, index, phrase)로 평탄화
    final allPhrases = <({String packId, int index, Phrase phrase})>[];
    for (final pack in freePacks) {
      for (var i = 0; i < pack.phrases.length; i++) {
        allPhrases.add((packId: pack.id, index: i, phrase: pack.phrases[i]));
      }
    }

    if (allPhrases.isEmpty) return null;

    // 솔트+날짜 해시로 인덱스 결정
    final hash = _hashCode('$_salt:$date');
    final selectedIndex = hash % allPhrases.length;
    final selected = allPhrases[selectedIndex];

    return DailyCard(
      date: date,
      phraseIndex: selected.index,
      phrase: selected.phrase,
      packId: selected.packId,
    );
  }

  /// 단순하고 결정론적인 해시 함수.
  /// 암호학적 보안이 아닌 일관된 분배가 목적.
  int _hashCode(String input) {
    final bytes = utf8.encode(input);
    var hash = 0;
    for (final byte in bytes) {
      hash = (hash * 31 + byte) & 0x7FFFFFFF;
    }
    return hash;
  }
}
