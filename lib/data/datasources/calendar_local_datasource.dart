import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:fangeul/core/entities/kpop_event.dart';

/// 로컬 에셋에서 K-pop 이벤트 JSON을 로드하는 데이터소스.
///
/// `assets/calendar/kpop_events.json`을 파싱하여 [KpopEvent] 목록으로 변환.
/// 앱 생명주기 동안 메모리 캐시를 유지하여 중복 로드를 방지한다.
class CalendarLocalDataSource {
  final AssetBundle _assetBundle;

  /// 메모리 캐시
  List<KpopEvent>? _cache;

  CalendarLocalDataSource({AssetBundle? assetBundle})
      : _assetBundle = assetBundle ?? rootBundle;

  /// 모든 이벤트를 로드한다.
  Future<List<KpopEvent>> getAllEvents() async {
    if (_cache != null) return _cache!;

    final jsonStr =
        await _assetBundle.loadString('assets/calendar/kpop_events.json');
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final events = (json['events'] as List<dynamic>)
        .map((e) => KpopEvent.fromJson(e as Map<String, dynamic>))
        .toList();

    _cache = events;
    return events;
  }

  /// MM-DD 형식 날짜로 이벤트를 필터링한다.
  Future<List<KpopEvent>> getEventsByDate(String mmdd) async {
    final events = await getAllEvents();
    return events.where((e) => e.date == mmdd).toList();
  }
}
