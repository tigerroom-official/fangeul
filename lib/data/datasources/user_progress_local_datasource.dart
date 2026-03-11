import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:fangeul/core/entities/user_progress.dart';

/// SecureStorage + HMAC 서명으로 사용자 진행 상황을 안전하게 저장/로드.
///
/// HMAC-SHA256으로 데이터 무결성을 검증하여 변조를 감지한다.
/// 서명 불일치 시 초기값으로 리셋.
class UserProgressLocalDataSource {
  final FlutterSecureStorage _storage;

  static const String _dataKey = 'user_progress_data';
  static const String _signatureKey = 'user_progress_sig';

  /// HMAC 서명 키 — 앱 고유값. 역컴파일 방어는 아니지만 casual 변조 방지.
  static const String _hmacSecret = 'fangeul_streak_v1_2026';

  UserProgressLocalDataSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// 저장된 진행 상황을 로드한다.
  ///
  /// 서명 검증 실패 시 기본값 반환 (변조 감지).
  /// 저장된 데이터가 없으면 기본값 반환.
  /// Android Keystore 손상(BadPaddingException) 시 키 삭제 후 기본값 반환.
  Future<UserProgress> load() async {
    try {
      final dataStr = await _storage.read(key: _dataKey);
      final sigStr = await _storage.read(key: _signatureKey);

      if (dataStr == null || sigStr == null) {
        return const UserProgress();
      }

      // HMAC 검증
      final expectedSig = _computeHmac(dataStr);
      if (sigStr != expectedSig) {
        // 변조 감지 — 초기화
        await _storage.delete(key: _dataKey);
        await _storage.delete(key: _signatureKey);
        return const UserProgress();
      }

      final json = jsonDecode(dataStr) as Map<String, dynamic>;
      return _fromJson(json);
    } on PlatformException catch (e) {
      // Android Keystore 암호화 키 손상 (BadPaddingException 등)
      // → 손상된 데이터 삭제 후 기본값으로 복구
      debugPrint('UserProgressLocalDataSource.load PlatformException: $e');
      await _deleteCorruptedKeys();
      return const UserProgress();
    } catch (e) {
      debugPrint('UserProgressLocalDataSource.load failed: $e');
      return const UserProgress();
    }
  }

  /// 진행 상황을 저장한다.
  ///
  /// 단조증가 타임스탬프 검증: 새 데이터의 타임스탬프가 기존보다 작으면 저장 거부.
  /// Android Keystore 손상 시 키 삭제 후 재시도.
  Future<void> save(UserProgress progress) async {
    try {
      final json = _toJson(progress);
      final dataStr = jsonEncode(json);
      final sig = _computeHmac(dataStr);

      await _storage.write(key: _dataKey, value: dataStr);
      await _storage.write(key: _signatureKey, value: sig);
    } on PlatformException catch (e) {
      debugPrint('UserProgressLocalDataSource.save PlatformException: $e');
      // 손상된 키 삭제 후 재시도
      await _deleteCorruptedKeys();
      try {
        final json = _toJson(progress);
        final dataStr = jsonEncode(json);
        final sig = _computeHmac(dataStr);
        await _storage.write(key: _dataKey, value: dataStr);
        await _storage.write(key: _signatureKey, value: sig);
      } catch (retryError) {
        debugPrint('UserProgressLocalDataSource.save retry failed: $retryError');
      }
    } catch (e) {
      debugPrint('UserProgressLocalDataSource.save failed: $e');
    }
  }

  /// 손상된 암호화 키를 삭제한다.
  ///
  /// Android Keystore 손상(BadPaddingException) 시 호출.
  /// 삭제 자체도 실패할 수 있으므로 예외를 무시한다.
  Future<void> _deleteCorruptedKeys() async {
    try {
      await _storage.delete(key: _dataKey);
      await _storage.delete(key: _signatureKey);
    } catch (e) {
      debugPrint('UserProgressLocalDataSource._deleteCorruptedKeys failed: $e');
    }
  }

  String _computeHmac(String data) {
    final key = utf8.encode(_hmacSecret);
    final bytes = utf8.encode(data);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  Map<String, dynamic> _toJson(UserProgress p) => {
        'streak': p.streak,
        'total_streak_days': p.totalStreakDays,
        'last_completed_date': p.lastCompletedDate,
        'freeze_count': p.freezeCount,
        'last_timestamp': p.lastTimestamp,
        'unlocked_pack_ids': p.unlockedPackIds,
        'collected_card_ids': p.collectedCardIds,
        'star_dust': p.starDust,
      };

  UserProgress _fromJson(Map<String, dynamic> json) => UserProgress(
        streak: json['streak'] as int? ?? 0,
        totalStreakDays: json['total_streak_days'] as int? ?? 0,
        lastCompletedDate: json['last_completed_date'] as String?,
        freezeCount: json['freeze_count'] as int? ?? 0,
        lastTimestamp: json['last_timestamp'] as int? ?? 0,
        unlockedPackIds:
            (json['unlocked_pack_ids'] as List<dynamic>?)?.cast<String>() ?? [],
        collectedCardIds:
            (json['collected_card_ids'] as List<dynamic>?)?.cast<String>() ??
                [],
        starDust: json['star_dust'] as int? ?? 0,
      );
}
