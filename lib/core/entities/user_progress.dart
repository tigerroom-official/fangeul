import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress.freezed.dart';

/// 사용자 진행 상황 — 스트릭, 해금 팩, 수집 카드 등.
///
/// [lastTimestamp]로 단조증가를 검증하여 시간 조작을 방어한다.
/// JSON 직렬화는 [UserProgressLocalDataSource]에서 HMAC 검증과 결합하여 수동 처리.
@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    /// 현재 연속 스트릭 일수
    @Default(0) int streak,

    /// 누적 스트릭 일수
    @Default(0) int totalStreakDays,

    /// 마지막 완료 날짜 (yyyy-MM-dd)
    String? lastCompletedDate,

    /// 스트릭 프리즈 잔여 횟수
    @Default(0) int freezeCount,

    /// 단조증가 타임스탬프 (밀리초). 시간 조작 방어용.
    @Default(0) int lastTimestamp,

    /// 해금된 팩 ID 목록
    @Default([]) List<String> unlockedPackIds,

    /// 수집한 카드 ID 목록 (v1.1 확장)
    @Default([]) List<String> collectedCardIds,

    /// 스타더스트 포인트 (v1.1 확장)
    @Default(0) int starDust,
  }) = _UserProgress;
}
