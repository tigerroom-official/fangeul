import 'package:fangeul/core/entities/monetization_state.dart';

/// 수익화 상태 저장소 인터페이스.
///
/// 구현체는 `data/repositories/monetization_repository_impl.dart`에서 제공.
abstract interface class MonetizationRepository {
  /// 저장된 수익화 상태를 로드한다. 저장된 데이터가 없으면 기본값 반환.
  Future<MonetizationState> load();

  /// 수익화 상태를 저장한다.
  Future<void> save(MonetizationState state);
}
