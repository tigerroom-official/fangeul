import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/core/entities/color_pack.dart';

part 'color_pack_provider.g.dart';

/// 컬러 팩 목록을 JSON 에셋에서 로드하는 Provider.
///
/// `assets/color_packs/color_packs.json`에서 팩 정보를 읽어
/// [ColorPack] 목록으로 변환한다.
@riverpod
Future<List<ColorPack>> colorPacks(ColorPacksRef ref) async {
  final jsonStr =
      await rootBundle.loadString('assets/color_packs/color_packs.json');
  final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
  return (decoded['packs'] as List)
      .map((e) => ColorPack.fromJson(e as Map<String, dynamic>))
      .toList();
}
