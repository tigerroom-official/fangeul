import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/repositories/phrase_repository.dart';

/// 상황별 문구 필터링 유스케이스.
///
/// 모든 팩에서 지정 상황(birthday, comeback, daily, support 등)에
/// 해당하는 문구만 추출한다.
class GetPhrasesBySituationUseCase {
  final PhraseRepository _repository;

  GetPhrasesBySituationUseCase(this._repository);

  /// [situation]에 해당하는 문구 목록을 반환한다.
  Future<List<Phrase>> execute(String situation) async {
    final packs = await _repository.getAllPacks();
    return packs
        .expand((pack) => pack.phrases)
        .where((phrase) => phrase.situation == situation)
        .toList();
  }
}
