import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/providers/converter_providers.dart';

void main() {
  group('ConverterNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should start with initial state', () {
      final state = container.read(converterNotifierProvider);
      expect(state, const ConverterState.initial());
    });

    test('should convert eng to kor', () {
      container
          .read(converterNotifierProvider.notifier)
          .convert('gksrmf', ConvertMode.engToKor);

      final state = container.read(converterNotifierProvider);
      expect(state, isA<ConverterSuccess>());
      final result = state as ConverterSuccess;
      expect(result.output, '한글');
      expect(result.mode, ConvertMode.engToKor);
      expect(result.input, 'gksrmf');
    });

    test('should convert kor to eng', () {
      container
          .read(converterNotifierProvider.notifier)
          .convert('한글', ConvertMode.korToEng);

      final state = container.read(converterNotifierProvider);
      expect(state, isA<ConverterSuccess>());
      expect((state as ConverterSuccess).output, 'gksrmf');
    });

    test('should romanize korean text', () {
      container
          .read(converterNotifierProvider.notifier)
          .convert('사랑해요', ConvertMode.romanize);

      final state = container.read(converterNotifierProvider);
      expect(state, isA<ConverterSuccess>());
      expect((state as ConverterSuccess).output, 'saranghaeyo');
    });

    test('should return initial state for empty input', () {
      container
          .read(converterNotifierProvider.notifier)
          .convert('hello', ConvertMode.engToKor);
      container
          .read(converterNotifierProvider.notifier)
          .convert('', ConvertMode.engToKor);

      expect(
        container.read(converterNotifierProvider),
        const ConverterState.initial(),
      );
    });

    test('should clear state', () {
      container
          .read(converterNotifierProvider.notifier)
          .convert('hello', ConvertMode.engToKor);
      container.read(converterNotifierProvider.notifier).clear();

      expect(
        container.read(converterNotifierProvider),
        const ConverterState.initial(),
      );
    });

    test('should handle non-korean input in romanize mode', () {
      container
          .read(converterNotifierProvider.notifier)
          .convert('hello', ConvertMode.romanize);

      final state = container.read(converterNotifierProvider);
      expect(state, isA<ConverterSuccess>());
      // Romanizer passes through non-Korean text
      expect((state as ConverterSuccess).output, 'hello');
    });
  });
}
