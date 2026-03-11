import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:fangeul/core/entities/monetization_state.dart';

/// SecureStorage + HMAC-SHA256 서명으로 수익화 상태를 안전하게 저장/로드.
///
/// 데이터와 함께 HMAC 서명을 저장하여 무결성을 검증한다.
/// 서명 불일치(변조 감지) 또는 JSON 파싱 오류 시 기본값으로 리셋.
class MonetizationLocalDataSource {
  /// [storage]를 주입받아 생성한다.
  MonetizationLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  /// 수익화 데이터 저장 키.
  static const String dataKey = 'monetization_data';

  /// HMAC 서명 저장 키.
  static const String sigKey = 'monetization_sig';

  /// HMAC 서명 시크릿 — 앱 고유값. casual 변조 방지용.
  static const String _hmacSecret = 'fangeul_monetization_v1_2026';

  /// 저장된 수익화 상태를 로드한다.
  ///
  /// - 저장된 데이터가 없으면 기본 [MonetizationState] 반환.
  /// - HMAC 서명 불일치 시 변조로 간주하여 데이터 삭제 후 기본값 반환.
  /// - JSON 파싱 오류 시 데이터 삭제 후 기본값 반환.
  /// - Android Keystore 손상(BadPaddingException) 시 키 삭제 후 기본값 반환.
  Future<MonetizationState> load() async {
    try {
      final dataStr = await _storage.read(key: dataKey);
      final sigStr = await _storage.read(key: sigKey);

      if (dataStr == null || sigStr == null) {
        return const MonetizationState();
      }

      // HMAC 검증
      final expectedSig = computeHmac(dataStr);
      if (sigStr != expectedSig) {
        debugPrint('[MonetizationLocalDataSource] HMAC mismatch — resetting');
        await _storage.delete(key: dataKey);
        await _storage.delete(key: sigKey);
        return const MonetizationState();
      }

      final json = jsonDecode(dataStr) as Map<String, dynamic>;
      return MonetizationState.fromJson(json);
    } on PlatformException catch (e) {
      // Android Keystore 암호화 키 손상 (BadPaddingException 등)
      debugPrint('[MonetizationLocalDataSource] PlatformException: $e');
      await _deleteCorruptedKeys();
      return const MonetizationState();
    } catch (e) {
      debugPrint('[MonetizationLocalDataSource] load failed: $e');
      await _deleteCorruptedKeys();
      return const MonetizationState();
    }
  }

  /// 수익화 상태를 저장한다.
  ///
  /// JSON 직렬화 후 HMAC 서명과 함께 SecureStorage에 기록.
  /// Android Keystore 손상 시 키 삭제 후 재시도.
  Future<void> save(MonetizationState state) async {
    try {
      final dataStr = jsonEncode(state.toJson());
      final sig = computeHmac(dataStr);

      await _storage.write(key: dataKey, value: dataStr);
      await _storage.write(key: sigKey, value: sig);
    } on PlatformException catch (e) {
      debugPrint('[MonetizationLocalDataSource] save PlatformException: $e');
      await _deleteCorruptedKeys();
      try {
        final dataStr = jsonEncode(state.toJson());
        final sig = computeHmac(dataStr);
        await _storage.write(key: dataKey, value: dataStr);
        await _storage.write(key: sigKey, value: sig);
      } catch (retryError) {
        debugPrint('[MonetizationLocalDataSource] save retry failed: $retryError');
      }
    } catch (e) {
      debugPrint('[MonetizationLocalDataSource] save failed: $e');
    }
  }

  /// 손상된 암호화 키를 삭제한다.
  Future<void> _deleteCorruptedKeys() async {
    try {
      await _storage.delete(key: dataKey);
      await _storage.delete(key: sigKey);
    } catch (e) {
      debugPrint('[MonetizationLocalDataSource] _deleteCorruptedKeys failed: $e');
    }
  }

  /// HMAC-SHA256 서명을 계산한다.
  ///
  /// 동일 입력에 대해 항상 동일 출력을 보장한다.
  /// 테스트에서 서명 값을 검증할 수 있도록 public.
  String computeHmac(String data) {
    final key = utf8.encode(_hmacSecret);
    final bytes = utf8.encode(data);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }
}
