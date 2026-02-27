import 'package:fangeul/core/entities/user_progress.dart';
import 'package:fangeul/core/repositories/user_progress_repository.dart';
import 'package:fangeul/data/datasources/user_progress_local_datasource.dart';

/// [UserProgressRepository] 구현체 — SecureStorage + HMAC 기반.
class UserProgressRepositoryImpl implements UserProgressRepository {
  final UserProgressLocalDataSource _dataSource;

  UserProgressRepositoryImpl(this._dataSource);

  @override
  Future<UserProgress> getProgress() => _dataSource.load();

  @override
  Future<void> saveProgress(UserProgress progress) =>
      _dataSource.save(progress);

  @override
  Future<bool> checkAndUpdateStreak() async {
    final progress = await _dataSource.load();
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // 이미 오늘 완료했으면 false
    if (progress.lastCompletedDate == todayStr) {
      return false;
    }

    return true;
  }
}
