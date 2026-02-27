import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/core/engines/keyboard_converter.dart';
import 'package:fangeul/core/engines/romanizer.dart';

part 'converter_providers.freezed.dart';
part 'converter_providers.g.dart';

/// 변환기 모드.
enum ConvertMode {
  /// 영문 → 한글
  engToKor,

  /// 한글 → 영문
  korToEng,

  /// 한글 → 로마자 발음
  romanize,
}

/// 변환기 상태.
///
/// 프로젝트 규칙에 따라 initial/loading/success/error 4개 상태를 모두 정의한다.
@freezed
sealed class ConverterState with _$ConverterState {
  /// 초기 상태 (입력 없음)
  const factory ConverterState.initial() = ConverterInitial;

  /// 변환 중 (현재 동기 엔진이므로 미사용, 향후 TTS 연동 대비)
  const factory ConverterState.loading() = ConverterLoading;

  /// 변환 성공
  const factory ConverterState.success({
    required String input,
    required String output,
    required ConvertMode mode,
  }) = ConverterSuccess;

  /// 변환 에러
  const factory ConverterState.error(String message) = ConverterError;
}

/// 변환기 상태 관리.
///
/// [KeyboardConverter]와 [Romanizer] 엔진을 래핑하여
/// 입력 텍스트를 선택된 모드로 변환한다.
@riverpod
class ConverterNotifier extends _$ConverterNotifier {
  @override
  ConverterState build() => const ConverterState.initial();

  /// [input]을 [mode]에 따라 변환한다.
  void convert(String input, ConvertMode mode) {
    if (input.isEmpty) {
      state = const ConverterState.initial();
      return;
    }

    try {
      final output = switch (mode) {
        ConvertMode.engToKor => KeyboardConverter.engToKor(input),
        ConvertMode.korToEng => KeyboardConverter.korToEng(input),
        ConvertMode.romanize => Romanizer.romanize(input),
      };

      state = ConverterState.success(
        input: input,
        output: output,
        mode: mode,
      );
    } catch (e) {
      state = ConverterState.error(e.toString());
    }
  }

  /// 상태를 초기화한다.
  void clear() {
    state = const ConverterState.initial();
  }
}
