import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MonetizationLocalDataSource dataSource;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    dataSource = MonetizationLocalDataSource(mockStorage);
  });

  group('MonetizationLocalDataSource', () {
    group('load', () {
      test('should return default state when no data stored', () async {
        when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
            .thenAnswer((_) async => null);
        when(() => mockStorage.read(key: MonetizationLocalDataSource.sigKey))
            .thenAnswer((_) async => null);

        final result = await dataSource.load();

        expect(result, const MonetizationState());
      });

      test('should return default state when data exists but sig is null',
          () async {
        when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
            .thenAnswer((_) async => '{"honeymoon_active":true}');
        when(() => mockStorage.read(key: MonetizationLocalDataSource.sigKey))
            .thenAnswer((_) async => null);

        final result = await dataSource.load();

        expect(result, const MonetizationState());
      });

      test('should return stored state when HMAC matches', () async {
        final state = MonetizationState(
          installDate: '2026-03-01',
          honeymoonActive: false,
          favoriteSlotLimit: 5,
          ttsPlayCount: 5,
          adWatchCount: 2,
          lastTimestamp: 1000,
          purchasedPackIds: ['pack_purple_dream'],
        );
        final dataStr = jsonEncode(state.toJson());
        final validSig = dataSource.computeHmac(dataStr);

        when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
            .thenAnswer((_) async => dataStr);
        when(() => mockStorage.read(key: MonetizationLocalDataSource.sigKey))
            .thenAnswer((_) async => validSig);

        final result = await dataSource.load();

        expect(result.installDate, '2026-03-01');
        expect(result.honeymoonActive, false);
        expect(result.favoriteSlotLimit, 5);
        expect(result.ttsPlayCount, 5);
        expect(result.adWatchCount, 2);
        expect(result.lastTimestamp, 1000);
        expect(result.purchasedPackIds, ['pack_purple_dream']);
      });

      test('should reset when HMAC mismatch (tampering detected)', () async {
        final dataStr =
            jsonEncode(const MonetizationState(adWatchCount: 99).toJson());
        const tamperedSig = 'tampered_signature_abc123';

        when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
            .thenAnswer((_) async => dataStr);
        when(() => mockStorage.read(key: MonetizationLocalDataSource.sigKey))
            .thenAnswer((_) async => tamperedSig);
        when(() => mockStorage.delete(key: MonetizationLocalDataSource.dataKey))
            .thenAnswer((_) async {});
        when(() => mockStorage.delete(key: MonetizationLocalDataSource.sigKey))
            .thenAnswer((_) async {});

        final result = await dataSource.load();

        expect(result, const MonetizationState());
        verify(
          () => mockStorage.delete(key: MonetizationLocalDataSource.dataKey),
        ).called(1);
        verify(
          () => mockStorage.delete(key: MonetizationLocalDataSource.sigKey),
        ).called(1);
      });

      test(
          'should return default state and delete keys on PlatformException (BadPaddingException)',
          () async {
        when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
            .thenThrow(PlatformException(
          code: 'Exception encountered',
          message: 'read',
          details:
              'javax.crypto.BadPaddingException: error:1e000065:Cipher functions:OPENSSL_internal:BAD_DECRYPT',
        ));
        when(() => mockStorage.delete(key: MonetizationLocalDataSource.dataKey))
            .thenAnswer((_) async {});
        when(() => mockStorage.delete(key: MonetizationLocalDataSource.sigKey))
            .thenAnswer((_) async {});

        final result = await dataSource.load();

        expect(result, const MonetizationState());
        verify(
          () => mockStorage.delete(key: MonetizationLocalDataSource.dataKey),
        ).called(1);
        verify(
          () => mockStorage.delete(key: MonetizationLocalDataSource.sigKey),
        ).called(1);
      });

      test('should reset when JSON is corrupted', () async {
        const corruptedData = '{not valid json!!!';
        final sig = dataSource.computeHmac(corruptedData);

        when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
            .thenAnswer((_) async => corruptedData);
        when(() => mockStorage.read(key: MonetizationLocalDataSource.sigKey))
            .thenAnswer((_) async => sig);
        when(() => mockStorage.delete(key: MonetizationLocalDataSource.dataKey))
            .thenAnswer((_) async {});
        when(() => mockStorage.delete(key: MonetizationLocalDataSource.sigKey))
            .thenAnswer((_) async {});

        final result = await dataSource.load();

        expect(result, const MonetizationState());
        verify(
          () => mockStorage.delete(key: MonetizationLocalDataSource.dataKey),
        ).called(1);
        verify(
          () => mockStorage.delete(key: MonetizationLocalDataSource.sigKey),
        ).called(1);
      });
    });

    group('save', () {
      test(
          'should delete corrupted keys and retry on PlatformException',
          () async {
        final state = const MonetizationState(adWatchCount: 1);
        final expectedData = jsonEncode(state.toJson());
        final expectedSig = dataSource.computeHmac(expectedData);

        var callCount = 0;
        when(
          () => mockStorage.write(
            key: MonetizationLocalDataSource.dataKey,
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw PlatformException(
              code: 'Exception encountered',
              message: 'write',
              details: 'javax.crypto.BadPaddingException',
            );
          }
        });
        when(
          () => mockStorage.write(
            key: MonetizationLocalDataSource.sigKey,
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockStorage.delete(key: MonetizationLocalDataSource.dataKey))
            .thenAnswer((_) async {});
        when(() => mockStorage.delete(key: MonetizationLocalDataSource.sigKey))
            .thenAnswer((_) async {});

        // Should not throw
        await dataSource.save(state);

        verify(
          () => mockStorage.delete(key: MonetizationLocalDataSource.dataKey),
        ).called(1);
      });

      test('should persist data with HMAC signature', () async {
        final state = MonetizationState(
          installDate: '2026-03-01',
          honeymoonActive: false,
          adWatchCount: 3,
          lastTimestamp: 5000,
        );
        final expectedData = jsonEncode(state.toJson());
        final expectedSig = dataSource.computeHmac(expectedData);

        when(
          () => mockStorage.write(
            key: MonetizationLocalDataSource.dataKey,
            value: expectedData,
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockStorage.write(
            key: MonetizationLocalDataSource.sigKey,
            value: expectedSig,
          ),
        ).thenAnswer((_) async {});

        await dataSource.save(state);

        verify(
          () => mockStorage.write(
            key: MonetizationLocalDataSource.dataKey,
            value: expectedData,
          ),
        ).called(1);
        verify(
          () => mockStorage.write(
            key: MonetizationLocalDataSource.sigKey,
            value: expectedSig,
          ),
        ).called(1);
      });
    });

    group('computeHmac', () {
      test('should be deterministic (same input = same output)', () {
        const input = '{"honeymoon_active":true,"ad_watch_count":0}';

        final result1 = dataSource.computeHmac(input);
        final result2 = dataSource.computeHmac(input);

        expect(result1, result2);
        expect(result1, isNotEmpty);
      });

      test('should produce different output for different input', () {
        const input1 = '{"ad_watch_count":0}';
        const input2 = '{"ad_watch_count":1}';

        final result1 = dataSource.computeHmac(input1);
        final result2 = dataSource.computeHmac(input2);

        expect(result1, isNot(result2));
      });
    });
  });
}
