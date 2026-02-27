import 'package:fangeul/core/entities/user_progress.dart';

/// 사용자 진행 상황 데이터 접근 인터페이스.
///
/// 구현체는 `data/repositories/user_progress_repository_impl.dart`에서 제공.
abstract interface class UserProgressRepository {
  /// 현재 진행 상황 조회. 저장된 데이터가 없으면 기본값 반환.
  Future<UserProgress> getProgress();

  /// 진행 상황 저장.
  Future<void> saveProgress(UserProgress progress);

  /// 스트릭 체크 및 업데이트. 업데이트 성공 시 true 반환.
  Future<bool> checkAndUpdateStreak();
}
