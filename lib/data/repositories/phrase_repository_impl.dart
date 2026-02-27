import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/core/repositories/phrase_repository.dart';
import 'package:fangeul/data/datasources/phrase_local_datasource.dart';

/// [PhraseRepository] 구현체 — 로컬 에셋 JSON 기반.
class PhraseRepositoryImpl implements PhraseRepository {
  final PhraseLocalDataSource _dataSource;

  PhraseRepositoryImpl(this._dataSource);

  @override
  Future<List<PhrasePack>> getAllPacks() => _dataSource.getAllPacks();

  @override
  Future<PhrasePack?> getPackById(String packId) =>
      _dataSource.getPackById(packId);
}
