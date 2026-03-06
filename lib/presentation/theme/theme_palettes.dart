import 'package:flutter/material.dart';

/// 추천 테마 팔레트 정의.
///
/// 자연 테마 이름으로 IP 리스크 없이 팬 감성 표현.
class ThemePalette {
  /// 추천 팔레트를 생성한다.
  const ThemePalette({
    required this.id,
    required this.nameKey,
    required this.seedColor,
    required this.isFree,
  });

  /// 팔레트 고유 ID.
  final String id;

  /// l10n 키 (예: 'paletteCherryBlossom').
  final String nameKey;

  /// seed color for ColorScheme.fromSeed().
  final Color seedColor;

  /// 무료 여부 (false면 보상형/IAP 필요).
  final bool isFree;
}

/// 추천 팔레트 목록. 무료 3개 + 보상형 5개.
abstract final class ThemePalettes {
  /// 벚꽃 (무료).
  static const cherryBlossom = ThemePalette(
    id: 'cherry_blossom',
    nameKey: 'paletteCherryBlossom',
    seedColor: Color(0xFFF8BBD0),
    isFree: true,
  );

  /// 바다 (무료).
  static const ocean = ThemePalette(
    id: 'ocean',
    nameKey: 'paletteOcean',
    seedColor: Color(0xFF1565C0),
    isFree: true,
  );

  /// 숲 (무료).
  static const forest = ThemePalette(
    id: 'forest',
    nameKey: 'paletteForest',
    seedColor: Color(0xFF2E7D32),
    isFree: true,
  );

  /// 노을 (보상형).
  static const sunset = ThemePalette(
    id: 'sunset',
    nameKey: 'paletteSunset',
    seedColor: Color(0xFFE65100),
    isFree: false,
  );

  /// 별밤 (보상형).
  static const starryNight = ThemePalette(
    id: 'starry_night',
    nameKey: 'paletteStarryNight',
    seedColor: Color(0xFF4527A0),
    isFree: false,
  );

  /// 새벽 (보상형).
  static const dawn = ThemePalette(
    id: 'dawn',
    nameKey: 'paletteDawn',
    seedColor: Color(0xFFFF8A65),
    isFree: false,
  );

  /// 석양 (보상형).
  static const dusk = ThemePalette(
    id: 'dusk',
    nameKey: 'paletteDusk',
    seedColor: Color(0xFFAD1457),
    isFree: false,
  );

  /// 보석 (보상형).
  static const jewel = ThemePalette(
    id: 'jewel',
    nameKey: 'paletteJewel',
    seedColor: Color(0xFF00897B),
    isFree: false,
  );

  /// 전체 팔레트 목록 (무료 우선 정렬).
  static const all = [
    cherryBlossom,
    ocean,
    forest,
    sunset,
    starryNight,
    dawn,
    dusk,
    jewel,
  ];

  /// 무료 팔레트만.
  static List<ThemePalette> get free => all.where((p) => p.isFree).toList();
}
