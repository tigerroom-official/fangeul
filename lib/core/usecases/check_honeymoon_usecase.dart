import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/core/repositories/monetization_repository.dart';

/// 허니문(무료 체험) 기간 상태 확인 유스케이스.
///
/// 앱 진입 시 호출하여 설치 후 경과 일수를 계산하고,
/// Day 14 이상이면 허니문을 종료하고 즐겨찾기 슬롯 제한을 적용한다.
/// Day 0~13은 모든 기능이 무료로 제공되는 허니문 기간이다.
class CheckHoneymoonUseCase {
  /// [repository]를 통해 수익화 상태를 로드/저장한다.
  ///
  /// [honeymoonDays]와 [defaultSlotLimit]은 Remote Config에서 주입 가능.
  /// 기본값은 기존 하드코딩 수치와 동일.
  CheckHoneymoonUseCase(
    this._repository, {
    int honeymoonDays = 14,
    int defaultSlotLimit = 5,
  })  : _honeymoonDays = honeymoonDays,
        _defaultSlotLimit = defaultSlotLimit;

  final MonetizationRepository _repository;

  final int _honeymoonDays;
  final int _defaultSlotLimit;

  /// 앱 진입 시 허니문 상태를 체크한다.
  ///
  /// - [now]는 테스트 가능성을 위해 외부에서 주입. null이면 현재 시각 사용.
  /// - installDate가 null이면 오늘로 설정하고 허니문 활성화.
  /// - Day 14 이상이면 honeymoonActive=false, favoriteSlotLimit=5로 전환.
  /// - 이미 종료된 상태면 변경 없이 그대로 반환.
  Future<MonetizationState> execute({DateTime? now}) async {
    final today = now ?? DateTime.now();
    var state = await _repository.load();

    // 첫 실행 — 설치 날짜 기록
    if (state.installDate == null) {
      state = state.copyWith(
        installDate: _formatDate(today),
        honeymoonActive: true,
      );
      await _repository.save(state);
      return state;
    }

    // 이미 종료됨 — 변경 없음
    if (!state.honeymoonActive) return state;

    // 설치 후 경과 일수 계산
    final installDate = _parseDate(state.installDate!);
    final daysSince = today.difference(installDate).inDays;

    if (daysSince >= _honeymoonDays) {
      state = state.copyWith(
        honeymoonActive: false,
        favoriteSlotLimit: _defaultSlotLimit,
      );
      await _repository.save(state);
    }

    return state;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  DateTime _parseDate(String date) {
    final parts = date.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
