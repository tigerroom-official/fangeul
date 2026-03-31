import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/theme/fangeul_text_styles.dart';
import 'package:fangeul/presentation/widgets/copy_feedback_overlay.dart';

/// 변환기 입출력 위젯 -- 읽기 전용 TextField + 결과 표시 + 붙여넣기 + 빈 상태 예시.
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
    this.focusNode,
    this.onPaste,
    this.exampleInput,
    this.exampleOutput,
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
  final void Function(String text)? onCopied;

  /// 입력 필드 포커스 노드.
  final FocusNode? focusNode;

  /// 클립보드 붙여넣기 콜백.
  final VoidCallback? onPaste;

  /// 빈 상태에서 보여줄 예시 입력 (예: "gksrmf").
  final String? exampleInput;

  /// 빈 상태에서 보여줄 예시 출력 (예: "한글").
  final String? exampleOutput;

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
          focusNode: focusNode,
          readOnly: true,
          showCursor: true,
          maxLines: null,
          minLines: 1,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: (onPaste != null || controller.text.isNotEmpty)
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onPaste != null)
                        IconButton(
                          icon: const Icon(Icons.content_paste, size: 18),
                          onPressed: onPaste,
                          tooltip: l.converterPaste,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 36, minHeight: 36),
                        ),
                      if (controller.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: onClear,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 36, minHeight: 36),
                        ),
                    ],
                  )
                : null,
          ),
        ),
        const SizedBox(height: 24),
        // 빈 상태: 변환 예시 표시
        if (controller.text.isEmpty &&
            exampleInput != null &&
            exampleOutput != null)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  exampleInput!,
                  style: FangeulTextStyles.koreanDisplay.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 22,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  exampleOutput!,
                  style: FangeulTextStyles.koreanDisplay.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          )
        // 결과 영역
        else if (output.isNotEmpty)
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
    );
  }
}
