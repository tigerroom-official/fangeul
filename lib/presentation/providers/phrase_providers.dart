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
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/template_phrase_provider.dart';

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
///
/// 아이돌/멤버 설정 상태에 따라 템플릿 문구를 풀에 포함하고,
/// 선택된 템플릿은 치환하여 반환한다.
@riverpod
Future<DailyCard?> dailyCard(DailyCardRef ref, String date) async {
  final groupName = await ref.watch(myIdolDisplayNameProvider.future);
  final memberName = await ref.watch(myIdolMemberNameProvider.future);

  final card = await ref.read(getDailyCardUseCaseProvider).execute(
        date: date,
        hasGroupName: groupName != null,
        hasMemberName: memberName != null,
      );

  if (card == null || !card.phrase.isTemplate || groupName == null) return card;

  final resolved =
      resolveTemplatePhrase(card.phrase, groupName, memberName: memberName);
  return card.copyWith(phrase: resolved);
}
