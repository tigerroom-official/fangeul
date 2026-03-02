import 'package:freezed_annotation/freezed_annotation.dart';

part 'kpop_event.freezed.dart';
part 'kpop_event.g.dart';

/// K-pop 캘린더 이벤트.
///
/// 아이돌 생일, 데뷔 기념일 등 매년 반복되는 이벤트를 표현한다.
/// [date]는 MM-DD 형식으로, 연도와 무관하게 매년 매칭된다.
/// [situation]은 [Phrase.situation]과 매칭되어 추천 문구 필터링에 사용.
@freezed
class KpopEvent with _$KpopEvent {
  const factory KpopEvent({
    /// MM-DD 형식의 날짜 (예: "03-09")
    required String date,

    /// 이벤트 유형 (birthday / comeback / debut_anniversary)
    required String type,

    /// 아티스트 이름 (예: "슈가")
    required String artist,

    /// 그룹 이름 (예: "BTS")
    required String group,

    /// Phrase.situation과 매칭되는 상황 태그
    required String situation,
  }) = _KpopEvent;

  factory KpopEvent.fromJson(Map<String, dynamic> json) =>
      _$KpopEventFromJson(json);
}
