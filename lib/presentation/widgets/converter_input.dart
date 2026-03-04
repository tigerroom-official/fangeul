import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/theme/fangeul_text_styles.dart';
import 'package:fangeul/presentation/widgets/copy_feedback_overlay.dart';

/// 변환기 입출력 위젯 -- 읽기 전용 TextField + 결과 표시.
///
/// 커스텀 한글 키보드와 함께 사용되므로 시스템 키보드를 띄우지 않는다.
/// [readOnly]가 true이고, 텍스트 입력은 부모가 [controller]를 통해 직접 제어한다.
/// 지우기 버튼은 [onClear] 콜백을 호출하여 부모의 버퍼까지 함께 초기화한다.
class ConverterInput extends StatelessWidget {
  /// Creates the [ConverterInput] widget.
  const ConverterInput({
    super.key,
    required this.controller,
    required this.output,
    required this.hintText,
    required this.onClear,
    this.onCopied,
  });

  /// 입력 필드 컨트롤러.
  final TextEditingController controller;

  /// 변환 결과 텍스트. 빈 문자열이면 미표시.
  final String output;

  /// 입력 필드 힌트.
  final String hintText;

  /// 지우기 콜백. 부모의 버퍼 + 컨트롤러 + 변환 상태를 모두 초기화한다.
  final VoidCallback onClear;

  /// 복사 완료 콜백. 클립보드에 텍스트가 복사된 뒤 호출된다.
  ///
  /// MiniConverterScreen 등에서 복사 이력(copy history)을 추적할 때 사용한다.
  /// `null`이면 아무 동작도 하지 않는다(기존 호출부 호환).
  final void Function(String text)? onCopied;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 입력 필드 (읽기 전용 — 시스템 키보드 숨김)
        TextField(
          controller: controller,
          readOnly: true,
          showCursor: true,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: onClear,
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
                        CopyFeedback.trigger(context);
                        onCopied?.call(output);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.copied)),
                        );
                      },
                      icon: const Icon(Icons.copy_outlined),
                      tooltip: l.copyTooltip,
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
