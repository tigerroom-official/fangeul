import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/user_progress.dart';
import 'package:fangeul/data/datasources/user_progress_local_datasource.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late UserProgressLocalDataSource dataSource;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    dataSource = UserProgressLocalDataSource(storage: mockStorage);
  });

  group('UserProgressLocalDataSource', () {
    group('load', () {
      test('should return default when no data stored', () async {
        when(() => mockStorage.read(key: 'user_progress_data'))
            .thenAnswer((_) async => null);
        when(() => mockStorage.read(key: 'user_progress_sig'))
            .thenAnswer((_) async => null);

        final result = await dataSource.load();

        expect(result, const UserProgress());
      });

      test(
          'should return default and delete keys on PlatformException (BadPaddingException)',
          () async {
        when(() => mockStorage.read(key: 'user_progress_data')).thenThrow(
          PlatformException(
            code: 'Exception encountered',
            message: 'read',
            details:
                'javax.crypto.BadPaddingException: error:1e000065:Cipher functions:OPENSSL_internal:BAD_DECRYPT',
          ),
        );
        when(() => mockStorage.delete(key: 'user_progress_data'))
            .thenAnswer((_) async {});
        when(() => mockStorage.delete(key: 'user_progress_sig'))
            .thenAnswer((_) async {});

        final result = await dataSource.load();

        expect(result, const UserProgress());
        verify(() => mockStorage.delete(key: 'user_progress_data')).called(1);
        verify(() => mockStorage.delete(key: 'user_progress_sig')).called(1);
      });

      test('should return default on generic exception', () async {
        when(() => mockStorage.read(key: 'user_progress_data'))
            .thenThrow(Exception('unknown error'));
        // No delete stub needed — generic catch just returns default

        final result = await dataSource.load();

        expect(result, const UserProgress());
      });

      test('should return default when HMAC mismatch', () async {
        final data = jsonEncode({
          'streak': 99,
          'total_streak_days': 99,
          'last_completed_date': null,
          'freeze_count': 0,
          'last_timestamp': 0,
          'unlocked_pack_ids': <String>[],
          'collected_card_ids': <String>[],
          'star_dust': 0,
        });

        when(() => mockStorage.read(key: 'user_progress_data'))
            .thenAnswer((_) async => data);
        when(() => mockStorage.read(key: 'user_progress_sig'))
            .thenAnswer((_) async => 'tampered_signature');
        when(() => mockStorage.delete(key: 'user_progress_data'))
            .thenAnswer((_) async {});
        when(() => mockStorage.delete(key: 'user_progress_sig'))
            .thenAnswer((_) async {});

        final result = await dataSource.load();

        expect(result, const UserProgress());
        verify(() => mockStorage.delete(key: 'user_progress_data')).called(1);
        verify(() => mockStorage.delete(key: 'user_progress_sig')).called(1);
      });
    });

    group('save', () {
      test('should delete corrupted keys and retry on PlatformException',
          () async {
        const progress = UserProgress(streak: 5, totalStreakDays: 10);

        var writeCallCount = 0;
        when(
          () => mockStorage.write(
            key: 'user_progress_data',
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {
          writeCallCount++;
          if (writeCallCount == 1) {
            throw PlatformException(
              code: 'Exception encountered',
              message: 'write',
              details: 'javax.crypto.BadPaddingException',
            );
          }
        });
        when(
          () => mockStorage.write(
            key: 'user_progress_sig',
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockStorage.delete(key: 'user_progress_data'))
            .thenAnswer((_) async {});
        when(() => mockStorage.delete(key: 'user_progress_sig'))
            .thenAnswer((_) async {});

        // Should not throw
        await dataSource.save(progress);

        verify(() => mockStorage.delete(key: 'user_progress_data')).called(1);
        verify(() => mockStorage.delete(key: 'user_progress_sig')).called(1);
      });

      test('should not throw on generic save error', () async {
        const progress = UserProgress(streak: 1);

        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenThrow(Exception('disk full'));

        // Should not throw
        await dataSource.save(progress);
      });
    });
  });
}
