import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/core/repositories/phrase_repository.dart';

/// 전체 문구 팩 조회 유스케이스.
class GetPhrasesUseCase {
  final PhraseRepository _repository;

  GetPhrasesUseCase(this._repository);

  /// 모든 문구 팩을 반환한다.
  Future<List<PhrasePack>> execute() => _repository.getAllPacks();
}
