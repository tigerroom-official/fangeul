import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart'
    show contrastRatio;

/// 배경색 기반 WCAG 4.5:1 추천 글자색 생성.
///
/// 보색, 유사색, 무채색에서 WCAG 대비율 4.5:1을 만족하는 후보를 반환한다.
List<Color> suggestTextColors(Color background) {
  final bgHct = Hct.fromInt(background.toARGB32());
  final isDark = bgHct.tone < 50;
  final baseTone = isDark ? 90.0 : 10.0;

  final rawCandidates = <Hct>[
    // 보색
    Hct.from((bgHct.hue + 180) % 360, 30, baseTone),
    // 유사색 ±30
    Hct.from((bgHct.hue + 30) % 360, 20, baseTone),
    Hct.from((bgHct.hue + 330) % 360, 20, baseTone),
    // 같은 hue, 대비 tone
    Hct.from(bgHct.hue, 16, baseTone),
    // 무채색
    Hct.from(0, 0, isDark ? 95.0 : 5.0),
    Hct.from(0, 0, isDark ? 85.0 : 15.0),
    // 순백/순흑
    Hct.from(0, 0, isDark ? 100.0 : 0.0),
  ];

  final candidates = <Color>[];
  for (final hct in rawCandidates) {
    final color = Color(hct.toInt());
    if (contrastRatio(color, background) >= 4.5) {
      // 중복 방지 (비슷한 색상)
      final isDuplicate = candidates.any(
        (c) => _colorDistance(c, color) < 20,
      );
      if (!isDuplicate) candidates.add(color);
    }
  }
  return candidates.take(5).toList();
}

double _colorDistance(Color a, Color b) {
  final dr = ((a.r - b.r) * 255);
  final dg = ((a.g - b.g) * 255);
  final db = ((a.b - b.b) * 255);
  return math.sqrt(dr * dr + dg * dg + db * db);
}

/// HCT 기반 경량 글자색 피커 다이얼로그.
///
/// hue 바 + tone 슬라이더 + 실시간 프리뷰 + WCAG 대비율 표시.
class TextColorPickerDialog extends StatefulWidget {
  const TextColorPickerDialog({
    super.key,
    required this.backgroundColor,
    this.initialColor,
  });

  /// 대비율 계산용 배경색.
  final Color backgroundColor;

  /// 초기 글자색 (null이면 흰색으로 시작).
  final Color? initialColor;

  /// 다이얼로그를 표시하고 선택된 색상을 반환한다.
  static Future<Color?> show(
    BuildContext context, {
    required Color backgroundColor,
    Color? initialColor,
  }) {
    return showDialog<Color>(
      context: context,
      builder: (_) => TextColorPickerDialog(
        backgroundColor: backgroundColor,
        initialColor: initialColor,
      ),
    );
  }

  @override
  State<TextColorPickerDialog> createState() => _TextColorPickerDialogState();
}

class _TextColorPickerDialogState extends State<TextColorPickerDialog> {
  late double _hue;
  late double _tone;
  static const _chroma = 20.0; // 글자색은 채도보다 명도 중요

  @override
  void initState() {
    super.initState();
    if (widget.initialColor != null) {
      final hct = Hct.fromInt(widget.initialColor!.toARGB32());
      _hue = hct.hue;
      _tone = hct.tone.clamp(0.0, 100.0);
    } else {
      _hue = 0;
      _tone = 90;
    }
  }

  Color get _currentColor => Color(Hct.from(_hue, _chroma, _tone).toInt());

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);
    final color = _currentColor;
    final ratio = contrastRatio(color, widget.backgroundColor);
    final passesWcag = ratio >= 4.5;

    return AlertDialog(
      title: Text(l.themePickerFreePickerTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 프리뷰
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '가나다라마바사 ABC 123',
              style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: 16,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // WCAG 대비율
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passesWcag
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                size: 16,
                color: passesWcag
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                '${ratio.toStringAsFixed(1)}:1',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: passesWcag
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hue 슬라이더
          _buildSlider(
            label: l.themePickerHue,
            value: _hue,
            min: 0,
            max: 360,
            onChanged: (v) => setState(() => _hue = v),
            theme: theme,
          ),
          const SizedBox(height: 8),
          // Tone 슬라이더
          _buildSlider(
            label: l.themePickerTone,
            value: _tone,
            min: 0,
            max: 100,
            onChanged: (v) => setState(() => _tone = v),
            theme: theme,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(color),
          child: Text(l.complete),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
