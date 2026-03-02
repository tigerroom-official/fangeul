import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/core/repositories/phrase_repository.dart';
import 'package:fangeul/core/usecases/get_phrases_usecase.dart';
import 'package:fangeul/core/usecases/get_phrases_by_tag_usecase.dart';
import 'package:fangeul/core/usecases/get_phrases_by_situation_usecase.dart';
import 'package:fangeul/core/usecases/get_daily_card_usecase.dart';
import 'package:fangeul/core/entities/daily_card.dart';
import 'package:fangeul/data/datasources/phrase_local_datasource.dart';
import 'package:fangeul/data/repositories/phrase_repository_impl.dart';

part 'phrase_providers.g.dart';

@riverpod
PhraseLocalDataSource phraseLocalDataSource(PhraseLocalDataSourceRef ref) {
  return PhraseLocalDataSource();
}

@riverpod
PhraseRepository phraseRepository(PhraseRepositoryRef ref) {
  return PhraseRepositoryImpl(ref.read(phraseLocalDataSourceProvider));
}

@riverpod
GetPhrasesUseCase getPhrasesUseCase(GetPhrasesUseCaseRef ref) {
  return GetPhrasesUseCase(ref.read(phraseRepositoryProvider));
}

@riverpod
GetPhrasesByTagUseCase getPhrasesByTagUseCase(GetPhrasesByTagUseCaseRef ref) {
  return GetPhrasesByTagUseCase(ref.read(phraseRepositoryProvider));
}

@riverpod
GetPhrasesBySituationUseCase getPhrasesBySituationUseCase(
    GetPhrasesBySituationUseCaseRef ref) {
  return GetPhrasesBySituationUseCase(ref.read(phraseRepositoryProvider));
}

@riverpod
GetDailyCardUseCase getDailyCardUseCase(GetDailyCardUseCaseRef ref) {
  return GetDailyCardUseCase(ref.read(phraseRepositoryProvider));
}

/// 전체 문구 팩 목록
@riverpod
Future<List<PhrasePack>> allPhrases(AllPhrasesRef ref) {
  return ref.read(getPhrasesUseCaseProvider).execute();
}

/// 태그별 문구 필터
@riverpod
Future<List<Phrase>> phrasesByTag(PhrasesByTagRef ref, String tag) {
  return ref.read(getPhrasesByTagUseCaseProvider).execute(tag);
}

/// 상황별 문구 필터
@riverpod
Future<List<Phrase>> phrasesBySituation(
    PhrasesBySituationRef ref, String situation) {
  return ref.read(getPhrasesBySituationUseCaseProvider).execute(situation);
}

/// 오늘의 카드
@riverpod
Future<DailyCard?> dailyCard(DailyCardRef ref, String date) {
  return ref.read(getDailyCardUseCaseProvider).execute(date: date);
}
