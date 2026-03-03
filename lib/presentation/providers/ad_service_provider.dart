import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/services/ad_service.dart';

part 'ad_service_provider.g.dart';

/// AdService 인스턴스 Provider.
///
/// 테스트에서 mock으로 override 가능.
@Riverpod(keepAlive: true)
AdService adService(AdServiceRef ref) => AdService();
