import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/core/repositories/monetization_repository.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';

/// [MonetizationRepository] 구현체 — SecureStorage + HMAC 기반.
///
/// 모든 저장/로드를 [MonetizationLocalDataSource]에 위임한다.
class MonetizationRepositoryImpl implements MonetizationRepository {
  /// [dataSource]를 주입받아 생성한다.
  MonetizationRepositoryImpl(this._dataSource);

  final MonetizationLocalDataSource _dataSource;

  @override
  Future<MonetizationState> load() => _dataSource.load();

  @override
  Future<void> save(MonetizationState state) => _dataSource.save(state);
}
