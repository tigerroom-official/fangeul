import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late double _chroma;
  bool _chromaExpanded = false;

  late final TextEditingController _hexController;
  bool _hexEditing = false; // hex→slider 동기화 루프 방지

  @override
  void initState() {
    super.initState();
    if (widget.initialColor != null) {
      final hct = Hct.fromInt(widget.initialColor!.toARGB32());
      _hue = hct.hue;
      _tone = hct.tone.clamp(0.0, 100.0);
      _chroma = hct.chroma.clamp(10.0, 100.0);
    } else {
      _hue = 0;
      _tone = 90;
      _chroma = 20.0;
    }
    _hexController = TextEditingController(
      text: _colorToHex6(_currentColor),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Color get _currentColor => Color(Hct.from(_hue, _chroma, _tone).toInt());

  /// Hex 입력 → 슬라이더 동기화.
  void _onHexChanged(String value) {
    if (value.length != 6) return;
    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return;
    final color = Color(0xFF000000 | parsed);
    final hct = Hct.fromInt(color.toARGB32());
    _hexEditing = true;
    setState(() {
      _hue = hct.hue;
      _chroma = hct.chroma.clamp(10.0, 100.0);
      _tone = hct.tone.clamp(0.0, 100.0);
    });
    _hexEditing = false;
  }

  /// 슬라이더 → hex 입력 동기화.
  void _syncHexFromSliders() {
    if (_hexEditing) return;
    _hexController.text = _colorToHex6(_currentColor);
  }

  static String _colorToHex6(Color c) {
    return (c.toARGB32() & 0x00FFFFFF)
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);
    final color = _currentColor;
    final ratio = contrastRatio(color, widget.backgroundColor);

    // WCAG 3-level: AA (>=4.5), AA18 (>=3.0), fail (<3.0)
    final Color wcagColor;
    final IconData wcagIcon;
    final String wcagLabel;
    if (ratio >= 4.5) {
      wcagColor = Colors.green;
      wcagIcon = Icons.check_circle_outline;
      wcagLabel = 'AA';
    } else if (ratio >= 3.0) {
      wcagColor = Colors.orange;
      wcagIcon = Icons.warning_amber_rounded;
      wcagLabel = 'AA18';
    } else {
      wcagColor = theme.colorScheme.error;
      wcagIcon = Icons.error_outline;
      wcagLabel = '';
    }

    return AlertDialog(
      title: Text(l.themePickerFreePickerTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 프리뷰 (대비율 <3.0이면 오버레이 표시)
          Stack(
            children: [
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
              if (ratio < 3.0)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.visibility_off,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // WCAG 대비율 (3-level)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(wcagIcon, size: 16, color: wcagColor),
              const SizedBox(width: 4),
              Text(
                wcagLabel.isEmpty
                    ? '${ratio.toStringAsFixed(1)}:1'
                    : '$wcagLabel ${ratio.toStringAsFixed(1)}:1',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: wcagColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Hex 입력
          Row(
            children: [
              Text(
                '#',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _hexController,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: 'FFD700',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
                  ],
                  onChanged: _onHexChanged,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Hue 슬라이더
          _buildSlider(
            label: l.themePickerHue,
            value: _hue,
            min: 0,
            max: 360,
            onChanged: (v) {
              setState(() => _hue = v);
              _syncHexFromSliders();
            },
            theme: theme,
          ),
          const SizedBox(height: 8),
          // Tone 슬라이더
          _buildSlider(
            label: l.themePickerTone,
            value: _tone,
            min: 0,
            max: 100,
            onChanged: (v) {
              setState(() => _tone = v);
              _syncHexFromSliders();
            },
            theme: theme,
          ),
          const SizedBox(height: 8),
          // 접이식 Chroma 슬라이더
          GestureDetector(
            onTap: () => setState(() => _chromaExpanded = !_chromaExpanded),
            child: Row(
              children: [
                Text(
                  l.themePickerChroma,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Icon(
                  _chromaExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          if (_chromaExpanded)
            Slider(
              value: _chroma,
              min: 10,
              max: 100,
              onChanged: (v) {
                setState(() => _chroma = v);
                _syncHexFromSliders();
              },
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
