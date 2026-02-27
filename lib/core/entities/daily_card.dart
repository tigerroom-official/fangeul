import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:fangeul/core/entities/phrase.dart';

part 'daily_card.freezed.dart';

/// 오늘의 카드 — 매일 하나의 문구를 선정하여 제공.
///
/// 동일 날짜에는 항상 동일 카드가 선정된다 (솔트+해시 기반 결정론적 선택).
@freezed
class DailyCard with _$DailyCard {
  const factory DailyCard({
    /// 카드 날짜 (yyyy-MM-dd)
    required String date,

    /// 선정된 문구의 팩 내 인덱스
    required int phraseIndex,

    /// 선정된 문구
    required Phrase phrase,

    /// 문구가 속한 팩 ID
    required String packId,

    /// 완료 여부
    @Default(false) bool isCompleted,
  }) = _DailyCard;
}
