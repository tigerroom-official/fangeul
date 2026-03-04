import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/core/entities/remote_config_values.dart';
import 'package:fangeul/services/remote_config_service.dart';

part 'remote_config_providers.g.dart';

/// Remote Config 서비스 Provider.
///
/// main.dart에서 override하여 Firebase 또는 NoOp 구현체를 주입한다.
@Riverpod(keepAlive: true)
RemoteConfigService remoteConfigService(RemoteConfigServiceRef ref) =>
    throw UnimplementedError(
        'Override remoteConfigServiceProvider in main.dart');

/// Remote Config 값 편의 Provider.
///
/// 서비스에서 현재 값을 읽어 반환한다.
@riverpod
RemoteConfigValues remoteConfigValues(RemoteConfigValuesRef ref) =>
    ref.watch(remoteConfigServiceProvider).values;
