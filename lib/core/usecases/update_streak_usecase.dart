import 'package:fangeul/core/entities/user_progress.dart';
import 'package:fangeul/core/repositories/user_progress_repository.dart';

/// 스트릭 업데이트 유스케이스.
///
/// 날짜 비교, 단조증가 타임스탬프 검증, 프리즈 처리를 수행한다.
class UpdateStreakUseCase {
  final UserProgressRepository _repository;

  UpdateStreakUseCase(this._repository);

  /// 스트릭을 업데이트하고 결과 [UserProgress]를 반환한다.
  ///
  /// [now]는 테스트 가능성을 위해 외부에서 주입.
  Future<UserProgress> execute({required DateTime now}) async {
    final progress = await _repository.getProgress();
    final todayStr = _formatDate(now);
    final nowMs = now.millisecondsSinceEpoch;

    // 단조증가 타임스탬프 검증 — 시간이 되돌아갔으면 무시
    if (nowMs < progress.lastTimestamp) {
      return progress;
    }

    // 같은 날 중복 완료 방지
    if (progress.lastCompletedDate == todayStr) {
      return progress;
    }

    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = _formatDate(yesterday);

    UserProgress updated;

    if (progress.lastCompletedDate == yesterdayStr) {
      // 연속 — 스트릭 증가
      updated = progress.copyWith(
        streak: progress.streak + 1,
        totalStreakDays: progress.totalStreakDays + 1,
        lastCompletedDate: todayStr,
        lastTimestamp: nowMs,
      );
    } else if (progress.lastCompletedDate == null) {
      // 첫 사용
      updated = progress.copyWith(
        streak: 1,
        totalStreakDays: 1,
        lastCompletedDate: todayStr,
        lastTimestamp: nowMs,
      );
    } else if (progress.freezeCount > 0) {
      // 하루 이상 건너뛰었지만 프리즈 사용 가능
      final daysDiff = _daysDifference(progress.lastCompletedDate!, todayStr);
      if (daysDiff == 2) {
        // 정확히 하루 건너뜀 — 프리즈 1회 소모
        updated = progress.copyWith(
          streak: progress.streak + 1,
          totalStreakDays: progress.totalStreakDays + 1,
          lastCompletedDate: todayStr,
          lastTimestamp: nowMs,
          freezeCount: progress.freezeCount - 1,
        );
      } else {
        // 2일 이상 건너뜀 — 스트릭 리셋
        updated = progress.copyWith(
          streak: 1,
          totalStreakDays: progress.totalStreakDays + 1,
          lastCompletedDate: todayStr,
          lastTimestamp: nowMs,
        );
      }
    } else {
      // 하루 이상 건너뜀, 프리즈 없음 — 스트릭 리셋
      updated = progress.copyWith(
        streak: 1,
        totalStreakDays: progress.totalStreakDays + 1,
        lastCompletedDate: todayStr,
        lastTimestamp: nowMs,
      );
    }

    await _repository.saveProgress(updated);
    return updated;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  int _daysDifference(String dateA, String dateB) {
    final a = DateTime.parse(dateA);
    final b = DateTime.parse(dateB);
    return b.difference(a).inDays.abs();
  }
}
