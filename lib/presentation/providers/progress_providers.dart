import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/core/entities/user_progress.dart';
import 'package:fangeul/core/repositories/user_progress_repository.dart';
import 'package:fangeul/core/usecases/update_streak_usecase.dart';
import 'package:fangeul/data/datasources/user_progress_local_datasource.dart';
import 'package:fangeul/data/repositories/user_progress_repository_impl.dart';

part 'progress_providers.g.dart';

@riverpod
UserProgressLocalDataSource userProgressLocalDataSource(
    UserProgressLocalDataSourceRef ref) {
  return UserProgressLocalDataSource();
}

@riverpod
UserProgressRepository userProgressRepository(UserProgressRepositoryRef ref) {
  return UserProgressRepositoryImpl(
      ref.read(userProgressLocalDataSourceProvider));
}

@riverpod
UpdateStreakUseCase updateStreakUseCase(UpdateStreakUseCaseRef ref) {
  return UpdateStreakUseCase(ref.read(userProgressRepositoryProvider));
}

/// 사용자 진행 상황
@riverpod
Future<UserProgress> userProgress(UserProgressRef ref) {
  return ref.read(userProgressRepositoryProvider).getProgress();
}
