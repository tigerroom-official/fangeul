import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/repositories/phrase_repository.dart';

/// 태그별 문구 필터링 유스케이스.
///
/// 모든 팩에서 지정 태그를 포함하는 문구만 추출한다.
class GetPhrasesByTagUseCase {
  final PhraseRepository _repository;

  GetPhrasesByTagUseCase(this._repository);

  /// [tag]를 포함하는 문구 목록을 반환한다.
  Future<List<Phrase>> execute(String tag) async {
    final packs = await _repository.getAllPacks();
    return packs
        .expand((pack) => pack.phrases)
        .where((phrase) => phrase.tags.contains(tag))
        .toList();
  }
}
