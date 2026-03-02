import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/data/datasources/calendar_local_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CalendarLocalDataSource dataSource;

  final testEvents = {
    'events': [
      {
        'date': '03-09',
        'type': 'birthday',
        'artist': '슈가',
        'group': 'BTS',
        'situation': 'birthday',
      },
      {
        'date': '06-13',
        'type': 'debut_anniversary',
        'artist': 'BTS',
        'group': 'BTS',
        'situation': 'comeback',
      },
      {
        'date': '09-01',
        'type': 'birthday',
        'artist': '정한',
        'group': 'SEVENTEEN',
        'situation': 'birthday',
      },
      {
        'date': '09-01',
        'type': 'birthday',
        'artist': '나연',
        'group': 'TWICE',
        'situation': 'birthday',
      },
    ],
  };

  setUp(() {
    final bundle = _TestAssetBundle(jsonEncode(testEvents));
    dataSource = CalendarLocalDataSource(assetBundle: bundle);
  });

  group('CalendarLocalDataSource', () {
    test('should load all events from asset', () async {
      final events = await dataSource.getAllEvents();

      expect(events, hasLength(4));
      expect(events.first.artist, '슈가');
    });

    test('should cache events after first load', () async {
      await dataSource.getAllEvents();
      final second = await dataSource.getAllEvents();

      expect(second, hasLength(4));
    });

    test('should filter events by date', () async {
      final events = await dataSource.getEventsByDate('03-09');

      expect(events, hasLength(1));
      expect(events.first.artist, '슈가');
    });

    test('should return multiple events for same date', () async {
      final events = await dataSource.getEventsByDate('09-01');

      expect(events, hasLength(2));
      expect(events.map((e) => e.artist).toList(), ['정한', '나연']);
    });

    test('should return empty list for date with no events', () async {
      final events = await dataSource.getEventsByDate('12-25');

      expect(events, isEmpty);
    });
  });
}

class _TestAssetBundle extends CachingAssetBundle {
  final String _jsonStr;

  _TestAssetBundle(this._jsonStr);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return _jsonStr;
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }
}
