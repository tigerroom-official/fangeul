import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/presentation/theme/fangeul_text_styles.dart';

/// 변환기 입출력 위젯 -- 입력 TextField + 결과 표시.
///
/// 입력값이 변경되면 [onChanged] 콜백을 통해 부모에게 전달하고,
/// [output]으로 변환 결과를 표시한다.
class ConverterInput extends StatelessWidget {
  /// Creates the [ConverterInput] widget.
  const ConverterInput({
    super.key,
    required this.controller,
    required this.output,
    required this.hintText,
    required this.onChanged,
  });

  /// 입력 필드 컨트롤러.
  final TextEditingController controller;

  /// 변환 결과 텍스트. 빈 문자열이면 미표시.
  final String output;

  /// 입력 필드 힌트.
  final String hintText;

  /// 텍스트 변경 콜백.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 입력 필드
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 24),
        // 결과 영역
        if (output.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  output,
                  style: FangeulTextStyles.koreanDisplay.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: output));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('복사되었습니다')),
                        );
                      },
                      icon: const Icon(Icons.copy_outlined),
                      tooltip: '복사',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
