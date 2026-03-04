import 'package:fangeul/core/entities/remote_config_values.dart';
import 'package:fangeul/services/remote_config_service.dart';

/// 테스트 및 Firebase 미설정 환경용 NoOp Remote Config 서비스.
///
/// 항상 기본값을 반환한다.
class NoopRemoteConfigService implements RemoteConfigService {
  @override
  Future<void> initialize() async {}

  @override
  RemoteConfigValues get values => const RemoteConfigValues();
}
