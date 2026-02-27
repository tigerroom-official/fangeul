import 'package:fangeul/core/entities/phrase_pack.dart';

/// 문구 팩 데이터 접근 인터페이스.
///
/// 구현체는 `data/repositories/phrase_repository_impl.dart`에서 제공.
abstract interface class PhraseRepository {
  /// 모든 문구 팩 조회.
  Future<List<PhrasePack>> getAllPacks();

  /// ID로 특정 문구 팩 조회. 없으면 null 반환.
  Future<PhrasePack?> getPackById(String packId);
}
