import 'package:fangeul/core/entities/remote_config_values.dart';

/// Remote Config 서비스 추상 인터페이스.
///
/// Firebase Remote Config, NoOp 등 구현체를 교체할 수 있도록
/// 추상 레이어를 제공한다. Provider를 통해 DI.
abstract interface class RemoteConfigService {
  /// 서비스를 초기화하고 원격 값을 가져온다.
  Future<void> initialize();

  /// 현재 Remote Config 값을 반환한다.
  RemoteConfigValues get values;
}
